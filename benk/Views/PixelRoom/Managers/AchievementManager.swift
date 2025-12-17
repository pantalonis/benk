//
//  AchievementManager.swift
//  Pixel Room Customizer
//
//  Manages achievements, daily tasks, and rewards
//

import Foundation
import SwiftUI
import Combine

class AchievementManager: ObservableObject {
    static let shared = AchievementManager()
    
    // MARK: - Published Properties
    @Published var achievementProgress: [String: AchievementProgress] = [:]
    @Published var dailyTaskProgress: [String: DailyTaskProgress] = [:]
    @Published var loginStreak = LoginStreak(currentStreak: 0, longestStreak: 0, lastLoginDate: nil, totalLogins: 0)
    @Published var dailyRewardClaimed: Bool = false
    @Published var lastDailyRewardDate: Date?
    @Published var currentDailyTasks: [DailyTask] = []
    @Published var lastTaskResetDate: Date?
    @Published var totalCoinsEarned: Int = 0
    @Published var totalItemsPurchased: Int = 0
    @Published var totalItemsPlaced: Int = 0
    @Published var uniqueRoomThemesUsed: Set<String> = []
    
    // MARK: - Notifications
    let achievementUnlockedPublisher = PassthroughSubject<Achievement, Never>()
    let dailyTaskCompletedPublisher = PassthroughSubject<DailyTask, Never>()
    let dailyRewardClaimedPublisher = PassthroughSubject<DailyReward, Never>()
    
    private init() {
        initializeAchievements()
        checkDailyReset()
    }
    
    // MARK: - Initialization
    
    private func initializeAchievements() {
        // Initialize progress for all achievements if not already tracked
        for achievement in AchievementCatalog.allAchievements {
            if achievementProgress[achievement.id] == nil {
                achievementProgress[achievement.id] = AchievementProgress(
                    achievementId: achievement.id,
                    currentValue: 0,
                    isCompleted: false,
                    completedDate: nil,
                    isRewardClaimed: false
                )
            }
        }
    }
    
    // MARK: - Daily Reset
    
    func checkDailyReset() {
        let today = Calendar.current.startOfDay(for: Date())
        
        // Reset daily reward claim
        if let lastReward = lastDailyRewardDate {
            let lastRewardDay = Calendar.current.startOfDay(for: lastReward)
            if lastRewardDay < today {
                dailyRewardClaimed = false
            }
        } else {
            dailyRewardClaimed = false
        }
        
        // Reset daily tasks
        if let lastReset = lastTaskResetDate {
            let lastResetDay = Calendar.current.startOfDay(for: lastReset)
            if lastResetDay < today {
                resetDailyTasks()
            }
        } else {
            resetDailyTasks()
        }
    }
    
    private func resetDailyTasks() {
        currentDailyTasks = DailyTaskCatalog.generateDailyTasks()
        dailyTaskProgress.removeAll()
        
        for task in currentDailyTasks {
            dailyTaskProgress[task.id] = DailyTaskProgress(
                taskId: task.id,
                currentValue: 0,
                isCompleted: false,
                completedDate: nil
            )
        }
        
        lastTaskResetDate = Date()
    }
    
    // MARK: - Login Tracking
    
    func recordLogin() {
        guard !loginStreak.hasLoggedInToday else { return }
        
        loginStreak.recordLogin()
        
        // Update daily login achievement
        updateProgress(for: .dailyLogins, value: loginStreak.currentStreak)
        
        // Check if daily reward is available
        checkDailyReset()
    }
    
    // MARK: - Daily Rewards
    
    func claimDailyReward() -> DailyReward? {
        guard !dailyRewardClaimed else { return nil }
        
        let day = loginStreak.currentStreak
        let reward = DailyRewardCatalog.getReward(for: day)
        
        // Award bonus item if available
        if let bonusItemId = reward.bonusItem,
           let item = ItemCatalog.allShopItems.first(where: { $0.id == bonusItemId }) {
            InventoryManager.shared.addItem(item)
        }
        
        dailyRewardClaimed = true
        lastDailyRewardDate = Date()
        
        dailyRewardClaimedPublisher.send(reward)
        
        return reward
    }
    
    var canClaimDailyReward: Bool {
        return !dailyRewardClaimed && loginStreak.hasLoggedInToday
    }
    
    // MARK: - Progress Tracking
    
    func updateProgress(for type: AchievementType, value: Int) {
        // Update all achievements of this type
        let relevantAchievements = AchievementCatalog.allAchievements.filter { $0.type == type }
        
        for achievement in relevantAchievements {
            guard var progress = achievementProgress[achievement.id] else { continue }
            guard !progress.isCompleted else { continue }
            
            progress.currentValue = value
            
            // Check if achievement is completed
            if progress.currentValue >= achievement.targetValue && !progress.isCompleted {
                progress.isCompleted = true
                progress.completedDate = Date()
                achievementProgress[achievement.id] = progress
                
                achievementUnlockedPublisher.send(achievement)
                
                // Play haptic feedback
                HapticManager.shared.notification(.success)
            } else {
                achievementProgress[achievement.id] = progress
            }
        }
        
        // Update daily tasks
        updateDailyTaskProgress(for: type, increment: 1)
    }
    
    func incrementProgress(for type: AchievementType, by amount: Int = 1) {
        // Get current max value for this type
        let relevantAchievements = AchievementCatalog.allAchievements.filter { $0.type == type }
        var currentMax = 0
        
        for achievement in relevantAchievements {
            if let progress = achievementProgress[achievement.id] {
                currentMax = max(currentMax, progress.currentValue)
            }
        }
        
        updateProgress(for: type, value: currentMax + amount)
    }
    
    // MARK: - Daily Tasks
    
    private func updateDailyTaskProgress(for type: AchievementType, increment: Int) {
        let relevantTasks = currentDailyTasks.filter { $0.taskType == type }
        
        for task in relevantTasks {
            guard var progress = dailyTaskProgress[task.id] else { continue }
            guard !progress.isCompleted else { continue }
            
            progress.currentValue += increment
            
            if progress.currentValue >= task.targetValue && !progress.isCompleted {
                progress.isCompleted = true
                progress.completedDate = Date()
                dailyTaskProgress[task.id] = progress
                
                dailyTaskCompletedPublisher.send(task)
                
                // Play haptic feedback
                HapticManager.shared.notification(.success)
            } else {
                dailyTaskProgress[task.id] = progress
            }
        }
    }
    
    // MARK: - Claim Achievement Reward
    
    func claimAchievementReward(_ achievementId: String) -> Bool {
        guard var progress = achievementProgress[achievementId],
              progress.isCompleted,
              !progress.isRewardClaimed,
              let achievement = AchievementCatalog.allAchievements.first(where: { $0.id == achievementId }) else {
            return false
        }
        
        progress.isRewardClaimed = true
        achievementProgress[achievementId] = progress
        
        // Play haptic feedback
        HapticManager.shared.notification(.success)
        
        return true
    }
    
    // MARK: - Computed Properties
    
    var completedAchievements: [Achievement] {
        AchievementCatalog.allAchievements.filter { achievement in
            achievementProgress[achievement.id]?.isCompleted ?? false
        }
    }
    
    var unclaimedAchievements: [Achievement] {
        AchievementCatalog.allAchievements.filter { achievement in
            if let progress = achievementProgress[achievement.id] {
                return progress.isCompleted && !progress.isRewardClaimed
            }
            return false
        }
    }
    
    var inProgressAchievements: [Achievement] {
        AchievementCatalog.allAchievements.filter { achievement in
            if let progress = achievementProgress[achievement.id] {
                return !progress.isCompleted && progress.currentValue > 0
            }
            return false
        }
    }
    
    var completedDailyTasks: [DailyTask] {
        currentDailyTasks.filter { task in
            dailyTaskProgress[task.id]?.isCompleted ?? false
        }
    }
    
    var totalAchievementProgress: Double {
        let total = AchievementCatalog.allAchievements.count
        let completed = completedAchievements.count
        return total > 0 ? Double(completed) / Double(total) : 0
    }
    
    // MARK: - Event Handlers (called from other managers)
    
    func onItemPlaced() {
        totalItemsPlaced += 1
        incrementProgress(for: .itemsPlaced, by: 1)
    }
    
    func onItemPurchased(_ item: Item) {
        totalItemsPurchased += 1
        incrementProgress(for: .itemsPurchased, by: 1)
        
        // Track specific categories
        switch item.category {
        case .pet:
            let petCount = InventoryManager.shared.ownedItems.filter { $0.category == .pet }.count
            updateProgress(for: .petsOwned, value: petCount)
            
        case .furniture:
            let furnitureCount = InventoryManager.shared.ownedItems.filter { $0.category == .furniture }.count
            updateProgress(for: .furnitureOwned, value: furnitureCount)
            
            // Check for plants (subcategory)
            let plantCount = InventoryManager.shared.ownedItems.filter {
                $0.category == .furniture && ($0.subCategory == "Decorations" && $0.name.lowercased().contains("plant"))
            }.count
            updateProgress(for: .plantsOwned, value: plantCount)
            
        case .decoration:
            let decorationCount = InventoryManager.shared.ownedItems.filter { $0.category == .decoration }.count
            updateProgress(for: .decorationsOwned, value: decorationCount)
            
        default:
            break
        }
    }
    
    func onCoinsEarned(_ amount: Int) {
        totalCoinsEarned += amount
        updateProgress(for: .coinsEarned, value: totalCoinsEarned)
    }
    
    func onRoomThemeChanged(_ themeId: String) {
        uniqueRoomThemesUsed.insert(themeId)
        updateProgress(for: .roomThemes, value: uniqueRoomThemesUsed.count)
    }
}

// MARK: - Singleton Access Extension
extension AchievementManager {
    static var instance: AchievementManager {
        return shared
    }
}
