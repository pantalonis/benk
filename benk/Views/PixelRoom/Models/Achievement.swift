//
//  Achievement.swift
//  Pixel Room Customizer
//
//  Achievement system models and definitions
//

import Foundation
import SwiftUI

// MARK: - Achievement Type
enum AchievementType: String, Codable {
    case itemsPlaced = "items_placed"
    case coinsEarned = "coins_earned"
    case petsOwned = "pets_owned"
    case plantsOwned = "plants_owned"
    case roomThemes = "room_themes"
    case furnitureOwned = "furniture_owned"
    case dailyLogins = "daily_logins"
    case itemsPurchased = "items_purchased"
    case decorationsOwned = "decorations_owned"
}

// MARK: - Achievement Tier
enum AchievementTier: String, Codable {
    case bronze = "Bronze"
    case silver = "Silver"
    case gold = "Gold"
    case platinum = "Platinum"
    case diamond = "Diamond"
    
    var color: Color {
        switch self {
        case .bronze: return Color(red: 0.8, green: 0.5, blue: 0.2)
        case .silver: return Color(red: 0.75, green: 0.75, blue: 0.75)
        case .gold: return Color(red: 1.0, green: 0.84, blue: 0.0)
        case .platinum: return Color(red: 0.9, green: 0.95, blue: 1.0)
        case .diamond: return Color(red: 0.7, green: 0.9, blue: 1.0)
        }
    }
    
    var emoji: String {
        switch self {
        case .bronze: return "🥉"
        case .silver: return "🥈"
        case .gold: return "🥇"
        case .platinum: return "💎"
        case .diamond: return "💠"
        }
    }
}

// MARK: - Achievement Model
struct Achievement: Identifiable, Codable, Equatable {
    let id: String
    let type: AchievementType
    let tier: AchievementTier
    let title: String
    let description: String
    let targetValue: Int
    let rewardCoins: Int
    let icon: String // Emoji or SF Symbol
    
    init(
        id: String,
        type: AchievementType,
        tier: AchievementTier,
        title: String,
        description: String,
        targetValue: Int,
        rewardCoins: Int,
        icon: String
    ) {
        self.id = id
        self.type = type
        self.tier = tier
        self.title = title
        self.description = description
        self.targetValue = targetValue
        self.rewardCoins = rewardCoins
        self.icon = icon
    }
}

// MARK: - Achievement Progress
struct AchievementProgress: Codable, Equatable {
    let achievementId: String
    var currentValue: Int
    var isCompleted: Bool
    var completedDate: Date?
    var isRewardClaimed: Bool
    
    var progress: Double {
        guard let achievement = AchievementCatalog.allAchievements.first(where: { $0.id == achievementId }) else {
            return 0
        }
        return min(Double(currentValue) / Double(achievement.targetValue), 1.0)
    }
}

// MARK: - Daily Task
struct DailyTask: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let description: String
    let targetValue: Int
    let rewardCoins: Int
    let icon: String
    let taskType: AchievementType // Reuse achievement types
    
    init(
        id: String,
        title: String,
        description: String,
        targetValue: Int,
        rewardCoins: Int,
        icon: String,
        taskType: AchievementType
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.targetValue = targetValue
        self.rewardCoins = rewardCoins
        self.icon = icon
        self.taskType = taskType
    }
}

// MARK: - Daily Task Progress
struct DailyTaskProgress: Codable, Equatable {
    let taskId: String
    var currentValue: Int
    var isCompleted: Bool
    var completedDate: Date?
    
    var progress: Double {
        guard let task = DailyTaskCatalog.allTasks.first(where: { $0.id == taskId }) else {
            return 0
        }
        return min(Double(currentValue) / Double(task.targetValue), 1.0)
    }
}

// MARK: - Daily Reward
struct DailyReward: Codable, Equatable {
    let day: Int
    let coins: Int
    let bonusItem: String? // Optional bonus item ID
    
    var displayText: String {
        if let item = bonusItem {
            return "\(coins) coins + \(item)"
        }
        return "\(coins) coins"
    }
}

// MARK: - Login Streak
struct LoginStreak: Codable {
    var currentStreak: Int
    var longestStreak: Int
    var lastLoginDate: Date?
    var totalLogins: Int
    
    mutating func recordLogin() {
        let today = Calendar.current.startOfDay(for: Date())
        
        if let lastLogin = lastLoginDate {
            let lastLoginDay = Calendar.current.startOfDay(for: lastLogin)
            let daysBetween = Calendar.current.dateComponents([.day], from: lastLoginDay, to: today).day ?? 0
            
            if daysBetween == 1 {
                // Consecutive day
                currentStreak += 1
            } else if daysBetween > 1 {
                // Streak broken
                currentStreak = 1
            }
            // If daysBetween == 0, already logged in today, do nothing
        } else {
            // First login
            currentStreak = 1
        }
        
        longestStreak = max(longestStreak, currentStreak)
        lastLoginDate = Date()
        totalLogins += 1
    }
    
    var hasLoggedInToday: Bool {
        guard let lastLogin = lastLoginDate else { return false }
        return Calendar.current.isDateInToday(lastLogin)
    }
}

// MARK: - Achievement Catalog
struct AchievementCatalog {
    static let allAchievements: [Achievement] = [
        // Items Placed Achievements
        Achievement(
            id: "items_placed_bronze",
            type: .itemsPlaced,
            tier: .bronze,
            title: "Getting Started",
            description: "Place 5 items in your room",
            targetValue: 5,
            rewardCoins: 50,
            icon: "🏠"
        ),
        Achievement(
            id: "items_placed_silver",
            type: .itemsPlaced,
            tier: .silver,
            title: "Decorator",
            description: "Place 25 items in your room",
            targetValue: 25,
            rewardCoins: 150,
            icon: "🎨"
        ),
        Achievement(
            id: "items_placed_gold",
            type: .itemsPlaced,
            tier: .gold,
            title: "Interior Designer",
            description: "Place 50 items in your room",
            targetValue: 50,
            rewardCoins: 300,
            icon: "✨"
        ),
        Achievement(
            id: "items_placed_platinum",
            type: .itemsPlaced,
            tier: .platinum,
            title: "Master Designer",
            description: "Place 100 items in your room",
            targetValue: 100,
            rewardCoins: 500,
            icon: "👑"
        ),
        
        // Coins Earned Achievements
        Achievement(
            id: "coins_earned_bronze",
            type: .coinsEarned,
            tier: .bronze,
            title: "Penny Pincher",
            description: "Earn 1,000 coins",
            targetValue: 1000,
            rewardCoins: 100,
            icon: "💰"
        ),
        Achievement(
            id: "coins_earned_silver",
            type: .coinsEarned,
            tier: .silver,
            title: "Coin Collector",
            description: "Earn 5,000 coins",
            targetValue: 5000,
            rewardCoins: 250,
            icon: "💵"
        ),
        Achievement(
            id: "coins_earned_gold",
            type: .coinsEarned,
            tier: .gold,
            title: "Money Maker",
            description: "Earn 10,000 coins",
            targetValue: 10000,
            rewardCoins: 500,
            icon: "💸"
        ),
        Achievement(
            id: "coins_earned_platinum",
            type: .coinsEarned,
            tier: .platinum,
            title: "Tycoon",
            description: "Earn 50,000 coins",
            targetValue: 50000,
            rewardCoins: 1000,
            icon: "🏦"
        ),
        
        // Pets Owned Achievements
        Achievement(
            id: "pets_owned_bronze",
            type: .petsOwned,
            tier: .bronze,
            title: "Pet Lover",
            description: "Own 1 pet",
            targetValue: 1,
            rewardCoins: 100,
            icon: "🐾"
        ),
        Achievement(
            id: "pets_owned_silver",
            type: .petsOwned,
            tier: .silver,
            title: "Pet Collector",
            description: "Own 5 pets",
            targetValue: 5,
            rewardCoins: 250,
            icon: "🐕"
        ),
        Achievement(
            id: "pets_owned_gold",
            type: .petsOwned,
            tier: .gold,
            title: "Pet Enthusiast",
            description: "Own 10 pets",
            targetValue: 10,
            rewardCoins: 500,
            icon: "🐈"
        ),
        
        // Plants Owned Achievements
        Achievement(
            id: "plants_owned_bronze",
            type: .plantsOwned,
            tier: .bronze,
            title: "Green Thumb",
            description: "Own 3 plants",
            targetValue: 3,
            rewardCoins: 75,
            icon: "🌱"
        ),
        Achievement(
            id: "plants_owned_silver",
            type: .plantsOwned,
            tier: .silver,
            title: "Plant Parent",
            description: "Own 10 plants",
            targetValue: 10,
            rewardCoins: 200,
            icon: "🌿"
        ),
        Achievement(
            id: "plants_owned_gold",
            type: .plantsOwned,
            tier: .gold,
            title: "Botanist",
            description: "Own 20 plants",
            targetValue: 20,
            rewardCoins: 400,
            icon: "🪴"
        ),
        
        // Room Themes Achievements
        Achievement(
            id: "room_themes_bronze",
            type: .roomThemes,
            tier: .bronze,
            title: "Theme Explorer",
            description: "Try 3 different room themes",
            targetValue: 3,
            rewardCoins: 150,
            icon: "🎭"
        ),
        Achievement(
            id: "room_themes_silver",
            type: .roomThemes,
            tier: .silver,
            title: "Style Switcher",
            description: "Try 7 different room themes",
            targetValue: 7,
            rewardCoins: 300,
            icon: "🌈"
        ),
        Achievement(
            id: "room_themes_gold",
            type: .roomThemes,
            tier: .gold,
            title: "Theme Master",
            description: "Try all room themes",
            targetValue: 15,
            rewardCoins: 600,
            icon: "🎨"
        ),
        
        // Daily Login Achievements
        Achievement(
            id: "daily_login_bronze",
            type: .dailyLogins,
            tier: .bronze,
            title: "Regular Visitor",
            description: "Login 7 days in a row",
            targetValue: 7,
            rewardCoins: 200,
            icon: "📅"
        ),
        Achievement(
            id: "daily_login_silver",
            type: .dailyLogins,
            tier: .silver,
            title: "Dedicated Player",
            description: "Login 30 days in a row",
            targetValue: 30,
            rewardCoins: 500,
            icon: "🗓️"
        ),
        Achievement(
            id: "daily_login_gold",
            type: .dailyLogins,
            tier: .gold,
            title: "Loyal Fan",
            description: "Login 100 days in a row",
            targetValue: 100,
            rewardCoins: 1000,
            icon: "⭐"
        ),
        
        // Furniture Owned Achievements
        Achievement(
            id: "furniture_owned_bronze",
            type: .furnitureOwned,
            tier: .bronze,
            title: "Furniture Fan",
            description: "Own 10 furniture items",
            targetValue: 10,
            rewardCoins: 100,
            icon: "🪑"
        ),
        Achievement(
            id: "furniture_owned_silver",
            type: .furnitureOwned,
            tier: .silver,
            title: "Furniture Collector",
            description: "Own 25 furniture items",
            targetValue: 25,
            rewardCoins: 250,
            icon: "🛋️"
        ),
        Achievement(
            id: "furniture_owned_gold",
            type: .furnitureOwned,
            tier: .gold,
            title: "Furniture Hoarder",
            description: "Own 50 furniture items",
            targetValue: 50,
            rewardCoins: 500,
            icon: "🏡"
        ),
    ]
}

// MARK: - Daily Task Catalog
struct DailyTaskCatalog {
    static let allTasks: [DailyTask] = [
        DailyTask(
            id: "daily_place_items",
            title: "Redecorate",
            description: "Place 3 items in your room",
            targetValue: 3,
            rewardCoins: 50,
            icon: "🪑",
            taskType: .itemsPlaced
        ),
        DailyTask(
            id: "daily_buy_item",
            title: "Shopping Spree",
            description: "Purchase 1 item from the shop",
            targetValue: 1,
            rewardCoins: 75,
            icon: "🛒",
            taskType: .itemsPurchased
        ),
        DailyTask(
            id: "daily_change_theme",
            title: "Fresh Look",
            description: "Change your room theme",
            targetValue: 1,
            rewardCoins: 100,
            icon: "🎨",
            taskType: .roomThemes
        ),
    ]
    
    static func generateDailyTasks() -> [DailyTask] {
        // Return a random selection of 3 tasks
        return Array(allTasks.shuffled().prefix(3))
    }
}

// MARK: - Daily Reward Catalog
struct DailyRewardCatalog {
    static let rewards: [DailyReward] = [
        DailyReward(day: 1, coins: 50, bonusItem: nil),
        DailyReward(day: 2, coins: 75, bonusItem: nil),
        DailyReward(day: 3, coins: 100, bonusItem: nil),
        DailyReward(day: 4, coins: 125, bonusItem: nil),
        DailyReward(day: 5, coins: 150, bonusItem: nil),
        DailyReward(day: 6, coins: 200, bonusItem: nil),
        DailyReward(day: 7, coins: 500, bonusItem: "rug_1"), // Bonus item on day 7
    ]
    
    static func getReward(for day: Int) -> DailyReward {
        let index = (day - 1) % rewards.count
        return rewards[index]
    }
}
