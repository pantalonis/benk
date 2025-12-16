//
//  QuestService.swift
//  benk
//
//  Main quest management service
//  Handles daily/weekly challenge generation, streak rewards, and goal tracking
//

import Foundation
import Combine
import SwiftUI
import SwiftData

/// Quest category for filtering
enum QuestCategory: String, Codable, CaseIterable {
    case daily = "Daily"
    case weekly = "Weekly"
    case goals = "Goals"
}

/// Quest tracking type - what metric does this quest track
enum QuestTrackingType: String, Codable {
    // Daily tracking
    case tasksCompletedToday
    case studyMinutesToday
    case dailyGoalCompleted
    case subjectsStudiedToday
    case breaksTakenToday
    case pomodorosCompletedToday
    case studySessionCompleted
    case earlyMorningStudy
    case eveningStudy
    case exceedDailyGoal
    
    // Weekly tracking
    case tasksCompletedThisWeek
    case studyMinutesThisWeek
    case dailyGoalsCompletedThisWeek
    case pomodorosCompletedThisWeek
    case breaksTakenThisWeek
    case streakDays
    case dailyChallengesCompletedThisWeek
    case weekendStudy
    case tasksInOneDay
    case studyMinutesInOneDay
    
    // Total/Goal tracking
    case tasksCompletedTotal
    case studyMinutesTotal
    case coinsEarned
    case petsOwned
    case plantsOwned
    case furnitureOwned
    case itemsOwned
    case itemsPlaced
    case decorationsOwned
    case roomThemesUsed
    case currentStreak
}

/// Quest template for catalog
struct QuestTemplate: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let description: String
    let instructions: String
    let lore: String
    let icon: String
    let category: QuestCategory
    let trackingType: QuestTrackingType
    let targetValue: Int
    let coinReward: Int
    let colorHex: String
    
    var color: Color {
        Color(hex: colorHex) ?? .blue
    }
}

/// Active quest instance with progress
struct ActiveQuest: Identifiable, Codable, Equatable {
    let id: UUID
    let templateId: String
    var currentProgress: Int
    var isCompleted: Bool
    var isClaimed: Bool
    var createdAt: Date
    var completedAt: Date?
    var claimedAt: Date?
    
    var progressPercentage: Double {
        guard let template = QuestCatalog.getTemplate(id: templateId) else { return 0 }
        return min(Double(currentProgress) / Double(template.targetValue), 1.0)
    }
    
    var remainingCount: Int {
        guard let template = QuestCatalog.getTemplate(id: templateId) else { return 0 }
        return max(template.targetValue - currentProgress, 0)
    }
}

/// Main quest service
@MainActor
class QuestService: ObservableObject {
    static let shared = QuestService()
    
    // MARK: - UserDefaults Keys
    private let activeDailyQuestsKey = "quest_active_daily_v2"
    private let activeWeeklyQuestsKey = "quest_active_weekly_v2"
    private let completedGoalIdsKey = "quest_completed_goals_v2"
    private let lastDailyRefreshKey = "quest_last_daily_refresh_v2"
    private let lastWeeklyRefreshKey = "quest_last_weekly_refresh_v2"
    
    // MARK: - Published Properties
    @Published var activeDailyQuests: [ActiveQuest] = []
    @Published var activeWeeklyQuests: [ActiveQuest] = []
    @Published var completedGoalIds: Set<String> = []
    
    private init() {
        loadQuests()
        checkRefresh()
    }
    
    // MARK: - Load/Save
    
    private func loadQuests() {
        if let data = UserDefaults.standard.data(forKey: activeDailyQuestsKey),
           let quests = try? JSONDecoder().decode([ActiveQuest].self, from: data) {
            activeDailyQuests = quests
        }
        
        if let data = UserDefaults.standard.data(forKey: activeWeeklyQuestsKey),
           let quests = try? JSONDecoder().decode([ActiveQuest].self, from: data) {
            activeWeeklyQuests = quests
        }
        
        if let ids = UserDefaults.standard.stringArray(forKey: completedGoalIdsKey) {
            completedGoalIds = Set(ids)
        }
    }
    
    private func saveQuests() {
        if let data = try? JSONEncoder().encode(activeDailyQuests) {
            UserDefaults.standard.set(data, forKey: activeDailyQuestsKey)
        }
        if let data = try? JSONEncoder().encode(activeWeeklyQuests) {
            UserDefaults.standard.set(data, forKey: activeWeeklyQuestsKey)
        }
        UserDefaults.standard.set(Array(completedGoalIds), forKey: completedGoalIdsKey)
    }
    
    // MARK: - Refresh Logic
    
    func checkRefresh() {
        let calendar = Calendar.current
        let now = Date()
        let today = calendar.startOfDay(for: now)
        
        // Check daily refresh
        if let lastRefresh = UserDefaults.standard.object(forKey: lastDailyRefreshKey) as? Date {
            if calendar.startOfDay(for: lastRefresh) < today {
                refreshDailyQuests()
            }
        } else {
            refreshDailyQuests()
        }
        
        // Check weekly refresh (Monday 00:00)
        if let lastRefresh = UserDefaults.standard.object(forKey: lastWeeklyRefreshKey) as? Date {
            // Get the Monday of current week
            let currentWeekday = calendar.component(.weekday, from: now)
            let daysToMonday = (currentWeekday == 1) ? -6 : (2 - currentWeekday)
            guard let thisMonday = calendar.date(byAdding: .day, value: daysToMonday, to: today) else { return }
            
            let lastRefreshDay = calendar.startOfDay(for: lastRefresh)
            if lastRefreshDay < thisMonday {
                refreshWeeklyQuests()
            }
        } else {
            refreshWeeklyQuests()
        }
        
        // Update progress with current stats
        updateAllProgress()
    }
    
    private func refreshDailyQuests() {
        // Pick 3 random daily quests
        let templates = QuestCatalog.dailyQuests.shuffled().prefix(3)
        activeDailyQuests = templates.map { template in
            ActiveQuest(
                id: UUID(),
                templateId: template.id,
                currentProgress: 0,
                isCompleted: false,
                isClaimed: false,
                createdAt: Date()
            )
        }
        UserDefaults.standard.set(Date(), forKey: lastDailyRefreshKey)
        saveQuests()
    }
    
    private func refreshWeeklyQuests() {
        // Pick 3 random weekly quests
        let templates = QuestCatalog.weeklyQuests.shuffled().prefix(3)
        activeWeeklyQuests = templates.map { template in
            ActiveQuest(
                id: UUID(),
                templateId: template.id,
                currentProgress: 0,
                isCompleted: false,
                isClaimed: false,
                createdAt: Date()
            )
        }
        UserDefaults.standard.set(Date(), forKey: lastWeeklyRefreshKey)
        saveQuests()
    }
    
    // MARK: - Streak Reward Calculation
    
    func streakRewardCoins(for streak: Int) -> Int {
        switch streak {
        case 0...10: return 10
        case 11...15: return 15
        case 16...25: return 25
        case 26...50: return 40
        case 51...100: return 60
        default: return 100
        }
    }
    
    // MARK: - Progress Update
    
    func updateAllProgress() {
        let stats = QuestStats.shared
        
        // Update daily quests based on current stats
        for i in activeDailyQuests.indices {
            guard let template = QuestCatalog.getTemplate(id: activeDailyQuests[i].templateId),
                  !activeDailyQuests[i].isCompleted else { continue }
            
            let value = getProgressValue(for: template.trackingType, stats: stats)
            activeDailyQuests[i].currentProgress = value
            
            if value >= template.targetValue {
                activeDailyQuests[i].isCompleted = true
                activeDailyQuests[i].completedAt = Date()
            }
        }
        
        // Update weekly quests
        for i in activeWeeklyQuests.indices {
            guard let template = QuestCatalog.getTemplate(id: activeWeeklyQuests[i].templateId),
                  !activeWeeklyQuests[i].isCompleted else { continue }
            
            let value = getProgressValue(for: template.trackingType, stats: stats)
            activeWeeklyQuests[i].currentProgress = value
            
            if value >= template.targetValue {
                activeWeeklyQuests[i].isCompleted = true
                activeWeeklyQuests[i].completedAt = Date()
            }
        }
        
        saveQuests()
    }
    
    private func getProgressValue(for trackingType: QuestTrackingType, stats: QuestStats) -> Int {
        switch trackingType {
        case .tasksCompletedToday:
            return stats.tasksCompletedToday
        case .studyMinutesToday:
            return stats.studyMinutesToday
        case .subjectsStudiedToday:
            return stats.subjectsStudiedTodayCount
        case .breaksTakenToday:
            return stats.breaksTakenToday
        case .pomodorosCompletedToday:
            return stats.pomodorosCompletedToday
        case .tasksCompletedThisWeek:
            return stats.tasksCompletedThisWeek
        case .studyMinutesThisWeek:
            return stats.studyMinutesThisWeek
        case .dailyGoalsCompletedThisWeek:
            return stats.dailyGoalsCompletedThisWeek
        case .pomodorosCompletedThisWeek:
            return stats.pomodorosCompletedThisWeek
        case .breaksTakenThisWeek:
            return stats.breaksTakenThisWeek
        case .tasksCompletedTotal:
            return stats.tasksCompletedTotal
        case .studyMinutesTotal:
            return stats.studyMinutesTotal
        default:
            return 0
        }
    }
    
    // MARK: - Goal Progress
    
    func getGoalProgress(for template: QuestTemplate) -> Int {
        let stats = QuestStats.shared
        let inventory = InventoryManager.shared
        let room = RoomManager.shared
        let achievement = AchievementManager.shared
        
        switch template.trackingType {
        case .petsOwned:
            return inventory.ownedItems.filter { $0.category == .pet }.count
        case .plantsOwned:
            return inventory.ownedItems.filter { 
                $0.category == .furniture && $0.name.lowercased().contains("plant") 
            }.count
        case .furnitureOwned:
            return inventory.ownedItems.filter { $0.category == .furniture }.count
        case .itemsOwned:
            return inventory.ownedItems.count
        case .itemsPlaced:
            return room.placedObjects.count
        case .decorationsOwned:
            return inventory.ownedItems.filter { $0.category == .decoration }.count
        case .coinsEarned:
            return achievement.totalCoinsEarned
        case .tasksCompletedTotal:
            return stats.tasksCompletedTotal
        case .studyMinutesTotal:
            return stats.studyMinutesTotal
        case .roomThemesUsed:
            return achievement.uniqueRoomThemesUsed.count
        default:
            return 0
        }
    }
    
    func isGoalCompleted(_ template: QuestTemplate) -> Bool {
        completedGoalIds.contains(template.id)
    }
    
    func isGoalClaimable(_ template: QuestTemplate) -> Bool {
        !completedGoalIds.contains(template.id) && getGoalProgress(for: template) >= template.targetValue
    }
    
    // MARK: - Claim Rewards
    
    func claimDailyQuest(id: UUID) -> Int? {
        guard let index = activeDailyQuests.firstIndex(where: { $0.id == id }),
              activeDailyQuests[index].isCompleted,
              !activeDailyQuests[index].isClaimed,
              let template = QuestCatalog.getTemplate(id: activeDailyQuests[index].templateId) else {
            return nil
        }
        
        activeDailyQuests[index].isClaimed = true
        activeDailyQuests[index].claimedAt = Date()
        CurrencyManager.shared.addCoins(template.coinReward)
        QuestStats.shared.recordDailyChallengeCompletion()
        saveQuests()
        HapticManager.shared.success()
        return template.coinReward
    }
    
    func claimWeeklyQuest(id: UUID) -> Int? {
        guard let index = activeWeeklyQuests.firstIndex(where: { $0.id == id }),
              activeWeeklyQuests[index].isCompleted,
              !activeWeeklyQuests[index].isClaimed,
              let template = QuestCatalog.getTemplate(id: activeWeeklyQuests[index].templateId) else {
            return nil
        }
        
        activeWeeklyQuests[index].isClaimed = true
        activeWeeklyQuests[index].claimedAt = Date()
        CurrencyManager.shared.addCoins(template.coinReward)
        saveQuests()
        HapticManager.shared.success()
        return template.coinReward
    }
    
    func claimGoal(templateId: String) -> Int? {
        guard let template = QuestCatalog.getTemplate(id: templateId),
              !completedGoalIds.contains(templateId) else {
            return nil
        }
        
        let progress = getGoalProgress(for: template)
        guard progress >= template.targetValue else { return nil }
        
        completedGoalIds.insert(templateId)
        CurrencyManager.shared.addCoins(template.coinReward)
        saveQuests()
        HapticManager.shared.success()
        return template.coinReward
    }
    
    func claimStreakReward(streak: Int) -> Int? {
        guard QuestStats.shared.canClaimStreakReward else { return nil }
        
        let coins = streakRewardCoins(for: streak)
        CurrencyManager.shared.addCoins(coins)
        QuestStats.shared.recordStreakRewardClaim()
        HapticManager.shared.success()
        return coins
    }
    
    // MARK: - Computed Properties
    
    var completedDailyCount: Int {
        activeDailyQuests.filter { $0.isCompleted }.count
    }
    
    var claimedDailyCount: Int {
        activeDailyQuests.filter { $0.isClaimed }.count
    }
    
    var completedWeeklyCount: Int {
        activeWeeklyQuests.filter { $0.isCompleted }.count
    }
    
    var claimedWeeklyCount: Int {
        activeWeeklyQuests.filter { $0.isClaimed }.count
    }
    
    var completedGoalsCount: Int {
        completedGoalIds.count
    }
    
    var totalGoalsCount: Int {
        QuestCatalog.goalQuests.count
    }
    
    var dailyProgress: Double {
        guard !activeDailyQuests.isEmpty else { return 0 }
        return Double(completedDailyCount) / Double(activeDailyQuests.count)
    }
    
    var weeklyProgress: Double {
        guard !activeWeeklyQuests.isEmpty else { return 0 }
        return Double(completedWeeklyCount) / Double(activeWeeklyQuests.count)
    }
    
    var goalsProgress: Double {
        guard totalGoalsCount > 0 else { return 0 }
        return Double(completedGoalsCount) / Double(totalGoalsCount)
    }
}
