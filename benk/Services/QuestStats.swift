//
//  QuestStats.swift
//  benk
//
//  Persistent tracking for quest-related statistics
//  Tracks task completions, study hours, etc. that persist even after deletion
//

import Foundation
import Combine

/// Tracks persistent statistics for quest progress
/// These counts survive task/session deletion
@MainActor
class QuestStats: ObservableObject {
    static let shared = QuestStats()
    
    // MARK: - UserDefaults Keys
    private let tasksCompletedTodayKey = "quest_tasks_completed_today"
    private let tasksCompletedThisWeekKey = "quest_tasks_completed_this_week"
    private let tasksCompletedTotalKey = "quest_tasks_completed_total"
    private let studyMinutesTodayKey = "quest_study_minutes_today"
    private let studyMinutesThisWeekKey = "quest_study_minutes_this_week"
    private let studyMinutesTotalKey = "quest_study_minutes_total"
    private let subjectsStudiedTodayKey = "quest_subjects_studied_today"
    private let dailyGoalsCompletedThisWeekKey = "quest_daily_goals_completed_week"
    private let pomodorosCompletedTodayKey = "quest_pomodoros_today"
    private let pomodorosCompletedThisWeekKey = "quest_pomodoros_week"
    private let breaksTakenTodayKey = "quest_breaks_today"
    private let breaksTakenThisWeekKey = "quest_breaks_week"
    private let lastDailyResetKey = "quest_last_daily_reset"
    private let lastWeeklyResetKey = "quest_last_weekly_reset"
    private let dailyChallengesCompletedTodayKey = "quest_daily_challenges_completed_today"
    private let streakRewardClaimedDateKey = "quest_streak_reward_claimed_date"
    
    // MARK: - Published Properties
    @Published var tasksCompletedToday: Int = 0
    @Published var tasksCompletedThisWeek: Int = 0
    @Published var tasksCompletedTotal: Int = 0
    @Published var studyMinutesToday: Int = 0
    @Published var studyMinutesThisWeek: Int = 0
    @Published var studyMinutesTotal: Int = 0
    @Published var subjectsStudiedToday: Set<UUID> = []
    @Published var dailyGoalsCompletedThisWeek: Int = 0
    @Published var pomodorosCompletedToday: Int = 0
    @Published var pomodorosCompletedThisWeek: Int = 0
    @Published var breaksTakenToday: Int = 0
    @Published var breaksTakenThisWeek: Int = 0
    @Published var dailyChallengesCompletedToday: Int = 0
    @Published var streakRewardClaimedDate: Date?
    
    private init() {
        loadStats()
        checkResets()
    }
    
    // MARK: - Load Stats
    private func loadStats() {
        tasksCompletedToday = UserDefaults.standard.integer(forKey: tasksCompletedTodayKey)
        tasksCompletedThisWeek = UserDefaults.standard.integer(forKey: tasksCompletedThisWeekKey)
        tasksCompletedTotal = UserDefaults.standard.integer(forKey: tasksCompletedTotalKey)
        studyMinutesToday = UserDefaults.standard.integer(forKey: studyMinutesTodayKey)
        studyMinutesThisWeek = UserDefaults.standard.integer(forKey: studyMinutesThisWeekKey)
        studyMinutesTotal = UserDefaults.standard.integer(forKey: studyMinutesTotalKey)
        dailyGoalsCompletedThisWeek = UserDefaults.standard.integer(forKey: dailyGoalsCompletedThisWeekKey)
        pomodorosCompletedToday = UserDefaults.standard.integer(forKey: pomodorosCompletedTodayKey)
        pomodorosCompletedThisWeek = UserDefaults.standard.integer(forKey: pomodorosCompletedThisWeekKey)
        breaksTakenToday = UserDefaults.standard.integer(forKey: breaksTakenTodayKey)
        breaksTakenThisWeek = UserDefaults.standard.integer(forKey: breaksTakenThisWeekKey)
        dailyChallengesCompletedToday = UserDefaults.standard.integer(forKey: dailyChallengesCompletedTodayKey)
        
        if let dateData = UserDefaults.standard.data(forKey: streakRewardClaimedDateKey),
           let date = try? JSONDecoder().decode(Date.self, from: dateData) {
            streakRewardClaimedDate = date
        }
        
        // Load subjects studied today as array of UUID strings
        if let subjectStrings = UserDefaults.standard.stringArray(forKey: subjectsStudiedTodayKey) {
            subjectsStudiedToday = Set(subjectStrings.compactMap { UUID(uuidString: $0) })
        }
    }
    
    // MARK: - Save Stats
    private func saveStats() {
        UserDefaults.standard.set(tasksCompletedToday, forKey: tasksCompletedTodayKey)
        UserDefaults.standard.set(tasksCompletedThisWeek, forKey: tasksCompletedThisWeekKey)
        UserDefaults.standard.set(tasksCompletedTotal, forKey: tasksCompletedTotalKey)
        UserDefaults.standard.set(studyMinutesToday, forKey: studyMinutesTodayKey)
        UserDefaults.standard.set(studyMinutesThisWeek, forKey: studyMinutesThisWeekKey)
        UserDefaults.standard.set(studyMinutesTotal, forKey: studyMinutesTotalKey)
        UserDefaults.standard.set(dailyGoalsCompletedThisWeek, forKey: dailyGoalsCompletedThisWeekKey)
        UserDefaults.standard.set(pomodorosCompletedToday, forKey: pomodorosCompletedTodayKey)
        UserDefaults.standard.set(pomodorosCompletedThisWeek, forKey: pomodorosCompletedThisWeekKey)
        UserDefaults.standard.set(breaksTakenToday, forKey: breaksTakenTodayKey)
        UserDefaults.standard.set(breaksTakenThisWeek, forKey: breaksTakenThisWeekKey)
        UserDefaults.standard.set(dailyChallengesCompletedToday, forKey: dailyChallengesCompletedTodayKey)
        
        // Save subjects as string array
        let subjectStrings = subjectsStudiedToday.map { $0.uuidString }
        UserDefaults.standard.set(subjectStrings, forKey: subjectsStudiedTodayKey)
        
        if let date = streakRewardClaimedDate,
           let dateData = try? JSONEncoder().encode(date) {
            UserDefaults.standard.set(dateData, forKey: streakRewardClaimedDateKey)
        }
    }
    
    // MARK: - Check Resets
    func checkResets() {
        let calendar = Calendar.current
        let now = Date()
        let today = calendar.startOfDay(for: now)
        
        // Check daily reset
        if let lastDailyReset = UserDefaults.standard.object(forKey: lastDailyResetKey) as? Date {
            let lastResetDay = calendar.startOfDay(for: lastDailyReset)
            if lastResetDay < today {
                resetDailyStats()
            }
        } else {
            UserDefaults.standard.set(today, forKey: lastDailyResetKey)
        }
        
        // Check weekly reset (Monday 00:00)
        let weekday = calendar.component(.weekday, from: now)
        let isMonday = weekday == 2 // Sunday = 1, Monday = 2
        
        if let lastWeeklyReset = UserDefaults.standard.object(forKey: lastWeeklyResetKey) as? Date {
            let daysSinceReset = calendar.dateComponents([.day], from: lastWeeklyReset, to: now).day ?? 0
            // Reset if it's Monday and we haven't reset this week, or if more than 7 days passed
            if (isMonday && !calendar.isDate(lastWeeklyReset, inSameDayAs: now)) || daysSinceReset >= 7 {
                resetWeeklyStats()
            }
        } else {
            UserDefaults.standard.set(now, forKey: lastWeeklyResetKey)
        }
    }
    
    private func resetDailyStats() {
        tasksCompletedToday = 0
        studyMinutesToday = 0
        subjectsStudiedToday = []
        pomodorosCompletedToday = 0
        breaksTakenToday = 0
        dailyChallengesCompletedToday = 0
        UserDefaults.standard.set(Date(), forKey: lastDailyResetKey)
        saveStats()
    }
    
    private func resetWeeklyStats() {
        tasksCompletedThisWeek = 0
        studyMinutesThisWeek = 0
        dailyGoalsCompletedThisWeek = 0
        pomodorosCompletedThisWeek = 0
        breaksTakenThisWeek = 0
        UserDefaults.standard.set(Date(), forKey: lastWeeklyResetKey)
        saveStats()
    }
    
    // MARK: - Tracking Methods
    
    /// Call when a task is marked as completed
    func recordTaskCompletion() {
        tasksCompletedToday += 1
        tasksCompletedThisWeek += 1
        tasksCompletedTotal += 1
        saveStats()
    }
    
    /// Call when a study session ends with duration in seconds
    func recordStudySession(durationSeconds: Int, subjectId: UUID?) {
        let minutes = durationSeconds / 60
        studyMinutesToday += minutes
        studyMinutesThisWeek += minutes
        studyMinutesTotal += minutes
        
        if let subjectId = subjectId {
            subjectsStudiedToday.insert(subjectId)
        }
        saveStats()
    }
    
    /// Call when daily goal is completed
    func recordDailyGoalCompletion() {
        dailyGoalsCompletedThisWeek += 1
        saveStats()
    }
    
    /// Call when a pomodoro session is completed
    func recordPomodoroCompletion() {
        pomodorosCompletedToday += 1
        pomodorosCompletedThisWeek += 1
        saveStats()
    }
    
    /// Call when a break is taken
    func recordBreakTaken() {
        breaksTakenToday += 1
        breaksTakenThisWeek += 1
        saveStats()
    }
    
    /// Call when a daily challenge is completed
    func recordDailyChallengeCompletion() {
        dailyChallengesCompletedToday += 1
        saveStats()
    }
    
    /// Check if streak reward can be claimed today
    var canClaimStreakReward: Bool {
        guard let claimedDate = streakRewardClaimedDate else { return true }
        return !Calendar.current.isDateInToday(claimedDate)
    }
    
    /// Record streak reward claim
    func recordStreakRewardClaim() {
        streakRewardClaimedDate = Date()
        saveStats()
    }
    
    // MARK: - Computed Properties
    
    var studyHoursToday: Double {
        Double(studyMinutesToday) / 60.0
    }
    
    var studyHoursThisWeek: Double {
        Double(studyMinutesThisWeek) / 60.0
    }
    
    var studyHoursTotal: Double {
        Double(studyMinutesTotal) / 60.0
    }
    
    var subjectsStudiedTodayCount: Int {
        subjectsStudiedToday.count
    }
    
    // MARK: - Reset All Stats
    
    /// Completely reset all quest stats (for app data reset)
    func resetAllStats() {
        tasksCompletedToday = 0
        tasksCompletedThisWeek = 0
        tasksCompletedTotal = 0
        studyMinutesToday = 0
        studyMinutesThisWeek = 0
        studyMinutesTotal = 0
        subjectsStudiedToday = []
        dailyGoalsCompletedThisWeek = 0
        pomodorosCompletedToday = 0
        pomodorosCompletedThisWeek = 0
        breaksTakenToday = 0
        breaksTakenThisWeek = 0
        dailyChallengesCompletedToday = 0
        streakRewardClaimedDate = nil
        
        // Clear UserDefaults
        let keys = [
            tasksCompletedTodayKey, tasksCompletedThisWeekKey, tasksCompletedTotalKey,
            studyMinutesTodayKey, studyMinutesThisWeekKey, studyMinutesTotalKey,
            subjectsStudiedTodayKey, dailyGoalsCompletedThisWeekKey,
            pomodorosCompletedTodayKey, pomodorosCompletedThisWeekKey,
            breaksTakenTodayKey, breaksTakenThisWeekKey,
            dailyChallengesCompletedTodayKey, streakRewardClaimedDateKey,
            lastDailyResetKey, lastWeeklyResetKey
        ]
        for key in keys {
            UserDefaults.standard.removeObject(forKey: key)
        }
        
        // Set fresh reset dates
        let now = Date()
        UserDefaults.standard.set(now, forKey: lastDailyResetKey)
        UserDefaults.standard.set(now, forKey: lastWeeklyResetKey)
    }
    
    // MARK: - Sync from SwiftData Sessions
    
    /// Sync study minutes from actual SwiftData sessions (call this to fix historical data)
    func syncStudyMinutesFromSessions(_ sessions: [StudySession]) {
        let calendar = Calendar.current
        let now = Date()
        let todayStart = calendar.startOfDay(for: now)
        
        // Calculate week start (Monday)
        let weekday = calendar.component(.weekday, from: now)
        let daysToMonday = (weekday == 1) ? -6 : (2 - weekday)
        let weekStart = calendar.date(byAdding: .day, value: daysToMonday, to: todayStart) ?? todayStart
        
        // Filter completed sessions
        let completedSessions = sessions.filter { $0.isCompleted }
        
        // Calculate today's minutes
        let todaySessions = completedSessions.filter { 
            calendar.isDate($0.timestamp, inSameDayAs: now) 
        }
        let todaySeconds = todaySessions.reduce(0) { $0 + $1.duration }
        studyMinutesToday = todaySeconds / 60
        
        // Calculate this week's minutes
        let weekSessions = completedSessions.filter {
            $0.timestamp >= weekStart && $0.timestamp <= now
        }
        let weekSeconds = weekSessions.reduce(0) { $0 + $1.duration }
        studyMinutesThisWeek = weekSeconds / 60
        
        // Calculate total minutes
        let totalSeconds = completedSessions.reduce(0) { $0 + $1.duration }
        studyMinutesTotal = totalSeconds / 60
        
        saveStats()
    }
}
