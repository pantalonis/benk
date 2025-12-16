//
//  BadgeService.swift
//  benk
//
//  Created on 2025-12-14
//

import Foundation
import SwiftUI
import SwiftData

@MainActor
class BadgeService: ObservableObject {
    static let shared = BadgeService()
    
    @Published var newlyEarnedBadge: Badge?
    @Published var showBadgeEarnedPopup = false
    
    // Queue for multiple badges
    private var badgeQueue: [Badge] = []
    private var isShowingPopup = false
    
    // Track badges already shown this session to avoid duplicates
    private var shownBadgeIds: Set<UUID> = []
    
    // Flag to prevent multiple initial checks
    private var hasCheckedOnLoad = false
    
    private init() {}
    
    // MARK: - Badge Queue Management
    
    /// Add a badge to the queue and show if not already showing
    private func queueBadge(_ badge: Badge) {
        // Don't queue if already shown this session
        guard !shownBadgeIds.contains(badge.id) else { return }
        
        // Don't queue if already in queue
        guard !badgeQueue.contains(where: { $0.id == badge.id }) else { return }
        
        badgeQueue.append(badge)
        showNextBadgeIfNeeded()
    }
    
    /// Show the next badge in queue
    private func showNextBadgeIfNeeded() {
        guard !isShowingPopup, let nextBadge = badgeQueue.first else { return }
        
        badgeQueue.removeFirst()
        shownBadgeIds.insert(nextBadge.id) // Mark as shown this session
        isShowingPopup = true
        newlyEarnedBadge = nextBadge
        showBadgeEarnedPopup = true
    }
    
    /// Dismiss the badge earned popup and show next if any
    func dismissBadgePopup() {
        showBadgeEarnedPopup = false
        newlyEarnedBadge = nil
        isShowingPopup = false
        
        // Show next badge after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.showNextBadgeIfNeeded()
        }
    }
    
    /// Reset tracking for a fresh check (call after reinitializing badges)
    func resetTracking() {
        shownBadgeIds.removeAll()
        badgeQueue.removeAll()
        hasCheckedOnLoad = false
    }
    
    /// Public method to queue a badge for popup display
    func queueBadgeForPopup(_ badge: Badge) {
        queueBadge(badge)
    }
    
    /// Force check all badges and unlock any that meet requirements but aren't earned
    func forceCheckAllBadges(context: ModelContext) {
        let descriptor = FetchDescriptor<Badge>(predicate: #Predicate { badge in
            !badge.isEarned
        })
        
        guard let badges = try? context.fetch(descriptor) else { return }
        
        for badge in badges {
            if badge.progress >= badge.requirement {
                badge.isEarned = true
                badge.earnedDate = Date()
                try? context.save()
                queueBadge(badge)
            }
        }
    }
    
    // MARK: - Comprehensive Badge Check (call on app load)
    
    /// Check all badges based on current data - call this on app load
    func checkAllBadgesOnLoad(context: ModelContext, force: Bool = false) {
        // Only run once per session unless forced
        guard !hasCheckedOnLoad || force else { return }
        hasCheckedOnLoad = true
        
        // Fetch all required data
        let userDescriptor = FetchDescriptor<UserProfile>()
        guard let userProfiles = try? context.fetch(userDescriptor),
              let userProfile = userProfiles.first else { return }
        
        let sessionDescriptor = FetchDescriptor<StudySession>(predicate: #Predicate { $0.isCompleted })
        let completedSessions = (try? context.fetch(sessionDescriptor)) ?? []
        
        let taskDescriptor = FetchDescriptor<Task>()
        let tasks = (try? context.fetch(taskDescriptor)) ?? []
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Calculate all stats
        let currentStreak = userProfile.currentStreak
        let totalMinutes = completedSessions.reduce(0) { $0 + ($1.duration / 60) }
        let completedTasksCount = tasks.filter { $0.isCompleted }.count
        
        // Techniques
        let usedTechniqueIds = Set(completedSessions.compactMap { $0.techniqueId })
        let uniqueTechniquesCount = usedTechniqueIds.count
        
        let todaySessions = completedSessions.filter { calendar.isDate($0.timestamp, inSameDayAs: today) }
        let techniquesUsedToday = Set(todaySessions.compactMap { $0.techniqueId }).count
        let subjectsStudiedToday = Set(todaySessions.compactMap { $0.subjectId }).count
        
        // Late night / early morning sessions
        let lateNightSessions = completedSessions.filter { session in
            let hour = calendar.component(.hour, from: session.timestamp)
            return hour >= 22
        }
        
        let afterMidnightSessions = completedSessions.filter { session in
            let hour = calendar.component(.hour, from: session.timestamp)
            return hour >= 0 && hour < 5
        }
        
        let earlyBirdSessions = completedSessions.filter { session in
            let hour = calendar.component(.hour, from: session.timestamp)
            return hour >= 4 && hour < 6
        }
        
        // Weekend sessions
        let saturdaySessions = completedSessions.filter { calendar.component(.weekday, from: $0.timestamp) == 7 }
        let sundaySessions = completedSessions.filter { calendar.component(.weekday, from: $0.timestamp) == 1 }
        let weekendProgress = (saturdaySessions.isEmpty ? 0 : 1) + (sundaySessions.isEmpty ? 0 : 1)
        
        // Marathon sessions
        let marathonSessions = completedSessions.filter { $0.duration >= 240 * 60 }
        
        // Christmas sessions
        let christmasSessions = completedSessions.filter { session in
            let components = calendar.dateComponents([.month, .day], from: session.timestamp)
            return components.month == 12 && components.day == 25
        }
        let christmasMinutes = christmasSessions.reduce(0) { $0 + ($1.duration / 60) }
        
        // Calculate days where daily goal was actually met
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
        
        // Check all badge categories
        checkStreakBadges(streak: currentStreak, context: context)
        checkDailyGoalBadges(consecutiveDaysHitGoal: daysGoalMet, context: context)
        checkTimeSpentBadges(totalMinutes: totalMinutes, context: context)
        checkTaskBadges(completedTasks: completedTasksCount, context: context)
        checkTechniqueBadges(uniqueTechniquesUsed: uniqueTechniquesCount, techniquesInOneDay: techniquesUsedToday, context: context)
        
        // Special badges
        if !afterMidnightSessions.isEmpty {
            checkSpecialBadgeQuietly(badgeName: "Gremlin", context: context)
        }
        if !earlyBirdSessions.isEmpty {
            checkSpecialBadgeQuietly(badgeName: "Early Bird", context: context)
        }
        if weekendProgress >= 2 {
            checkSpecialBadgeQuietly(badgeName: "Weekend Warrior", context: context)
        }
        if !marathonSessions.isEmpty {
            checkSpecialBadgeQuietly(badgeName: "Marathon Runner", context: context)
        }
        if currentStreak >= 7 {
            checkSpecialBadgeQuietly(badgeName: "Perfect Week", context: context)
        }
        if lateNightSessions.count >= 10 {
            checkSpecialBadgeQuietly(badgeName: "Night Owl", context: context)
        }
        if subjectsStudiedToday >= 5 {
            checkSpecialBadgeQuietly(badgeName: "Subject Hopper", context: context)
        }
        if christmasMinutes >= 402 {
            checkSpecialBadgeQuietly(badgeName: "Holiday Hero", context: context)
        }
        
        // Check Comeback Kid (7+ day gap between sessions)
        if completedSessions.count >= 2 {
            let sortedSessions = completedSessions.sorted { $0.timestamp > $1.timestamp }
            for i in 0..<(sortedSessions.count - 1) {
                let currentSession = sortedSessions[i]
                let previousSession = sortedSessions[i + 1]
                let daysBetween = calendar.dateComponents([.day], from: previousSession.timestamp, to: currentSession.timestamp).day ?? 0
                if daysBetween >= 7 {
                    checkSpecialBadgeQuietly(badgeName: "Comeback Kid", context: context)
                    break
                }
            }
        }
        
        // Update longest streak if needed
        if userProfile.longestStreak < currentStreak {
            userProfile.longestStreak = currentStreak
            try? context.save()
        }
    }
    
    /// Check special badge and queue if earned (without immediately showing)
    private func checkSpecialBadgeQuietly(badgeName: String, context: ModelContext) {
        let descriptor = FetchDescriptor<Badge>(predicate: #Predicate { badge in
            badge.name == badgeName && !badge.isEarned
        })
        
        guard let badges = try? context.fetch(descriptor),
              let badge = badges.first else { return }
        
        badge.isEarned = true
        badge.earnedDate = Date()
        badge.progress = badge.requirement
        
        try? context.save()
        
        // Queue the badge
        queueBadge(badge)
    }
    
    // MARK: - Badge Checking Functions
    
    /// Check and award streak badges based on current streak
    func checkStreakBadges(streak: Int, context: ModelContext) {
        let streakThresholds = [3, 10, 50, 100, 365, 1000]
        
        for threshold in streakThresholds {
            if streak >= threshold {
                awardBadgeIfNotEarned(category: .streak, requirement: threshold, progress: streak, context: context)
            }
        }
        
        // Update progress for all streak badges
        updateBadgeProgress(category: .streak, progress: streak, context: context)
    }
    
    /// Check and award daily goal badges
    func checkDailyGoalBadges(consecutiveDaysHitGoal: Int, context: ModelContext) {
        let goalThresholds = [1, 7, 30, 100]
        
        for threshold in goalThresholds {
            if consecutiveDaysHitGoal >= threshold {
                awardBadgeIfNotEarned(category: .dailyGoal, requirement: threshold, progress: consecutiveDaysHitGoal, context: context)
            }
        }
        
        updateBadgeProgress(category: .dailyGoal, progress: consecutiveDaysHitGoal, context: context)
    }
    
    /// Check and award technique badges
    func checkTechniqueBadges(uniqueTechniquesUsed: Int, techniquesInOneDay: Int, context: ModelContext) {
        // Method Actor - 3 techniques in one day
        if techniquesInOneDay >= 3 {
            awardBadgeIfNotEarned(category: .technique, requirement: 3, progress: techniquesInOneDay, context: context)
        }
        
        // Discovery badges
        let discoveryThresholds = [10, 25, 50, 100]
        for threshold in discoveryThresholds {
            if uniqueTechniquesUsed >= threshold {
                awardBadgeIfNotEarned(category: .technique, requirement: threshold, progress: uniqueTechniquesUsed, context: context)
            }
        }
        
        // Update progress - use max of unique techniques for discovery badges
        updateBadgeProgress(category: .technique, progress: uniqueTechniquesUsed, context: context)
    }
    
    /// Check and award time spent badges
    func checkTimeSpentBadges(totalMinutes: Int, context: ModelContext) {
        let timeThresholds = [60, 600, 1440, 10080, 30000] // 1hr, 10hr, 24hr, 168hr, 500hr
        
        for threshold in timeThresholds {
            if totalMinutes >= threshold {
                awardBadgeIfNotEarned(category: .timeSpent, requirement: threshold, progress: totalMinutes, context: context)
            }
        }
        
        updateBadgeProgress(category: .timeSpent, progress: totalMinutes, context: context)
    }
    
    /// Check and award task completion badges
    func checkTaskBadges(completedTasks: Int, context: ModelContext) {
        let taskThresholds = [10, 50, 100, 500]
        
        for threshold in taskThresholds {
            if completedTasks >= threshold {
                awardBadgeIfNotEarned(category: .taskCompletion, requirement: threshold, progress: completedTasks, context: context)
            }
        }
        
        updateBadgeProgress(category: .taskCompletion, progress: completedTasks, context: context)
    }
    
    /// Check special badges (Gremlin, Early Bird, etc.)
    func checkSpecialBadge(badgeName: String, context: ModelContext) {
        let descriptor = FetchDescriptor<Badge>(predicate: #Predicate { badge in
            badge.name == badgeName && !badge.isEarned
        })
        
        guard let badges = try? context.fetch(descriptor),
              let badge = badges.first else { return }
        
        badge.isEarned = true
        badge.earnedDate = Date()
        badge.progress = badge.requirement
        
        try? context.save()
        
        // Queue the badge for popup
        queueBadge(badge)
    }
    
    /// Check for Gremlin badge (study after midnight)
    func checkGremlinBadge(sessionTime: Date, context: ModelContext) {
        let hour = Calendar.current.component(.hour, from: sessionTime)
        if hour >= 0 && hour < 5 { // Between midnight and 5 AM
            checkSpecialBadge(badgeName: "Gremlin", context: context)
        }
    }
    
    /// Check for Early Bird badge (study before 6 AM)
    func checkEarlyBirdBadge(sessionTime: Date, context: ModelContext) {
        let hour = Calendar.current.component(.hour, from: sessionTime)
        if hour >= 5 && hour < 6 {
            checkSpecialBadge(badgeName: "Early Bird", context: context)
        }
    }
    
    /// Check for Marathon Runner badge (4+ hour session)
    func checkMarathonBadge(sessionMinutes: Int, context: ModelContext) {
        if sessionMinutes >= 240 { // 4 hours
            checkSpecialBadge(badgeName: "Marathon Runner", context: context)
        }
    }
    
    /// Check for Night Owl badge (sessions after 10 PM)
    func checkNightOwlBadge(sessionsAfter10PM: Int, context: ModelContext) {
        if sessionsAfter10PM >= 10 {
            awardBadgeIfNotEarned(category: .special, requirement: 10, progress: sessionsAfter10PM, context: context)
        }
    }
    
    /// Check for Subject Hopper badge (5 subjects in one day)
    func checkSubjectHopperBadge(subjectsStudiedToday: Int, context: ModelContext) {
        if subjectsStudiedToday >= 5 {
            checkSpecialBadge(badgeName: "Subject Hopper", context: context)
        }
    }
    
    /// Check for Comeback Kid badge (resume after 7+ day break)
    func checkComebackBadge(daysSinceLastStudy: Int, context: ModelContext) {
        if daysSinceLastStudy >= 7 {
            checkSpecialBadge(badgeName: "Comeback Kid", context: context)
        }
    }
    
    // MARK: - Private Helpers
    
    private func awardBadgeIfNotEarned(category: BadgeCategory, requirement: Int, progress: Int, context: ModelContext) {
        let categoryString = category.rawValue
        let descriptor = FetchDescriptor<Badge>(predicate: #Predicate { badge in
            badge.category == categoryString && badge.requirement == requirement && !badge.isEarned
        })
        
        guard let badges = try? context.fetch(descriptor),
              let badge = badges.first else { return }
        
        badge.isEarned = true
        badge.earnedDate = Date()
        badge.progress = progress
        
        try? context.save()
        
        // Queue the badge for popup
        queueBadge(badge)
    }
    
    private func updateBadgeProgress(category: BadgeCategory, progress: Int, context: ModelContext) {
        let categoryString = category.rawValue
        let descriptor = FetchDescriptor<Badge>(predicate: #Predicate { badge in
            badge.category == categoryString && !badge.isEarned
        })
        
        guard let badges = try? context.fetch(descriptor) else { return }
        
        for badge in badges {
            badge.progress = min(progress, badge.requirement)
            
            // Check if this badge should now be unlocked
            if badge.progress >= badge.requirement && !badge.isEarned {
                badge.isEarned = true
                badge.earnedDate = Date()
                try? context.save()
                queueBadge(badge)
            }
        }
        
        try? context.save()
    }
    
    /// Comprehensive badge check after a study session
    func checkAllBadgesAfterSession(
        context: ModelContext,
        userProfile: UserProfile,
        sessionDuration: Int,
        sessionTime: Date,
        totalStudyMinutes: Int,
        completedTasksCount: Int,
        uniqueTechniquesUsed: Int,
        techniquesUsedToday: Int,
        subjectsStudiedToday: Int,
        daysGoalMet: Int
    ) {
        // Streak badges
        checkStreakBadges(streak: userProfile.currentStreak, context: context)
        
        // Time badges
        checkTimeSpentBadges(totalMinutes: totalStudyMinutes, context: context)
        
        // Task badges
        checkTaskBadges(completedTasks: completedTasksCount, context: context)
        
        // Technique badges
        checkTechniqueBadges(uniqueTechniquesUsed: uniqueTechniquesUsed, techniquesInOneDay: techniquesUsedToday, context: context)
        
        // Daily goal badges
        checkDailyGoalBadges(consecutiveDaysHitGoal: daysGoalMet, context: context)
        
        // Special time-based badges
        checkGremlinBadge(sessionTime: sessionTime, context: context)
        checkEarlyBirdBadge(sessionTime: sessionTime, context: context)
        checkMarathonBadge(sessionMinutes: sessionDuration / 60, context: context)
        
        // Subject hopper
        checkSubjectHopperBadge(subjectsStudiedToday: subjectsStudiedToday, context: context)
    }
    
    /// Direct badge award - bypasses lookup and directly awards by name
    func awardBadgeByName(_ badgeName: String, context: ModelContext) {
        let descriptor = FetchDescriptor<Badge>(predicate: #Predicate { badge in
            badge.name == badgeName && !badge.isEarned
        })
        
        guard let badges = try? context.fetch(descriptor),
              let badge = badges.first else { return }
        
        badge.isEarned = true
        badge.earnedDate = Date()
        badge.progress = badge.requirement
        
        try? context.save()
        queueBadge(badge)
    }
}
