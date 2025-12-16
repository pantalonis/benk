//
//  PixelRoomAchievementsView.swift
//  benk
//
//  Achievements & Rewards view with iOS 26 Liquid Glass design
//

import SwiftUI

struct PixelRoomAchievementsView: View {
    @StateObject private var achievementManager = AchievementManager.shared
    @StateObject private var currencyManager = CurrencyManager.shared
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var parentTheme: ThemeService
    @State private var selectedTab: AchievementTab = .achievements
    @State private var showDailyRewardSheet = false
    @State private var showAchievementDetail: Achievement?
    
    enum AchievementTab: String, CaseIterable {
        case achievements = "Achievements"
        case dailyTasks = "Tasks"
        case rewards = "Rewards"
    }
    
    var body: some View {
        ZStack {
            // Themed background with effects (snow, stars, etc.)
            ThemedBackground(theme: parentTheme.currentTheme)
            
            VStack(spacing: 0) {
                // Top spacing for container top bar
                Color.clear.frame(height: 60)
                
                // Header
                glassHeaderView
                    .padding(.horizontal, 16)
                
                // Tab Selector
                glassTabSelector
                    .padding(.top, 12)
                
                // Content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        switch selectedTab {
                        case .achievements:
                            achievementsContent
                        case .dailyTasks:
                            dailyTasksContent
                        case .rewards:
                            rewardsContent
                        }
                    }
                    .padding(16)
                }
                .padding(.bottom, 100)
            }
        }
        .sheet(isPresented: $showDailyRewardSheet) {
            DailyRewardSheet()
        }
        .sheet(item: $showAchievementDetail) { achievement in
            AchievementDetailSheet(achievement: achievement)
        }
        .onAppear {
            achievementManager.checkDailyReset()
        }
    }
    
    // MARK: - Glass Header
    private var glassHeaderView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("🏆 Rewards")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(parentTheme.currentTheme.text)
                
                Text("\(achievementManager.completedAchievements.count)/\(AchievementCatalog.allAchievements.count) Unlocked")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(parentTheme.currentTheme.textSecondary)
            }
            
            Spacer()
            
            // Progress ring
            ZStack {
                Circle()
                    .stroke(parentTheme.currentTheme.textSecondary.opacity(0.2), lineWidth: 4)
                    .frame(width: 44, height: 44)
                
                Circle()
                    .trim(from: 0, to: achievementManager.totalAchievementProgress)
                    .stroke(
                        LinearGradient(
                            colors: [parentTheme.currentTheme.accent, parentTheme.currentTheme.glow],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 44, height: 44)
                    .rotationEffect(.degrees(-90))
                
                Text("\(Int(achievementManager.totalAchievementProgress * 100))%")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(parentTheme.currentTheme.text)
            }
        }
    }
    
    // MARK: - Glass Tab Selector
    private var glassTabSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(AchievementTab.allCases, id: \.self) { tab in
                    glassTabButton(for: tab)
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    private func glassTabButton(for tab: AchievementTab) -> some View {
        let isSelected = selectedTab == tab
        let textColor = isSelected ? parentTheme.currentTheme.text : parentTheme.currentTheme.textSecondary
        let fillColor: AnyShapeStyle = isSelected ? AnyShapeStyle(parentTheme.currentTheme.accent.opacity(0.2)) : AnyShapeStyle(.ultraThinMaterial)
        let strokeColor = isSelected ? parentTheme.currentTheme.accent.opacity(0.5) : Color.white.opacity(0.1)
        
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                selectedTab = tab
            }
            HapticManager.shared.selection()
        } label: {
            Text(tab.rawValue)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(textColor)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(fillColor)
                        .overlay(
                            Capsule()
                                .stroke(strokeColor, lineWidth: 1)
                        )
                )
        }
    }
    
    // MARK: - Achievements Content
    private var achievementsContent: some View {
        VStack(spacing: 16) {
            // Unclaimed achievements
            if !achievementManager.unclaimedAchievements.isEmpty {
                glassSection(title: "🎁 Ready to Claim") {
                    ForEach(achievementManager.unclaimedAchievements) { achievement in
                        GlassAchievementCard(achievement: achievement, isUnclaimed: true, parentTheme: parentTheme)
                            .onTapGesture {
                                claimAchievement(achievement)
                            }
                    }
                }
            }
            
            // In progress
            if !achievementManager.inProgressAchievements.isEmpty {
                glassSection(title: "📊 In Progress") {
                    ForEach(achievementManager.inProgressAchievements) { achievement in
                        GlassAchievementCard(achievement: achievement, parentTheme: parentTheme)
                            .onTapGesture {
                                showAchievementDetail = achievement
                            }
                    }
                }
            }
            
            // Completed
            if !achievementManager.completedAchievements.isEmpty {
                glassSection(title: "✅ Completed") {
                    ForEach(achievementManager.completedAchievements) { achievement in
                        GlassAchievementCard(achievement: achievement, isCompleted: true, parentTheme: parentTheme)
                    }
                }
            }
            
            // Locked
            let lockedAchievements = AchievementCatalog.allAchievements.filter { achievement in
                let progress = achievementManager.achievementProgress[achievement.id]
                return progress?.currentValue == 0
            }
            
            if !lockedAchievements.isEmpty {
                glassSection(title: "🔒 Locked") {
                    ForEach(lockedAchievements) { achievement in
                        GlassAchievementCard(achievement: achievement, isLocked: true, parentTheme: parentTheme)
                    }
                }
            }
        }
    }
    
    // MARK: - Daily Tasks Content
    private var dailyTasksContent: some View {
        VStack(spacing: 16) {
            // Header card
            VStack(spacing: 8) {
                Text("📅 Daily Challenges")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(parentTheme.currentTheme.text)
                
                Text("Complete tasks to earn bonus coins!")
                    .font(.system(size: 13))
                    .foregroundColor(parentTheme.currentTheme.textSecondary)
                
                Text("Resets in: \(timeUntilReset)")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(parentTheme.currentTheme.accent)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(parentTheme.currentTheme.accent.opacity(0.15))
                    )
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    colors: [parentTheme.currentTheme.accent.opacity(0.3), parentTheme.currentTheme.glow.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 0.5
                            )
                    )
            )
            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
            
            // Tasks
            ForEach(achievementManager.currentDailyTasks) { task in
                GlassDailyTaskCard(task: task, parentTheme: parentTheme)
            }
            
            // Completion summary
            let completedCount = achievementManager.completedDailyTasks.count
            let totalCount = achievementManager.currentDailyTasks.count
            
            if completedCount > 0 {
                HStack {
                    Text("✨ Progress: \(completedCount)/\(totalCount) completed")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(parentTheme.currentTheme.text)
                    Spacer()
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.green.opacity(0.15))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.green.opacity(0.3), lineWidth: 0.5)
                        )
                )
            }
        }
    }
    
    // MARK: - Rewards Content
    private var rewardsContent: some View {
        VStack(spacing: 16) {
            // Login streak card
            GlassLoginStreakCard(parentTheme: parentTheme)
            
            // Daily reward
            GlassDailyRewardCard(showSheet: $showDailyRewardSheet, parentTheme: parentTheme)
            
            // Weekly rewards preview
            VStack(alignment: .leading, spacing: 12) {
                Text("📅 Weekly Rewards")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(parentTheme.currentTheme.text)
                
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 70))], spacing: 12) {
                    ForEach(1...7, id: \.self) { day in
                        GlassWeeklyRewardDay(day: day, currentDay: achievementManager.loginStreak.currentStreak, parentTheme: parentTheme)
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                    )
            )
            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
        }
    }
    
    // MARK: - Glass Section
    private func glassSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(parentTheme.currentTheme.text)
            
            content()
        }
    }
    
    // MARK: - Helper Functions
    private func claimAchievement(_ achievement: Achievement) {
        if achievementManager.claimAchievementReward(achievement.id) {
            HapticManager.shared.notification(.success)
        }
    }
    
    private var timeUntilReset: String {
        let now = Date()
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now))!
        let components = calendar.dateComponents([.hour, .minute], from: now, to: tomorrow)
        return String(format: "%02dh %02dm", components.hour ?? 0, components.minute ?? 0)
    }
}

// MARK: - Glass Achievement Card
struct GlassAchievementCard: View {
    let achievement: Achievement
    var isCompleted: Bool = false
    var isUnclaimed: Bool = false
    var isLocked: Bool = false
    let parentTheme: ThemeService
    
    @StateObject private var achievementManager = AchievementManager.shared
    
    var body: some View {
        HStack(spacing: 14) {
            // Icon
            ZStack {
                Circle()
                    .fill(
                        isLocked ?
                        LinearGradient(colors: [Color.gray.opacity(0.2), Color.gray.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing) :
                        LinearGradient(colors: [achievement.tier.color.opacity(0.5), achievement.tier.color.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 50, height: 50)
                
                Text(achievement.icon)
                    .font(.system(size: 24))
                    .opacity(isLocked ? 0.3 : 1.0)
                
                if isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.green)
                        .background(Circle().fill(Color.white))
                        .offset(x: 18, y: -18)
                }
            }
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Text(achievement.tier.emoji)
                        .font(.system(size: 10))
                    Text(achievement.title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(parentTheme.currentTheme.text)
                        .opacity(isLocked ? 0.5 : 1.0)
                }
                
                Text(achievement.description)
                    .font(.system(size: 12))
                    .foregroundColor(parentTheme.currentTheme.textSecondary)
                    .lineLimit(2)
                
                if !isCompleted && !isLocked {
                    if let progress = achievementManager.achievementProgress[achievement.id] {
                        HStack(spacing: 8) {
                            ProgressView(value: progress.progress)
                                .tint(achievement.tier.color)
                            
                            Text("\(progress.currentValue)/\(achievement.targetValue)")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(parentTheme.currentTheme.textSecondary)
                        }
                    }
                }
                
                if isUnclaimed {
                    HStack {
                        Text("💰 +\(achievement.rewardCoins)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.yellow)
                        
                        Spacer()
                        
                        Text("Tap to claim!")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Capsule().fill(Color.green))
                    }
                }
            }
            
            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            isUnclaimed ? Color.green.opacity(0.4) : Color.white.opacity(0.1),
                            lineWidth: 0.5
                        )
                )
        )
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Glass Daily Task Card
struct GlassDailyTaskCard: View {
    let task: DailyTask
    let parentTheme: ThemeService
    @StateObject private var achievementManager = AchievementManager.shared
    
    var body: some View {
        HStack(spacing: 14) {
            // Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [parentTheme.currentTheme.accent.opacity(0.3), parentTheme.currentTheme.glow.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                
                Text(task.icon)
                    .font(.system(size: 20))
                
                if let progress = achievementManager.dailyTaskProgress[task.id], progress.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.green)
                        .background(Circle().fill(Color.white))
                        .offset(x: 16, y: -16)
                }
            }
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(parentTheme.currentTheme.text)
                
                Text(task.description)
                    .font(.system(size: 12))
                    .foregroundColor(parentTheme.currentTheme.textSecondary)
                
                if let progress = achievementManager.dailyTaskProgress[task.id] {
                    if progress.isCompleted {
                        Text("✅ Done! +\(task.rewardCoins)")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.green)
                    } else {
                        HStack(spacing: 8) {
                            ProgressView(value: progress.progress)
                                .tint(parentTheme.currentTheme.accent)
                            
                            Text("\(progress.currentValue)/\(task.targetValue)")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(parentTheme.currentTheme.textSecondary)
                        }
                    }
                }
            }
            
            Spacer()
            
            // Reward
            VStack {
                Text("💰")
                    .font(.system(size: 16))
                Text("+\(task.rewardCoins)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.yellow)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                )
        )
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Glass Login Streak Card
struct GlassLoginStreakCard: View {
    let parentTheme: ThemeService
    @StateObject private var achievementManager = AchievementManager.shared
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("🔥 Login Streak")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(parentTheme.currentTheme.text)
                    
                    Text("Keep it going!")
                        .font(.system(size: 12))
                        .foregroundColor(parentTheme.currentTheme.textSecondary)
                }
                
                Spacer()
                
                VStack {
                    Text("\(achievementManager.loginStreak.currentStreak)")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.orange)
                    Text("days")
                        .font(.system(size: 11))
                        .foregroundColor(parentTheme.currentTheme.textSecondary)
                }
            }
            
            Divider()
                .background(Color.white.opacity(0.15))
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Longest")
                        .font(.system(size: 11))
                        .foregroundColor(parentTheme.currentTheme.textSecondary)
                    Text("\(achievementManager.loginStreak.longestStreak) days")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(parentTheme.currentTheme.text)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Total Logins")
                        .font(.system(size: 11))
                        .foregroundColor(parentTheme.currentTheme.textSecondary)
                    Text("\(achievementManager.loginStreak.totalLogins)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(parentTheme.currentTheme.text)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [.orange.opacity(0.4), .red.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.5
                        )
                )
        )
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Glass Daily Reward Card
struct GlassDailyRewardCard: View {
    @Binding var showSheet: Bool
    let parentTheme: ThemeService
    @StateObject private var achievementManager = AchievementManager.shared
    
    var body: some View {
        Button {
            if achievementManager.canClaimDailyReward {
                showSheet = true
            }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("🎁 Daily Reward")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(parentTheme.currentTheme.text)
                    
                    if achievementManager.canClaimDailyReward {
                        Text("Tap to claim!")
                            .font(.system(size: 12))
                            .foregroundColor(.green)
                    } else if achievementManager.dailyRewardClaimed {
                        Text("✅ Claimed today")
                            .font(.system(size: 12))
                            .foregroundColor(parentTheme.currentTheme.textSecondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: achievementManager.canClaimDailyReward ? "gift.fill" : "gift")
                    .font(.system(size: 32))
                    .foregroundColor(achievementManager.canClaimDailyReward ? .yellow : parentTheme.currentTheme.textSecondary.opacity(0.3))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                achievementManager.canClaimDailyReward ?
                                Color.yellow.opacity(0.4) :
                                Color.white.opacity(0.1),
                                lineWidth: 0.5
                            )
                    )
            )
            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
        }
        .disabled(!achievementManager.canClaimDailyReward)
    }
}

// MARK: - Glass Weekly Reward Day
struct GlassWeeklyRewardDay: View {
    let day: Int
    let currentDay: Int
    let parentTheme: ThemeService
    
    var reward: DailyReward {
        DailyRewardCatalog.getReward(for: day)
    }
    
    var isCompleted: Bool { currentDay >= day }
    var isCurrent: Bool { currentDay == day }
    
    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(
                        isCurrent ?
                        LinearGradient(colors: [.yellow, .orange], startPoint: .topLeading, endPoint: .bottomTrailing) :
                        isCompleted ?
                        LinearGradient(colors: [.green.opacity(0.4), .blue.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing) :
                        LinearGradient(colors: [Color.white.opacity(0.1), Color.white.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 50, height: 50)
                
                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    Text("Day \(day)")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(parentTheme.currentTheme.textSecondary)
                }
            }
            
            Text("\(reward.coins) 💰")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(isCurrent ? .yellow : parentTheme.currentTheme.textSecondary)
        }
    }
}

// MARK: - Daily Reward Sheet
struct DailyRewardSheet: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var achievementManager = AchievementManager.shared
    @EnvironmentObject var parentTheme: ThemeService
    @State private var showConfetti = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.9)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Text("🎉")
                    .font(.system(size: 80))
                
                Text("Daily Reward!")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                let reward = DailyRewardCatalog.getReward(for: achievementManager.loginStreak.currentStreak)
                VStack(spacing: 12) {
                    Text("Day \(achievementManager.loginStreak.currentStreak)")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text("💰 \(reward.coins) Coins")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.yellow)
                    
                    if reward.bonusItem != nil {
                        Text("+ Bonus Item!")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.green)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.1))
                )
                
                Button {
                    claimReward()
                } label: {
                    Text("Claim Reward")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [Color.green, Color.blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                }
                .padding(.horizontal)
            }
            .padding()
        }
    }
    
    private func claimReward() {
        if let _ = achievementManager.claimDailyReward() {
            HapticManager.shared.notification(.success)
            showConfetti = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                dismiss()
            }
        }
    }
}

// MARK: - Achievement Detail Sheet
struct AchievementDetailSheet: View {
    let achievement: Achievement
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var parentTheme: ThemeService
    @StateObject private var achievementManager = AchievementManager.shared
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.9)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Close button
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                .padding()
                
                Spacer()
                
                // Achievement icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [achievement.tier.color, achievement.tier.color.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                    
                    Text(achievement.icon)
                        .font(.system(size: 60))
                }
                
                // Title
                VStack(spacing: 8) {
                    HStack {
                        Text(achievement.tier.emoji)
                        Text(achievement.title)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    Text(achievement.description)
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Progress
                if let progress = achievementManager.achievementProgress[achievement.id] {
                    VStack(spacing: 8) {
                        ProgressView(value: progress.progress)
                            .tint(achievement.tier.color)
                            .scaleEffect(y: 2)
                        
                        Text("\(progress.currentValue)/\(achievement.targetValue)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.1))
                    )
                    .padding(.horizontal)
                }
                
                // Reward
                VStack(spacing: 4) {
                    Text("Reward")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                    Text("💰 \(achievement.rewardCoins) Coins")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.yellow)
                }
                
                Spacer()
            }
        }
    }
}

#Preview("PixelRoomAchievementsView") {
    PixelRoomAchievementsView()
        .environmentObject(ThemeManager())
        .environmentObject(ThemeService.shared)
}

