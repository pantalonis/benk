//
//  UserProfile.swift
//  benk
//
//  Created on 2025-12-11
//

import Foundation
import SwiftData

@Model
final class UserProfile {
    var id: UUID
    var xp: Int
    var level: Int
    var coins: Int
    var currentStreak: Int
    var longestStreak: Int
    var lastStudyDate: Date?
    var ownedThemeIdsRaw: String = "light,dark" // Stored as CSV to avoid CoreData Array crash
    var currentThemeId: String
    var dailyGoalMinutes: Int
    var monthlyStudyGoalHours: Double
    var username: String
    var avatarImageName: String?
    var createdAt: Date
    var selectedTitleBadgeId: UUID?  // Currently equipped title badge
    var widgetOrderRaw: String = "0,1,2,3,4" // Widget order stored as CSV
    
    // Computed property for easy access
    var ownedThemeIds: [String] {
        get {
            ownedThemeIdsRaw.components(separatedBy: ",")
        }
        set {
            ownedThemeIdsRaw = newValue.joined(separator: ",")
        }
    }
    
    // Widget order computed property
    var widgetOrder: [Int] {
        get {
            widgetOrderRaw.components(separatedBy: ",").compactMap { Int($0) }
        }
        set {
            widgetOrderRaw = newValue.map { String($0) }.joined(separator: ",")
        }
    }
    
    init(
        id: UUID = UUID(),
        xp: Int = 0,
        level: Int = 1,
        coins: Int = 10000,
        currentStreak: Int = 0,
        longestStreak: Int = 0,
        lastStudyDate: Date? = nil,
        ownedThemeIds: [String] = ["light", "dark"],
        currentThemeId: String = "dark",
        dailyGoalMinutes: Int = 60,
        monthlyStudyGoalHours: Double = 0,
        username: String = "Student",
        avatarImageName: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.xp = xp
        self.level = level
        self.coins = coins
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.lastStudyDate = lastStudyDate
        self.ownedThemeIdsRaw = ownedThemeIds.joined(separator: ",")
        self.currentThemeId = currentThemeId
        self.dailyGoalMinutes = dailyGoalMinutes
        self.monthlyStudyGoalHours = monthlyStudyGoalHours
        self.username = username
        self.avatarImageName = avatarImageName
        self.createdAt = createdAt
    }
    
    
    var xpForNextLevel: Int {
        // Use XPService formula: (level + 1)^2 * 25
        // Or proposed gentler: let nextLevel = level + 1; return nextLevel * 25 + xpForCurrentLevel?
        // Let's stick to the user request of "Start at 25 XP".
        // If Level 1 -> 2 needs 25 XP.
        // User said 25 -> 100 -> 225 is too hard. (1*25, 4*25, 9*25)
        // Let's use triangular numbers * 25?
        // L1: 0. L2: 25. L3: 25+50=75. L4: 75+75=150.
        // Formula for XP needed for Level L: 25 * (L-1) * L / 2 ? No.
        // Let's use generic multiplier:
        // Level 1: 0 - 24
        // Level 2: 25 - ...
        // If we want L2->3 to be easier than 100 total.
        // Let's try constant increment of difficulty:
        // L1 needs 25. L2 needs 50. L3 needs 75.
        // Total XP for Level L = 25 * (L * (L-1) / 2) -> 12.5 * L^2 approx.
        // L1=0. L2=25. L3=75. L4=150.
        // This is much softer than 25, 100, 225.
        // Let's implement this "arithmetic progression" logic in XPService and call it here.
        // Ideally UserProfile should delegate to XPService but it's a model.
        // I'll replicate the logic or reference XPService.shared efficiently.
        XPService.xpForLevel(level + 1)
    }
    
    var xpForCurrentLevel: Int {
        XPService.xpForLevel(level)
    }
    
    var levelProgress: Double {
        let currentLevelXP = xpForCurrentLevel
        let nextLevelXP = xpForNextLevel
        let progressInLevel = xp - currentLevelXP
        let totalNeeded = nextLevelXP - currentLevelXP
        guard totalNeeded > 0 else { return 0 }
        return max(0, min(1.0, Double(progressInLevel) / Double(totalNeeded)))
    }
    
    var streakActive: Bool {
        guard let lastDate = lastStudyDate else { return false }
        return Calendar.current.isDateInToday(lastDate)
    }
}
