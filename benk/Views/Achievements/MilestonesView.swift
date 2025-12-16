//
//  MilestonesView.swift
//  benk
//
//  Created on 2025-12-14
//

import SwiftUI
import SwiftData

struct MilestonesView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeService: ThemeService
    @EnvironmentObject var badgeService: BadgeService
    
    @Query private var badges: [Badge]
    @Query private var userProfiles: [UserProfile]
    @Query(filter: #Predicate<StudySession> { $0.isCompleted }) private var completedSessions: [StudySession]
    @Query private var allSessions: [StudySession]
    @Query private var tasks: [Task]
    @Query private var techniques: [Technique]
    
    @State private var selectedBadge: Badge?
    @State private var animateHeader = false
    @State private var animateBadges = false
    
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var userProfile: UserProfile {
        userProfiles.first ?? UserProfile()
    }
    
    var earnedBadgesCount: Int {
        badges.filter { $0.isEarned }.count
    }
    
    var totalBadgesCount: Int {
        badges.count
    }
    
    // Group badges by category
    var badgesByCategory: [(category: BadgeCategory, badges: [Badge])] {
        var result: [(category: BadgeCategory, badges: [Badge])] = []
        
        for category in BadgeCategory.allCases {
            let categoryBadges = badges
                .filter { $0.badgeCategory == category }
                .sorted { $0.sortOrder < $1.sortOrder }
            
            if !categoryBadges.isEmpty {
                result.append((category, categoryBadges))
            }
        }
        
        return result
    }
    
    var body: some View {
        ZStack {
            // Background
            themeService.currentTheme.background
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header with navigation
                    headerSection
                    
                    // Streak and Badges Header
                    statsHeader
                        .opacity(animateHeader ? 1 : 0)
                        .offset(y: animateHeader ? 0 : 20)
                    
                    // Stats Cards
                    statsCards
                        .opacity(animateHeader ? 1 : 0)
                        .offset(y: animateHeader ? 0 : 20)
                    
                    // Badge Grid by Category
                    badgeCategories
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal)
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            updateBadgeProgress()
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                animateHeader = true
            }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3)) {
                animateBadges = true
            }
        }
        .sheet(item: $selectedBadge) { badge in
            BadgeDetailPopup(badge: badge)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "arrow.left")
                    .font(.title2.weight(.semibold))
                    .foregroundColor(themeService.currentTheme.text)
                    .frame(width: 44, height: 44)
                    .background(themeService.currentTheme.surface.opacity(0.5))
                    .clipShape(Circle())
            }
            
            Spacer()
            
            Text("Milestones")
                .font(.title.weight(.bold))
                .foregroundColor(themeService.currentTheme.text)
            
            Spacer()
            
            // Share button placeholder
            Circle()
                .fill(Color.clear)
                .frame(width: 44, height: 44)
        }
        .padding(.top, 8)
    }
    
    // MARK: - Streak color based on milestone
    private var streakColor: Color {
        StreakMilestone.color(for: userProfile.currentStreak)
    }
    
    private var isRainbowStreak: Bool {
        StreakMilestone.isRainbow(for: userProfile.currentStreak)
    }
    
    // MARK: - Stats Header (Fire + Badge icons)
    private var statsHeader: some View {
        HStack(spacing: 12) {
            // Streak Fire
            VStack(spacing: 8) {
                ZStack {
                    // Fire glow effect with milestone color
                    if isRainbowStreak {
                        // Rainbow animated glow for 1000+ streak
                        Circle()
                            .fill(
                                AngularGradient(
                                    colors: StreakMilestone.rainbowColors + [StreakMilestone.rainbowColors.first ?? .red],
                                    center: .center
                                )
                            )
                            .blur(radius: 20)
                            .frame(width: 100, height: 100)
                    } else {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        streakColor.opacity(0.5),
                                        streakColor.opacity(0.2),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 20,
                                    endRadius: 60
                                )
                            )
                            .frame(width: 100, height: 100)
                    }
                    
                    // Fire icon with number
                    ZStack {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(
                                isRainbowStreak
                                    ? AnyShapeStyle(LinearGradient(
                                        colors: StreakMilestone.rainbowColors,
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                                    : AnyShapeStyle(streakColor)
                            )
                        
                        Text("\(userProfile.currentStreak)")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                            .offset(y: 4)
                    }
                }
                .frame(height: 100)
                
                Text("Day streak")
                    .font(.headline)
                    .foregroundColor(themeService.currentTheme.text)
            }
            .frame(maxWidth: .infinity)
            
            // Badges Earned
            VStack(spacing: 8) {
                ZStack {
                    // Badge shape
                    BadgeShape()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: "#FFD700") ?? .yellow,
                                    Color(hex: "#B8860B") ?? .orange
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 90)
                        .shadow(color: (Color(hex: "#FFD700") ?? .yellow).opacity(0.4), radius: 10, x: 0, y: 4)
                    
                    // Inner badge
                    BadgeShape()
                        .fill(themeService.currentTheme.surface)
                        .frame(width: 60, height: 70)
                    
                    Text("\(earnedBadgesCount)")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(themeService.currentTheme.text)
                }
                .frame(height: 100)
                
                Text("Badges earned")
                    .font(.headline)
                    .foregroundColor(themeService.currentTheme.text)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 20)
    }
    
    // MARK: - Stats Cards
    private var statsCards: some View {
        HStack(spacing: 12) {
            // Longest Streak Card
            GlassCard(padding: 16) {
                HStack(spacing: 10) {
                    Text("🔥")
                        .font(.system(size: 30))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(alignment: .lastTextBaseline, spacing: 2) {
                            Text("\(userProfile.longestStreak)")
                                .font(.system(size: userProfile.longestStreak >= 1000 ? 18 : 24, weight: .bold, design: .rounded))
                                .foregroundColor(themeService.currentTheme.text)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                            Text("days")
                                .font(.system(size: 10))
                                .foregroundColor(themeService.currentTheme.textSecondary)
                        }
                        Text("longest")
                            .font(.system(size: 10))
                            .foregroundColor(themeService.currentTheme.textSecondary)
                    }
                    
                    Spacer(minLength: 0)
                }
            }
            
            // Badges Progress Card
            GlassCard(padding: 16) {
                HStack(spacing: 12) {
                    Circle()
                        .fill(themeService.currentTheme.surface)
                        .frame(width: 40, height: 40)
                        .overlay(
                            Circle()
                                .trim(from: 0, to: totalBadgesCount > 0 ? CGFloat(earnedBadgesCount) / CGFloat(totalBadgesCount) : 0)
                                .stroke(themeService.currentTheme.accent, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                                .rotationEffect(.degrees(-90))
                        )
                        .overlay(
                            Circle()
                                .fill(themeService.currentTheme.accent)
                                .frame(width: 12, height: 12)
                        )
                    
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(alignment: .lastTextBaseline, spacing: 2) {
                            Text("\(earnedBadgesCount)")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(themeService.currentTheme.text)
                            Text("/\(totalBadgesCount)")
                                .font(.caption)
                                .foregroundColor(themeService.currentTheme.textSecondary)
                        }
                        Text("badges")
                            .font(.caption)
                            .foregroundColor(themeService.currentTheme.textSecondary)
                    }
                    
                    Spacer()
                }
            }
        }
    }
    
    // MARK: - Badge Categories
    private var badgeCategories: some View {
        VStack(spacing: 28) {
            ForEach(Array(badgesByCategory.enumerated()), id: \.element.category) { index, categoryData in
                VStack(alignment: .leading, spacing: 12) {
                    // Category Header
                    Text(categoryTitle(for: categoryData.category))
                        .font(.title3.weight(.bold))
                        .foregroundColor(themeService.currentTheme.text)
                        .padding(.leading, 4)
                    
                    // Badge Grid
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(Array(categoryData.badges.enumerated()), id: \.element.id) { badgeIndex, badge in
                            BadgeGridItem(badge: badge)
                                .opacity(animateBadges ? 1 : 0)
                                .offset(y: animateBadges ? 0 : 30)
                                .animation(
                                    .spring(response: 0.5, dampingFraction: 0.7)
                                    .delay(Double(index) * 0.1 + Double(badgeIndex) * 0.05),
                                    value: animateBadges
                                )
                                .onTapGesture {
                                    selectedBadge = badge
                                    HapticManager.shared.selection()
                                }
                        }
                    }
                }
            }
        }
        .padding(.top, 8)
    }
    
    private func categoryTitle(for category: BadgeCategory) -> String {
        switch category {
        case .streak: return "Streak Badges"
        case .dailyGoal: return "Daily Goal Badges"
        case .technique: return "Technique Badges"
        case .timeSpent: return "Time Badges"
        case .taskCompletion: return "Task Badges"
        case .special: return "Special Badges"
        case .xpMilestone: return "XP Badges"
        case .subjectMastery: return "Subject Badges"
        }
    }
    
    // MARK: - Update Badge Progress
    private func updateBadgeProgress() {
        // Update streak badges progress
        let currentStreak = userProfile.currentStreak
        
        // Update longest streak if needed
        if userProfile.longestStreak < currentStreak {
            userProfile.longestStreak = currentStreak
        }
        
        // Calculate total study time in minutes
        let totalMinutes = completedSessions.reduce(0) { $0 + ($1.duration / 60) }
        
        // Calculate completed tasks
        let completedTasksCount = tasks.filter { $0.isCompleted }.count
        
        // Calculate unique techniques used (from sessions with techniqueId)
        let usedTechniqueIds = Set(completedSessions.compactMap { $0.techniqueId })
        let uniqueTechniquesCount = usedTechniqueIds.count
        
        // Calculate techniques used today
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let todaySessions = completedSessions.filter { calendar.isDate($0.timestamp, inSameDayAs: today) }
        let techniquesUsedToday = Set(todaySessions.compactMap { $0.techniqueId }).count
        
        // Calculate subjects studied today
        let subjectsStudiedToday = Set(todaySessions.compactMap { $0.subjectId }).count
        
        // Check for late night sessions (after 10 PM)
        let lateNightSessions = completedSessions.filter { session in
            let hour = calendar.component(.hour, from: session.timestamp)
            return hour >= 22 || hour < 6
        }
        let _ = lateNightSessions.count
        
        // Check for after midnight sessions (Gremlin badge)
        let afterMidnightSessions = completedSessions.filter { session in
            let hour = calendar.component(.hour, from: session.timestamp)
            return hour >= 0 && hour < 5
        }
        let hasAfterMidnight = afterMidnightSessions.count > 0 ? 1 : 0
        
        // Check for early bird sessions (before 6 AM)
        let earlyBirdSessions = completedSessions.filter { session in
            let hour = calendar.component(.hour, from: session.timestamp)
            return hour >= 4 && hour < 6
        }
        let hasEarlyBird = earlyBirdSessions.count > 0 ? 1 : 0
        
        // Check for weekend sessions
        let weekendSessions = completedSessions.filter { session in
            let weekday = calendar.component(.weekday, from: session.timestamp)
            return weekday == 1 || weekday == 7 // Sunday = 1, Saturday = 7
        }
        let saturdaySessions = weekendSessions.filter { calendar.component(.weekday, from: $0.timestamp) == 7 }
        let sundaySessions = weekendSessions.filter { calendar.component(.weekday, from: $0.timestamp) == 1 }
        let weekendProgress = (saturdaySessions.isEmpty ? 0 : 1) + (sundaySessions.isEmpty ? 0 : 1)
        
        // Check for marathon sessions (4+ hours = 240+ minutes)
        let marathonSessions = completedSessions.filter { $0.duration >= 240 * 60 }
        let hasMarathon = marathonSessions.count > 0 ? 1 : 0
        
        // Check for Christmas study (December 25)
        let christmasSessions = completedSessions.filter { session in
            let components = calendar.dateComponents([.month, .day], from: session.timestamp)
            return components.month == 12 && components.day == 25
        }
        let christmasMinutes = christmasSessions.reduce(0) { $0 + ($1.duration / 60) }
        
        // Calculate days where daily goal was met
        let dailyGoalMinutes = userProfile.dailyGoalMinutes
        var daysGoalMet = 0
        let sessionsByDay = Dictionary(grouping: completedSessions) { session in
            calendar.startOfDay(for: session.timestamp)
        }
        for (_, daySessions) in sessionsByDay {
            let dayMinutes = daySessions.reduce(0) { $0 + ($1.duration / 60) }
            if dayMinutes >= dailyGoalMinutes {
                daysGoalMet += 1
            }
        }
        
        // Calculate comeback (7+ day gap before most recent session)
        var hasComeback = 0
        if completedSessions.count >= 2 {
            let sortedSessions = completedSessions.sorted { $0.timestamp > $1.timestamp }
            for i in 0..<(sortedSessions.count - 1) {
                let currentSession = sortedSessions[i]
                let previousSession = sortedSessions[i + 1]
                let daysBetween = calendar.dateComponents([.day], from: previousSession.timestamp, to: currentSession.timestamp).day ?? 0
                if daysBetween >= 7 {
                    hasComeback = 1
                    break
                }
            }
        }
        
        // Update each badge's progress (display only - no unlocking here)
        for badge in badges {
            var newProgress = 0
            
            switch badge.badgeCategory {
            case .streak:
                newProgress = currentStreak
                
            case .timeSpent:
                newProgress = totalMinutes
                
            case .taskCompletion:
                newProgress = completedTasksCount
                
            case .dailyGoal:
                // Count days where goal was actually met
                newProgress = daysGoalMet
                
            case .technique:
                // Different technique badges have different requirements
                if badge.name == "Method Actor" {
                    // Use 3 techniques in one day
                    newProgress = techniquesUsedToday
                } else {
                    // Discover X techniques (count unique techniques used ever)
                    newProgress = uniqueTechniquesCount
                }
                
            case .special:
                // Handle special badges by name
                switch badge.name {
                case "Gremlin":
                    newProgress = hasAfterMidnight
                case "Early Bird":
                    newProgress = hasEarlyBird
                case "Weekend Warrior":
                    newProgress = weekendProgress
                case "Marathon Runner":
                    newProgress = hasMarathon
                case "Perfect Week":
                    // Use streak as proxy for now
                    newProgress = min(currentStreak, 7)
                case "Night Owl":
                    newProgress = lateNightSessions.count
                case "Subject Hopper":
                    newProgress = subjectsStudiedToday
                case "Comeback Kid":
                    // Requires a 7+ day gap before resuming study
                    newProgress = hasComeback
                case "Holiday Hero":
                    newProgress = christmasMinutes
                default:
                    continue
                }
                
            default:
                continue
            }
            
            // Update progress display only (unlocking happens in BadgeService during actions)
            badge.progress = newProgress
        }
        
        try? modelContext.save()
    }
}

// MARK: - Badge Grid Item
struct BadgeGridItem: View {
    let badge: Badge
    @EnvironmentObject var themeService: ThemeService
    
    var body: some View {
        VStack(spacing: 6) {
            // Badge Icon Container
            ZStack {
                // Glow effect for earned badges
                if badge.isEarned {
                    Circle()
                        .fill(badge.badgeColor.opacity(0.4))
                        .frame(width: 90, height: 90)
                        .blur(radius: 12)
                }
                
                // Hexagon background
                BadgeHexagon()
                    .fill(
                        badge.isEarned
                            ? LinearGradient(
                                colors: [
                                    badge.badgeColor.opacity(0.8),
                                    badge.badgeColor.opacity(0.5),
                                    badge.badgeColor.opacity(0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            : LinearGradient(
                                colors: [
                                    themeService.currentTheme.surface.opacity(0.6),
                                    themeService.currentTheme.surface.opacity(0.4)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                    )
                    .frame(width: 80, height: 90)
                    .shadow(color: badge.isEarned ? badge.badgeColor.opacity(0.5) : Color.clear, radius: 8, x: 0, y: 2)
                
                // Inner hexagon
                BadgeHexagon()
                    .fill(
                        badge.isEarned
                            ? LinearGradient(
                                colors: [
                                    badge.badgeColor.opacity(0.9),
                                    badge.badgeColor.opacity(0.6)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            : LinearGradient(
                                colors: [
                                    themeService.currentTheme.surface.opacity(0.8),
                                    themeService.currentTheme.surface.opacity(0.5)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                    )
                    .frame(width: 65, height: 73)
                
                // Badge Icon
                Image(systemName: badge.iconName)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(
                        badge.isEarned
                            ? .white
                            : themeService.currentTheme.textSecondary.opacity(0.5)
                    )
                    .shadow(color: badge.isEarned ? badge.badgeColor.opacity(0.8) : Color.clear, radius: 4, x: 0, y: 0)
            }
            
            // Badge Name
            Text(badge.name)
                .font(.caption.weight(.semibold))
                .foregroundColor(themeService.currentTheme.text)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            // Badge Description
            Text(badge.badgeDescription)
                .font(.caption2)
                .foregroundColor(themeService.currentTheme.textSecondary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(height: 28)
        }
        .opacity(badge.isEarned ? 1 : 0.7)
    }
}

// MARK: - Badge Detail Popup
struct BadgeDetailPopup: View {
    let badge: Badge
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeService: ThemeService
    
    @State private var glowPulse = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Large Badge Display
                ZStack {
                    // Glow effect for earned badges (subtle pulse animation)
                    if badge.isEarned {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        badge.badgeColor.opacity(0.5),
                                        badge.badgeColor.opacity(0.2),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 40,
                                    endRadius: 100
                                )
                            )
                            .frame(width: 200, height: 200)
                            .scaleEffect(glowPulse ? 1.1 : 1.0)
                            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: glowPulse)
                            .onAppear { glowPulse = true }
                    }
                    
                    // Badge hexagon
                    BadgeHexagon()
                        .fill(
                            badge.isEarned
                                ? LinearGradient(
                                    colors: [
                                        badge.badgeColor.opacity(0.8),
                                        badge.badgeColor.opacity(0.5),
                                        badge.badgeColor.opacity(0.3)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                : LinearGradient(
                                    colors: [
                                        themeService.currentTheme.surface.opacity(0.6),
                                        themeService.currentTheme.surface.opacity(0.4)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                        )
                        .frame(width: 140, height: 160)
                        .shadow(color: badge.isEarned ? badge.badgeColor.opacity(0.6) : Color.clear, radius: 15, x: 0, y: 5)
                    
                    BadgeHexagon()
                        .fill(
                            badge.isEarned
                                ? LinearGradient(
                                    colors: [
                                        badge.badgeColor.opacity(0.9),
                                        badge.badgeColor.opacity(0.6)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                                : LinearGradient(
                                    colors: [
                                        themeService.currentTheme.surface.opacity(0.8),
                                        themeService.currentTheme.surface.opacity(0.5)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                        )
                        .frame(width: 115, height: 130)
                    
                    Image(systemName: badge.iconName)
                        .font(.system(size: 50, weight: .semibold))
                        .foregroundColor(
                            badge.isEarned
                                ? .white
                                : themeService.currentTheme.textSecondary.opacity(0.4)
                        )
                        .shadow(color: badge.isEarned ? badge.badgeColor.opacity(0.8) : Color.clear, radius: 6, x: 0, y: 0)
                }
                
                // Badge Name
                Text(badge.name)
                    .font(.title.weight(.bold))
                    .foregroundColor(themeService.currentTheme.text)
                
                // Status
                HStack(spacing: 8) {
                    Circle()
                        .fill(badge.isEarned ? Color.green : Color.red.opacity(0.6))
                        .frame(width: 10, height: 10)
                    
                    Text(badge.isEarned ? "Unlocked" : "Locked")
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(badge.isEarned ? .green : themeService.currentTheme.textSecondary)
                    
                    if badge.isEarned, let earnedDate = badge.earnedDate {
                        Text("• \(earnedDate.formatted(date: .abbreviated, time: .omitted))")
                            .font(.subheadline)
                            .foregroundColor(themeService.currentTheme.textSecondary)
                    }
                }
                
                // Requirement
                GlassCard(padding: 16) {
                    VStack(spacing: 8) {
                        Text("How to unlock")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(themeService.currentTheme.textSecondary)
                        
                        Text(badge.badgeDescription)
                            .font(.headline)
                            .foregroundColor(themeService.currentTheme.text)
                            .multilineTextAlignment(.center)
                        
                        // Progress indicator
                        if !badge.isEarned && badge.requirement > 1 {
                            VStack(spacing: 4) {
                                ProgressView(value: badge.progressPercentage)
                                    .tint(themeService.currentTheme.accent)
                                
                                Text("\(badge.progress)/\(badge.requirement)")
                                    .font(.caption)
                                    .foregroundColor(themeService.currentTheme.textSecondary)
                            }
                            .padding(.top, 8)
                        }
                    }
                }
                .padding(.horizontal)
                
                // Lore
                if !badge.lore.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Lore")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(themeService.currentTheme.textSecondary)
                        
                        Text(badge.lore)
                            .font(.subheadline)
                            .foregroundColor(themeService.currentTheme.text.opacity(0.9))
                            .italic()
                            .multilineTextAlignment(.leading)
                            .lineSpacing(4)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(themeService.currentTheme.surface.opacity(0.3))
                    )
                    .padding(.horizontal)
                }
                
                Spacer(minLength: 40)
            }
            .padding(.top, 30)
        }
        .background(themeService.currentTheme.background.ignoresSafeArea())
    }
}

// MARK: - Badge Earned Celebration Popup
struct BadgeEarnedPopup: View {
    let badge: Badge
    let onDismiss: () -> Void
    
    @EnvironmentObject var themeService: ThemeService
    @State private var animateIn = false
    @State private var showConfetti = false
    
    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissWithAnimation()
                }
            
            VStack(spacing: 20) {
                // "Badge Unlocked" text
                Text("Badge Unlocked!")
                    .font(.title2.weight(.bold))
                    .foregroundColor(.white)
                    .scaleEffect(animateIn ? 1 : 0.5)
                    .opacity(animateIn ? 1 : 0)
                
                // Large Badge
                ZStack {
                    // Badge color glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    badge.badgeColor.opacity(0.6),
                                    badge.badgeColor.opacity(0.3),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 50,
                                endRadius: 120
                            )
                        )
                        .frame(width: 240, height: 240)
                        .scaleEffect(animateIn ? 1.2 : 0.5)
                    
                    // Badge hexagon
                    BadgeHexagon()
                        .fill(
                            LinearGradient(
                                colors: [
                                    badge.badgeColor.opacity(0.9),
                                    badge.badgeColor.opacity(0.6),
                                    badge.badgeColor.opacity(0.8)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 140, height: 160)
                        .shadow(color: badge.badgeColor.opacity(0.6), radius: 20, x: 0, y: 5)
                    
                    BadgeHexagon()
                        .fill(
                            LinearGradient(
                                colors: [
                                    badge.badgeColor,
                                    badge.badgeColor.opacity(0.7)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 115, height: 130)
                    
                    Image(systemName: badge.iconName)
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: badge.badgeColor.opacity(0.8), radius: 6, x: 0, y: 0)
                }
                .scaleEffect(animateIn ? 1 : 0)
                .rotationEffect(.degrees(animateIn ? 0 : -30))
                
                // Badge Name
                Text(badge.name)
                    .font(.title.weight(.bold))
                    .foregroundColor(.white)
                    .opacity(animateIn ? 1 : 0)
                
                // Description
                Text(badge.badgeDescription)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .opacity(animateIn ? 1 : 0)
                
                // Tap to continue
                Text("Tap to continue")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.top, 20)
                    .opacity(animateIn ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.6)) {
                animateIn = true
            }
            HapticManager.shared.success()
        }
    }
    
    private func dismissWithAnimation() {
        withAnimation(.easeOut(duration: 0.2)) {
            animateIn = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            onDismiss()
        }
    }
}

// MARK: - Custom Shapes
struct BadgeShape: Shape {
    func path(in rect: CGRect) -> Path {
        let width = rect.width
        let height = rect.height
        
        var path = Path()
        
        // Octagon-like shape for badge
        let inset: CGFloat = width * 0.15
        
        path.move(to: CGPoint(x: inset, y: 0))
        path.addLine(to: CGPoint(x: width - inset, y: 0))
        path.addLine(to: CGPoint(x: width, y: inset))
        path.addLine(to: CGPoint(x: width, y: height - inset))
        path.addLine(to: CGPoint(x: width - inset, y: height))
        path.addLine(to: CGPoint(x: inset, y: height))
        path.addLine(to: CGPoint(x: 0, y: height - inset))
        path.addLine(to: CGPoint(x: 0, y: inset))
        path.closeSubpath()
        
        return path
    }
}

struct BadgeHexagon: Shape {
    func path(in rect: CGRect) -> Path {
        let width = rect.width
        let height = rect.height
        
        var path = Path()
        
        // Hexagon shape
        let sideInset = width * 0.1
        let topBottomHeight = height * 0.2
        
        path.move(to: CGPoint(x: width / 2, y: 0))
        path.addLine(to: CGPoint(x: width - sideInset, y: topBottomHeight))
        path.addLine(to: CGPoint(x: width - sideInset, y: height - topBottomHeight))
        path.addLine(to: CGPoint(x: width / 2, y: height))
        path.addLine(to: CGPoint(x: sideInset, y: height - topBottomHeight))
        path.addLine(to: CGPoint(x: sideInset, y: topBottomHeight))
        path.closeSubpath()
        
        return path
    }
}

#Preview {
    MilestonesView()
        .environmentObject(ThemeService.shared)
}

