//
//  HomeView.swift
//  benk
//
//  Created on 2025-12-11
//

import SwiftUI
import SwiftData

// Simple static storage that persists across tab switches but resets on app restart
enum HomeState {
    static var currentWidgetPage = 0
}

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var themeService: ThemeService
    
    @Query(filter: #Predicate<StudySession> { $0.isCompleted }, sort: \StudySession.timestamp, order: .reverse)
    private var completedSessions: [StudySession]
    @Query(sort: \BreakSession.timestamp, order: .reverse) 
    private var breakSessions: [BreakSession]
    @Query private var userProfiles: [UserProfile]
    @Query private var tasks: [Task]
    @Query private var subjects: [Subject]
    @Query private var badges: [Badge]
    
    @State private var selectedDate = Calendar.current.startOfDay(for: Date())
    @State private var currentWidgetPage = HomeState.currentWidgetPage
    @State private var showTitleDropdown = false
    @State private var showRecentActivity = false
    @State private var localWidgetOrder: [Int] = [0, 1, 2]

    @State private var currentScrollOffset: CGFloat = 0
    @State private var visibleWidgetIndex: Int = 0
    
    // Cached computed values
    @State private var cachedSubjectHours: [(subject: Subject, hours: Double)] = []
    @State private var lastSessionCount: Int = 0
    @State private var lastSubjectCount: Int = 0
    
    // Recent activity items
    struct ActivityItem: Identifiable {
        let id: UUID
        let timestamp: Date
        let content: Content
        
        enum Content {
            case study(StudySession)
            case breakSession(BreakSession)
        }
    }
    
    var recentActivities: [ActivityItem] {
        let studyItems = completedSessions.prefix(20).map {
            ActivityItem(id: $0.id, timestamp: $0.timestamp, content: .study($0))
        }
        let breakItems = breakSessions.prefix(10).map {
            ActivityItem(id: $0.id, timestamp: $0.timestamp, content: .breakSession($0))
        }
        return (studyItems + breakItems).sorted { $0.timestamp > $1.timestamp }.prefix(15).map { $0 }
    }
    
    var userProfile: UserProfile {
        userProfiles.first ?? UserProfile()
    }
    
    /// Get the user's selected title badge if one is equipped
    var selectedTitleBadge: Badge? {
        guard let badgeId = userProfile.selectedTitleBadgeId else { return nil }
        return badges.first { $0.id == badgeId && $0.isEarned }
    }
    
    /// Get all earned badges for title selection
    var earnedBadges: [Badge] {
        badges.filter { $0.isEarned }.sorted { $0.sortOrder < $1.sortOrder }
    }
    
    // Pre-computed session lookup by day for O(1) access
    private var sessionsByDay: [Date: [StudySession]] {
        Dictionary(grouping: completedSessions) { session in
            Calendar.current.startOfDay(for: session.timestamp)
        }
    }
    
    private func minutes(for date: Date) -> Int {
        let dayStart = Calendar.current.startOfDay(for: date)
        let daySessions = sessionsByDay[dayStart] ?? []
        return daySessions.reduce(0) { $0 + ($1.duration / 60) }
    }
    
    var todayMinutes: Int {
        minutes(for: Date())
    }
    
    var selectedDayMinutes: Int {
        minutes(for: selectedDate)
    }
    
    var selectedDateLabel: String {
        selectedDate.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day())
    }
    
    private func formattedHoursAndMinutes(_ minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        if hours > 0 {
            return mins > 0 ? "\(hours)h \(mins)m" : "\(hours)h"
        }
        return "\(mins)m"
    }
    
    var todayTasksCompleted: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) ?? today
        
        return tasks.filter { task in
            guard task.isCompleted else { return false }
            guard let completedAt = task.completedAt else { return false }
            return completedAt >= today && completedAt < tomorrow
        }.count
    }
    
    var recentTask: Task? {
        tasks.filter { !$0.isCompleted }
            .sorted { $0.createdAt > $1.createdAt }
            .first
    }
    
    var recentTasks: [Task] {
        tasks.filter { !$0.isCompleted }
            .sorted { $0.createdAt > $1.createdAt }
            .prefix(3)
            .map { $0 }
    }
    
    // Recalculate subject hours only when data changes
    private func recalculateSubjectHours() {
        var subjectMap: [UUID: Double] = [:]
        
        for session in completedSessions {
            if let subjectId = session.subjectId {
                let hours = Double(session.duration) / 3600.0
                subjectMap[subjectId, default: 0] += hours
            }
        }
        
        cachedSubjectHours = subjects.compactMap { subject in
            guard let hours = subjectMap[subject.id], hours > 0 else { return nil }
            return (subject, hours)
        }.sorted { $0.hours > $1.hours }
    }
    
    var body: some View {
        ZStack {
            ThemedBackground(theme: themeService.currentTheme)
            
            ScrollViewReader { scrollProxy in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        // Invisible anchor at the top
                        Color.clear
                            .frame(height: 1)
                            .id("top")
                        
                        // Header
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                            Text("Welcome back,")
                                .font(.caption)
                                .foregroundColor(themeService.currentTheme.textSecondary)
                            
                            HStack(spacing: 8) {
                                Text(userProfile.username.count > 10 ? String(userProfile.username.prefix(10)) + "..." : userProfile.username)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(themeService.currentTheme.text)
                                    .lineLimit(1)
                                
                                // Title dropdown trigger
                                TitleDropdownTrigger(
                                    selectedBadge: selectedTitleBadge,
                                    earnedBadges: earnedBadges,
                                    isExpanded: $showTitleDropdown,
                                    onSelect: { badgeId in
                                        userProfile.selectedTitleBadgeId = badgeId
                                        try? modelContext.save()
                                        HapticManager.shared.selection()
                                    }
                                )
                            }
                            
                            // Tier/Rank with level color
                            Text(LevelTier.name(for: userProfile.level))
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(LevelTier.color(for: userProfile.level))
                        }
                            
                            Spacer()
                            
                            // Small Streak Widget - Navigate to Milestones
                            NavigationLink(destination: MilestonesView()) {
                                HStack(spacing: 4) {
                                    if StreakMilestone.isRainbow(for: userProfile.currentStreak) {
                                        // Rainbow animated gradient for 1000+ streak
                                        Image(systemName: "flame.fill")
                                            .font(.system(size: 14))
                                            .foregroundStyle(
                                                LinearGradient(
                                                    colors: StreakMilestone.rainbowColors,
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                        
                                        Text("\(userProfile.currentStreak)")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundStyle(
                                                LinearGradient(
                                                    colors: StreakMilestone.rainbowColors,
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                    } else {
                                        Image(systemName: "flame.fill")
                                            .foregroundColor(StreakMilestone.color(for: userProfile.currentStreak))
                                            .font(.system(size: 14))
                                        
                                        Text("\(userProfile.currentStreak)")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(StreakMilestone.color(for: userProfile.currentStreak))
                                    }
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(StreakMilestone.color(for: userProfile.currentStreak).opacity(0.15))
                                )
                            }
                            
                            // Calendar Button (Top Right)
                            NavigationLink(destination: CalendarView()) {
                                ZStack {
                                    Circle()
                                        .fill(Color.orange.opacity(0.3))
                                        .frame(width: 40, height: 40)
                                    
                                    Image(systemName: "calendar.circle.fill")
                                        .foregroundColor(.orange)
                                        .font(.system(size: 22))
                                }
                            }
                            
                            // Tasks Button (Top Right)
                            NavigationLink(destination: TasksView()) {
                                ZStack {
                                    Circle()
                                        .fill(themeService.currentTheme.primary.opacity(0.3))
                                        .frame(width: 40, height: 40)
                                    
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(themeService.currentTheme.primary)
                                        .font(.system(size: 22))
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        .background(
                            GeometryReader { geometry in
                                Color.clear
                                    .preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .named("scroll")).minY)
                            }
                        )
                    }
                    
                    // Calendar Bar
                    CalendarBar(selectedDate: $selectedDate)
                        .padding(.horizontal)
                    
                     // Widget slider with iOS-style drag reordering, page dots, and stopwatch
                    VStack(spacing: 0) {
                        // Horizontal Widget Stack with Drag Reordering
                        HorizontalWidgetReorderView(
                            widgetOrder: $localWidgetOrder,
                            widgetCount: 5,
                            visibleWidgetIndex: $visibleWidgetIndex,
                            onOrderChanged: {
                                // Persist widget order to UserProfile
                                userProfile.widgetOrder = localWidgetOrder
                                try? modelContext.save()
                            }
                        ) { widgetIndex in
                            widgetView(for: widgetIndex)
                                .frame(height: 180)
                        }
                        
                        // Stopwatch Timer
                        StopwatchTimer()
                            .padding(.horizontal, 24)
                    }
                    
                    // Scroll indicator hint
                    VStack(spacing: 4) {
                        Text(showRecentActivity ? "Pull down to close" : "Pull up for recent activity")
                            .font(.caption2)
                            .foregroundColor(themeService.currentTheme.textSecondary.opacity(0.5))
                        Image(systemName: showRecentActivity ? "chevron.down" : "chevron.up")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(themeService.currentTheme.textSecondary.opacity(0.5))
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 16)
                    .frame(maxWidth: .infinity)
                    .opacity(0.7)
                    
                    // Recent Activity Section (always in scroll, visibility controlled by state)
                    if showRecentActivity {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Recent Activity")
                                    .font(.headline)
                                    .foregroundColor(themeService.currentTheme.text)
                                
                                Spacer()
                            }
                            .padding(.horizontal)
                            
                            if recentActivities.isEmpty {
                                HStack {
                                    Spacer()
                                    VStack(spacing: 8) {
                                        Image(systemName: "clock.arrow.circlepath")
                                            .font(.largeTitle)
                                            .foregroundColor(themeService.currentTheme.textSecondary.opacity(0.5))
                                        Text("No recent activity")
                                            .font(.subheadline)
                                            .foregroundColor(themeService.currentTheme.textSecondary)
                                    }
                                    .padding(.vertical, 30)
                                    Spacer()
                                }
                            } else {
                                ForEach(recentActivities) { item in
                                    switch item.content {
                                    case .study(let session):
                                        SessionHistoryRow(session: session)
                                    case .breakSession(let session):
                                        BreakHistoryRow(breakSession: session)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.top, 8)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                    
                    Spacer(minLength: 100)
                }
                .scrollBounceBehavior(.basedOnSize)
                .onScrollGeometryChange(for: CGFloat.self) { geo in
                    // Track how far past the natural scroll bounds the user has scrolled
                    let maxScrollOffset = max(0, geo.contentSize.height - geo.containerSize.height)
                    return geo.contentOffset.y - maxScrollOffset
                } action: { oldOverscroll, overscroll in
                    // Reveal when user reaches the bottom (overscroll >= 0 means at or past bottom)
                    if overscroll >= 0 && oldOverscroll < 0 && !showRecentActivity {
                        withAnimation(.easeOut(duration: 0.15)) {
                            showRecentActivity = true
                        }
                        HapticManager.shared.medium()
                    }
                }
                .onScrollGeometryChange(for: Bool.self) { geo in
                    // Track if user is at the very top
                    geo.contentOffset.y <= 5
                } action: { wasAtTop, isAtTop in
                    // Close when user scrolls back to top
                    if isAtTop && !wasAtTop && showRecentActivity {
                        withAnimation(.easeOut(duration: 0.15)) {
                            showRecentActivity = false
                        }
                        HapticManager.shared.selection()
                    }
                }
                .coordinateSpace(name: "scroll")
            }
        .onAppear {
            // Load saved widget order (now includes 5 widgets)
            // If user has old order with only 3 widgets, add the new ones
            if userProfile.widgetOrder.isEmpty {
                localWidgetOrder = [0, 1, 2, 3, 4]
            } else if userProfile.widgetOrder.count < 5 {
                // Existing user with old order - add missing widgets
                var updatedOrder = userProfile.widgetOrder
                let existingWidgets = Set(updatedOrder)
                for widget in 0..<5 {
                    if !existingWidgets.contains(widget) {
                        updatedOrder.append(widget)
                    }
                }
                localWidgetOrder = updatedOrder
                userProfile.widgetOrder = updatedOrder
                try? modelContext.save()
            } else {
                localWidgetOrder = userProfile.widgetOrder
            }
            
            // Sync widget page from static state
            currentWidgetPage = HomeState.currentWidgetPage
            
            recalculateSubjectHours()
            lastSessionCount = completedSessions.count
            lastSubjectCount = subjects.count
        }
        .onChange(of: completedSessions.count) { _, newCount in
            if newCount != lastSessionCount {
                lastSessionCount = newCount
                recalculateSubjectHours()
            }
        }
        .onChange(of: subjects.count) { _, newCount in
            if newCount != lastSubjectCount {
                lastSubjectCount = newCount
                recalculateSubjectHours()
            }
        }
        .onChange(of: currentWidgetPage) { _, newPage in
            // Sync to static state for persistence
            HomeState.currentWidgetPage = newPage
        }
        }  // Close ZStack
    }
    

    
    // MARK: - Widget View Builder
    @ViewBuilder
    private func widgetView(for index: Int) -> some View {
        let isVisible = localWidgetOrder.indices.contains(visibleWidgetIndex) && localWidgetOrder[visibleWidgetIndex] == index
        
        switch index {
        case 0:
            // Page 1: Daily Goal & XP
            HStack(spacing: 12) {
                DailyGoalWidget(
                    dayMinutes: selectedDayMinutes,
                    goalMinutes: max(1, userProfile.dailyGoalMinutes),
                    isVisible: isVisible
                )
                
                XPLevelWidget(
                    currentXP: userProfile.xp,
                    currentLevel: userProfile.level,
                    nextLevelXP: userProfile.xpForNextLevel,
                    currentLevelXP: userProfile.xpForCurrentLevel,
                    isVisible: isVisible
                )
            }
            .frame(height: 180)
            .padding(.horizontal, 16)
            
        case 1:
            // Page 2: Subject Hours Pie Chart
            SubjectPieChartCard(
                subjectHours: cachedSubjectHours,
                isVisible: isVisible
            )
                .frame(height: 180)
                .padding(.horizontal, 16)
            
        case 2:
            // Page 3: Recent Tasks & Completed Today
            TaskStatsCard(
                recentTasks: recentTasks,
                todayTasksCompleted: todayTasksCompleted,
                modelContext: modelContext
            )
            .frame(height: 180)
            .padding(.horizontal, 16)
            
        case 3:
            // Page 4: Upcoming Exams
            ExamReminderWidget(isVisible: isVisible)
                .frame(height: 180)
                .padding(.horizontal, 16)
            
        case 4:
            // Page 5: Upcoming Assignments
            AssignmentReminderWidget(isVisible: isVisible)
                .frame(height: 180)
                .padding(.horizontal, 16)
            
        default:
            EmptyView()
        }
    }
}

// MARK: - Subject Pie Chart Card with Animation Lifecycle Management
struct SubjectPieChartCard: View {
    let subjectHours: [(subject: Subject, hours: Double)]
    let isVisible: Bool
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject var themeService: ThemeService
    
    @State private var animationProgress: CGFloat = 0
    @State private var showContent = false
    @State private var isAnimating = false
    @State private var rotationAngle: Double = 0
    
    var totalHours: Double {
        subjectHours.reduce(0) { $0 + $1.hours }
    }
    
    var displayedSubjects: [(subject: Subject, hours: Double)] {
        Array(subjectHours.prefix(3))
    }
    
    var body: some View {
        GlassCard(padding: 12) {
            VStack(spacing: 16) {
                titleView
                
                if subjectHours.isEmpty {
                    emptyStateView
                } else {
                    contentView
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            if isVisible {
                startAnimations()
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            // Only restart animations when coming back to active, don't stop them
            // This prevents "flashing" when switching apps
            if newPhase == .active && isVisible {
                // Slight delay to allow reset to take effect visually if needed
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    startAnimations()
                }
            }
        }
        .onChange(of: isVisible) { _, visible in
            if visible {
                stopAnimations()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    startAnimations()
                }
            } else {
                stopAnimations()
            }
        }
    }
    
    private func startAnimations() {
        guard !isAnimating else { return }
        isAnimating = true
        showContent = true
        
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
            animationProgress = 1
        }
    }
    
    private func stopAnimations() {
        // Fully reset animation state
        isAnimating = false
        withAnimation(.none) {
            animationProgress = 0
            showContent = false
            rotationAngle = 0
        }
    }
    
    private var titleView: some View {
        Text("Study Time by Subject")
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(themeService.currentTheme.text)
            .opacity(showContent ? 1.0 : 0.0)
            .animation(.easeOut(duration: 0.4).delay(0.1), value: showContent)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 6) {
            Image(systemName: "chart.pie")
                .font(.system(size: 32))
                .foregroundColor(themeService.currentTheme.textSecondary.opacity(0.4))
            Text("No study data yet")
                .font(.caption)
                .foregroundColor(themeService.currentTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .opacity(showContent ? 1.0 : 0.0)
        .scaleEffect(showContent ? 1.0 : 0.8)
        .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.2), value: showContent)
    }
    
    private var contentView: some View {
        HStack(spacing: 20) {
            pieChartView
            legendView
        }
    }
    
    private var pieChartView: some View {
        ZStack {
            glowBackground
            pieSlices
            glassShine
        }
        .frame(width: 80, height: 80)
    }
    
    private var glowBackground: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        themeService.currentTheme.accent.opacity(0.2),
                        themeService.currentTheme.primary.opacity(0.1),
                        Color.clear
                    ],
                    center: .center,
                    startRadius: 20.0,
                    endRadius: 50.0
                )
            )
            .frame(width: 100, height: 100)
            .blur(radius: 8)
            .opacity(showContent ? 0.8 : 0.0)
            .scaleEffect(showContent ? 1.0 : 0.5)
    }
    
    private var pieSlices: some View {
        ForEach(Array(subjectHours.enumerated()), id: \.element.subject.id) { index, item in
            AnimatedPieSlice(
                startAngle: startAngle(for: index),
                endAngle: endAngle(for: index),
                color: item.subject.color,
                animationProgress: animationProgress,
                delay: Double(index) * 0.1
            )
            .shadow(color: item.subject.color.opacity(0.3), radius: 3.0, x: 0.0, y: 1.0)
        }
    }
    
    private var glassShine: some View {
        Circle()
            .fill(
                AngularGradient(
                    colors: [
                        Color.white.opacity(0.3),
                        Color.clear,
                        Color.clear,
                        Color.white.opacity(0.15)
                    ],
                    center: .center,
                    angle: .degrees(rotationAngle)
                )
            )
            .frame(width: 80, height: 80)
            .blendMode(.overlay)
            .opacity(showContent ? 1.0 : 0.0)
    }
    
    private var legendView: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(Array(displayedSubjects.enumerated()), id: \.element.subject.id) { index, item in
                legendItem(for: item, at: index)
            }
            
            if subjectHours.count > 3 {
                moreText
            }
        }
    }
    
    private func legendItem(for item: (subject: Subject, hours: Double), at index: Int) -> some View {
        HStack(spacing: 10) {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            item.subject.color.opacity(0.8),
                            item.subject.color
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 10, height: 10)
                .shadow(color: item.subject.color.opacity(0.5), radius: 3.0, x: 0.0, y: 1.0)
                .scaleEffect(showContent ? 1.0 : 0.0)
            
            VStack(alignment: .leading, spacing: 1) {
                Text(item.subject.name)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(themeService.currentTheme.text)
                    .lineLimit(1)
                Text(String(format: "%.1fh", item.hours))
                    .font(.system(size: 10))
                    .foregroundColor(themeService.currentTheme.textSecondary)
            }
        }
        .opacity(showContent ? 1.0 : 0.0)
        .offset(x: showContent ? 0.0 : -20.0)
        .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.3 + Double(index) * 0.12), value: showContent)
    }
    
    private var moreText: some View {
        Text("+ \(subjectHours.count - 3) more")
            .font(.system(size: 10))
            .foregroundColor(themeService.currentTheme.textSecondary.opacity(0.7))
            .padding(.top, 2)
            .opacity(showContent ? 1.0 : 0.0)
            .animation(.easeOut(duration: 0.3).delay(0.8), value: showContent)
    }
    
    private func startAngle(for index: Int) -> Angle {
        let previousHours = subjectHours.prefix(index).reduce(0) { $0 + $1.hours }
        let ratio = previousHours / totalHours
        return .degrees(ratio * 360 - 90)
    }
    
    private func endAngle(for index: Int) -> Angle {
        let previousHours = subjectHours.prefix(index + 1).reduce(0) { $0 + $1.hours }
        let ratio = previousHours / totalHours
        return .degrees(ratio * 360 - 90)
    }
}

// MARK: - Pie Slice Shape
struct PieSlice: View {
    let startAngle: Angle
    let endAngle: Angle
    let color: Color
    
    var body: some View {
        PieSliceShape(startAngle: startAngle, endAngle: endAngle)
            .fill(color)
    }
}

struct AnimatedPieSlice: View {
    let startAngle: Angle
    let endAngle: Angle
    let color: Color
    let animationProgress: CGFloat
    let delay: Double
    
    @State private var localProgress: CGFloat = 0
    
    var body: some View {
        PieSliceShape(
            startAngle: startAngle,
            endAngle: .degrees(
                startAngle.degrees + (endAngle.degrees - startAngle.degrees) * localProgress
            )
        )
        .fill(
            LinearGradient(
                colors: [
                    color.opacity(0.9),
                    color
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .onChange(of: animationProgress) { _, newValue in
            withAnimation(.spring(response: 0.7, dampingFraction: 0.65).delay(delay)) {
                localProgress = newValue
            }
        }
    }
}

struct PieSliceShape: Shape {
    let startAngle: Angle
    let endAngle: Angle
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        path.move(to: center)
        path.addArc(
            center: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )
        path.closeSubpath()
        
        return path
    }
}

// MARK: - Task Stats Card - Fixed layout with subject tags on right
struct TaskStatsCard: View {
    let recentTasks: [Task]
    let todayTasksCompleted: Int
    let modelContext: ModelContext
    @EnvironmentObject var themeService: ThemeService
    @Query private var subjects: [Subject]
    @Query private var allTasks: [Task]
    
    private var completedTasksCount: Int {
        allTasks.filter { $0.isCompleted }.count
    }
    
    private func subject(for task: Task) -> Subject? {
        guard let subjectId = task.subjectId else { return nil }
        return subjects.first { $0.id == subjectId }
    }
    
    var body: some View {
        GlassCard(padding: 12) {
            HStack(alignment: .top, spacing: 10) {
                // Recent Tasks Section
                VStack(alignment: .leading, spacing: 6) {
                    Text("Recent Tasks")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(themeService.currentTheme.textSecondary)
                        .textCase(.uppercase)
                    
                    if recentTasks.isEmpty {
                        Text("No active tasks")
                            .font(.caption)
                            .italic()
                            .foregroundColor(themeService.currentTheme.text.opacity(0.6))
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    } else {
                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(recentTasks) { task in
                                TaskRowItem(
                                    task: task,
                                    subject: subject(for: task),
                                    modelContext: modelContext,
                                    completedTasksCount: completedTasksCount
                                )
                            }
                            
                            Spacer(minLength: 0)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
                
                // Divider
                Rectangle()
                    .fill(themeService.currentTheme.textSecondary.opacity(0.2))
                    .frame(width: 1)
                
                // Today's Progress Section
                VStack(alignment: .center, spacing: 4) {
                    Text("Done\nToday")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(themeService.currentTheme.textSecondary)
                        .textCase(.uppercase)
                        .multilineTextAlignment(.center)
                    
                    VStack(spacing: 2) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 20))
                        Text("\(todayTasksCompleted)")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(themeService.currentTheme.text)
                    }
                }
                .frame(width: 60)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
}

// MARK: - Task Row Item with subject tag on right
struct TaskRowItem: View {
    let task: Task
    let subject: Subject?
    let modelContext: ModelContext
    let completedTasksCount: Int
    @EnvironmentObject var themeService: ThemeService
    @EnvironmentObject var badgeService: BadgeService
    
    var body: some View {
        HStack(spacing: 6) {
            // Checkbox
            Button(action: {
                toggleTask()
            }) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.isCompleted ? .green : themeService.currentTheme.textSecondary)
                    .font(.system(size: 14))
            }
            .buttonStyle(.plain)
            
            // Task title
            Text(task.title)
                .font(.system(size: 11))
                .foregroundColor(themeService.currentTheme.text)
                .lineLimit(1)
            
            Spacer(minLength: 4)
            
            // Subject tag on the right with highlight
            if let subject = subject {
                Text(subject.name)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(subject.color)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(subject.color.opacity(0.2))
                    )
                    .lineLimit(1)
            }
        }
        .frame(height: 22)
    }
    
    private func toggleTask() {
        if task.isCompleted {
            // Untick
            task.completedAt = nil
            task.isCompleted = false
        } else {
            // Tick - mark as completed and log to analytics
            task.completedAt = Date()
            task.isCompleted = true
            
            // Log completion in analytics (no XP for tasks)
            let session = StudySession(
                duration: 0,
                xpEarned: 0,
                timestamp: Date(),
                subjectId: task.subjectId,
                isCompleted: true
            )
            modelContext.insert(session)
            
            // Check task completion badges
            let newCompletedCount = completedTasksCount + 1
            badgeService.checkTaskBadges(completedTasks: newCompletedCount, context: modelContext)
            
            // Force check any badges that might have progress >= requirement
            badgeService.forceCheckAllBadges(context: modelContext)
        }
        
        try? modelContext.save()
        HapticManager.shared.selection()
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        GlassCard {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
    }
}

// MARK: - Scroll Offset Preference Key
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [UserProfile.self, StudySession.self, Task.self, Subject.self])
        .environmentObject(ThemeService.shared)
        .environmentObject(TimerService.shared)
}
