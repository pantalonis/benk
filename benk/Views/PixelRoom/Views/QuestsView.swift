//
//  QuestsView.swift
//  benk
//
//  Main Quests page with Daily/Weekly/Goals filtering
//  Replaces the old PixelRoomAchievementsView
//

import SwiftUI
import SwiftData

// Wrapper struct for quest detail sheet to fix rendering issue
struct SelectedQuestInfo: Identifiable {
    let id = UUID()
    let template: QuestTemplate
    let progress: Int
    let isCompleted: Bool
    let isClaimed: Bool
}

struct QuestsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var userProfiles: [UserProfile]
    @Query(filter: #Predicate<StudySession> { $0.isCompleted })
    private var completedSessions: [StudySession]
    
    @StateObject private var questService = QuestService.shared
    @StateObject private var questStats = QuestStats.shared
    @EnvironmentObject var themeService: ThemeService
    
    @State private var selectedCategory: QuestCategory = .daily
    @State private var selectedQuestInfo: SelectedQuestInfo?
    @State private var showTransactionLog = false
    
    private var userProfile: UserProfile? {
        userProfiles.first
    }
    
    var body: some View {
        ZStack {
            // Themed Background (includes effects like snow for Christmas)
            ThemedBackground(theme: themeService.currentTheme)
            
            // Scrollable Content (underneath sticky header)
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // Spacer to account for sticky header height
                    Color.clear
                        .frame(height: stickyHeaderHeight)
                    
                    switch selectedCategory {
                    case .daily:
                        dailyContent
                    case .weekly:
                        weeklyContent
                    case .goals:
                        goalsContent
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 120) // Bottom padding for tab bar
            }
            .scrollBounceBehavior(.automatic)
            
            // Sticky Header Overlay (fully transparent)
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    // Header
                    headerSection
                        .padding(.horizontal)
                        .padding(.top, 8)
                        .padding(.bottom, 8)
                    
                    // Category Filter Buttons
                    categoryFilterButtons
                        .padding(.vertical, 10)
                    
                    // Progress Widget
                    progressWidget
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                }
                // No background - fully transparent
                
                Spacer()
            }
        }
        .sheet(item: $selectedQuestInfo) { questInfo in
            QuestDetailSheet(
                template: questInfo.template,
                currentProgress: questInfo.progress,
                isCompleted: questInfo.isCompleted,
                isClaimed: questInfo.isClaimed
            )
        }
        .onAppear {
            // Sync study minutes from actual SwiftData sessions
            questStats.syncStudyMinutesFromSessions(completedSessions)
            
            // Force refresh if quests are using old 3-quest format
            if questService.activeDailyQuests.count < 5 || questService.activeWeeklyQuests.count < 5 {
                questService.forceRefreshAllQuests()
            }
            
            questStats.checkResets()
            questService.checkRefresh()
            questService.updateAllProgress()
        }
    }
    
    // Height for sticky header
    private var stickyHeaderHeight: CGFloat {
        // Header (50) + category buttons (50) + progress widget (100) + padding/spacing
        return 210
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            Text("Quests")
                .font(.largeTitle.weight(.bold))
                .foregroundColor(themeService.currentTheme.text)
            
            Spacer()
            
            // Coins display (tappable) - matches container view styling
            HStack(spacing: 8) {
                Image(systemName: "dollarsign.circle.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.yellow, .orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Text("\(CurrencyManager.shared.coins)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(themeService.currentTheme.text)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)
                    .overlay(
                        Capsule()
                            .stroke(
                                LinearGradient(
                                    colors: [.white.opacity(0.3), .white.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 0.5
                            )
                    )
            )
            .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
            .onTapGesture {
                showTransactionLog = true
                HapticManager.shared.selection()
            }
            .sheet(isPresented: $showTransactionLog) {
                CoinTransactionLogView()
                    .environmentObject(themeService)
            }
        }
    }
    
    // MARK: - Category Filter Buttons
    private var categoryFilterButtons: some View {
        HStack(spacing: 8) {
            ForEach(QuestCategory.allCases, id: \.self) { category in
                categoryButton(for: category)
            }
        }
        .padding(.horizontal)
    }
    
    private func categoryButton(for category: QuestCategory) -> some View {
        let isSelected = selectedCategory == category
        
        return Button {
            SoundManager.shared.buttonTap()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                selectedCategory = category
            }
            HapticManager.shared.selection()
        } label: {
            Text(category.rawValue)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(isSelected ? themeService.currentTheme.text : themeService.currentTheme.textSecondary)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(categoryButtonBackground(isSelected: isSelected))
        }
    }
    
    @ViewBuilder
    private func categoryButtonBackground(isSelected: Bool) -> some View {
        if isSelected {
            Capsule()
                .fill(themeService.currentTheme.accent.opacity(0.2))
                .overlay(
                    Capsule()
                        .stroke(themeService.currentTheme.accent.opacity(0.5), lineWidth: 1)
                )
        } else {
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        }
    }
    
    // MARK: - Progress Widget
    private var progressWidget: some View {
        let progress: Double
        let completed: Int
        let total: Int
        
        switch selectedCategory {
        case .daily:
            progress = questService.dailyProgress
            completed = questService.completedDailyCount
            total = questService.activeDailyQuests.count
        case .weekly:
            progress = questService.weeklyProgress
            completed = questService.completedWeeklyCount
            total = questService.activeWeeklyQuests.count
        case .goals:
            progress = questService.goalsProgress
            completed = questService.completedGoalsCount
            total = questService.totalGoalsCount
        }
        
        return GlassCard(padding: 16) {
            HStack(spacing: 16) {
                // Circular Progress
                ZStack {
                    Circle()
                        .stroke(themeService.currentTheme.textSecondary.opacity(0.2), lineWidth: 8)
                        .frame(width: 60, height: 60)
                    
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            LinearGradient(
                                colors: [themeService.currentTheme.accent, themeService.currentTheme.glow],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 60, height: 60)
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(response: 0.5), value: progress)
                    
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(themeService.currentTheme.text)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(selectedCategory.rawValue) Progress")
                        .font(.headline)
                        .foregroundColor(themeService.currentTheme.text)
                    
                    Text("\(completed)/\(total) Completed")
                        .font(.subheadline)
                        .foregroundColor(themeService.currentTheme.textSecondary)
                }
                
                Spacer()
            }
        }
    }
    
    // MARK: - Daily Content
    private var dailyContent: some View {
        VStack(spacing: 16) {
            // Streak Reward Card
            if let profile = userProfile {
                StreakRewardCard(
                    streak: profile.currentStreak,
                    canClaim: questStats.canClaimStreakReward,
                    coinReward: questService.streakRewardCoins(for: profile.currentStreak),
                    onClaim: {
                        if let coins = questService.claimStreakReward(streak: profile.currentStreak) {
                            print("Claimed \(coins) streak reward coins")
                        }
                    }
                )
            }
            
            // Daily Challenges Header
            HStack {
                Text("Daily Challenges")
                    .font(.title3.weight(.bold))
                    .foregroundColor(themeService.currentTheme.text)
                
                Spacer()
                
                Text("Resets: \(timeUntilDailyReset)")
                    .font(.caption)
                    .foregroundColor(themeService.currentTheme.textSecondary)
            }
            
            // Daily Quest Cards
            ForEach(questService.activeDailyQuests) { quest in
                if let template = QuestCatalog.getTemplate(id: quest.templateId) {
                    QuestCard(
                        template: template,
                        currentProgress: quest.currentProgress,
                        isCompleted: quest.isCompleted,
                        isClaimed: quest.isClaimed,
                        onTap: {
                            selectedQuestInfo = SelectedQuestInfo(
                                template: template,
                                progress: quest.currentProgress,
                                isCompleted: quest.isCompleted,
                                isClaimed: quest.isClaimed
                            )
                        },
                        onClaim: {
                            _ = questService.claimDailyQuest(id: quest.id)
                        }
                    )
                }
            }
        }
    }
    
    // MARK: - Weekly Content
    private var weeklyContent: some View {
        VStack(spacing: 16) {
            // Weekly Challenges Header
            HStack {
                Text("Weekly Challenges")
                    .font(.title3.weight(.bold))
                    .foregroundColor(themeService.currentTheme.text)
                
                Spacer()
                
                Text("Resets Monday")
                    .font(.caption)
                    .foregroundColor(themeService.currentTheme.textSecondary)
            }
            
            // Weekly Quest Cards
            ForEach(questService.activeWeeklyQuests) { quest in
                if let template = QuestCatalog.getTemplate(id: quest.templateId) {
                    QuestCard(
                        template: template,
                        currentProgress: quest.currentProgress,
                        isCompleted: quest.isCompleted,
                        isClaimed: quest.isClaimed,
                        onTap: {
                            selectedQuestInfo = SelectedQuestInfo(
                                template: template,
                                progress: quest.currentProgress,
                                isCompleted: quest.isCompleted,
                                isClaimed: quest.isClaimed
                            )
                        },
                        onClaim: {
                            _ = questService.claimWeeklyQuest(id: quest.id)
                        }
                    )
                }
            }
        }
    }
    
    // MARK: - Goals Content
    private var goalsContent: some View {
        VStack(spacing: 16) {
            // Goals Header
            HStack {
                Text("Goals")
                    .font(.title3.weight(.bold))
                    .foregroundColor(themeService.currentTheme.text)
                
                Spacer()
                
                Text("\(questService.completedGoalsCount)/\(QuestCatalog.goalQuests.count)")
                    .font(.caption)
                    .foregroundColor(themeService.currentTheme.textSecondary)
            }
            
            // Goal Cards
            ForEach(QuestCatalog.goalQuests) { template in
                let progress = questService.getGoalProgress(for: template)
                let isCompleted = questService.isGoalCompleted(template)
                let isClaimable = questService.isGoalClaimable(template)
                
                QuestCard(
                    template: template,
                    currentProgress: progress,
                    isCompleted: isCompleted || isClaimable,
                    isClaimed: isCompleted,
                    onTap: {
                        selectedQuestInfo = SelectedQuestInfo(
                            template: template,
                            progress: progress,
                            isCompleted: isCompleted || isClaimable,
                            isClaimed: isCompleted
                        )
                    },
                    onClaim: {
                        _ = questService.claimGoal(templateId: template.id)
                    }
                )
            }
        }
    }
    
    // MARK: - Helpers
    private var timeUntilDailyReset: String {
        let now = Date()
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now))!
        let components = calendar.dateComponents([.hour, .minute], from: now, to: tomorrow)
        return String(format: "%02dh %02dm", components.hour ?? 0, components.minute ?? 0)
    }
}

// MARK: - Preview
#Preview {
    QuestsView()
        .environmentObject(ThemeService.shared)
}
