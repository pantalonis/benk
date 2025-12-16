//
//  XPService.swift
//  benk
//
//  Created on 2025-12-11
//

import Foundation
import SwiftData
import SwiftUI

@MainActor
class XPService: ObservableObject {
    static let shared = XPService()
    
    // Level up popup state
    @Published var showLevelUpPopup = false
    @Published var newLevel: Int = 0
    
    private init() {}
    
    /// Dismiss the level up popup
    func dismissLevelUpPopup() {
        showLevelUpPopup = false
        newLevel = 0
    }
    
    // XP calculation constants
    // XP calculation constants
    // 1 XP per minute (approx 0.0167 XP per second)
    
    /// Calculate XP earned from a study session
    func calculateXP(seconds: Int, technique: Technique?) -> Int {
        // 1 XP per minute
        // We use Int division, so < 60 seconds = 0 XP
        // To be generous for the second-accuracy update, we can use floating point then floor:
        // Actually, user standard is "1 min = 1 xp".
        // Let's allow fractional minutes to accumulate if we track it, but returning Int means we must floor or round.
        // Let's use simple division but maybe award at least 1 XP if seconds > 30?
        // User asked strict "1 min = 1 xp". Let's stick to seconds / 60.
        let baseXP = seconds / 60
        let multiplier = technique?.xpMultiplier ?? 1.0
        return max(0, Int(Double(baseXP) * multiplier))
    }
    
    /// Calculate level from total XP using arithmetic progression
    /// Level 1: 0-24 XP
    /// Level 2: 25-74 XP (needs 25 more)
    /// Level 3: 75-149 XP (needs 50 more)
    /// Level 4: 150-249 XP (needs 75 more)
    /// Total XP for level L = 12.5 * L * (L-1)
    /// Calculate level from total XP using arithmetic progression
    /// Level 1: 0-24 XP
    /// Level 2: 25-74 XP (needs 25 more)
    /// Level 3: 75-149 XP (needs 50 more)
    /// Level 4: 150-249 XP (needs 75 more)
    /// Total XP for level L = 12.5 * L * (L-1)
    static nonisolated func calculateLevel(xp: Int) -> Int {
        guard xp > 0 else { return 1 }
        
        // Inverse of triangular formula: 25 * n * (n-1) / 2 = XP
        // 12.5 * (n^2 - n) = XP
        // n^2 - n - (XP/12.5) = 0
        // quadratic formula: n = (1 + sqrt(1 + 4 * XP / 12.5)) / 2
        
        // 4 * XP / 12.5 = XP * 0.32
        // Let's re-derive carefully:
        // Total XP = 25 * n * (n-1) / 2 = 12.5 * (n^2 - n)
        // (xp / 12.5) = n^2 - n
        // n^2 - n - (xp / 12.5) = 0
        // n = [1 + sqrt(1 - 4(1)(-xp/12.5))] / 2
        // n = [1 + sqrt(1 + xp/3.125)] / 2
        
        let val = 1.0 + (Double(xp) / 3.125)
        let level = (1.0 + sqrt(val)) / 2.0
        return max(1, Int(level))
    }
    
    /// XP required to REACH a specific level
    /// e.g. Level 2 requires 25 total XP. Level 3 requires 75.
    static nonisolated func xpForLevel(_ level: Int) -> Int {
        if level <= 1 { return 0 }
        // Arithmetic sum formula: 25 + 50 + 75 + ...
        // Sum = (n/2) * (2*a + (n-1)d) where a=25, d=25
        // Or simpler: 25 * (level-1) * level / 2
        let n = level - 1
        return 25 * n * (n + 1) / 2
    }
    
    /// Get the theme color/glow for a specific level
    func getLevelColor(level: Int) -> Color {
        switch level {
        case 1...4: return .blue
        case 5...9: return .green
        case 10...14: return .cyan
        case 15...19: return .purple
        case 20...29: return .orange
        case 30...49: return .red
        case 50...: return .yellow // Gold
        default: return .blue
        }
    }
    
    /// Award XP to user and handle level ups
    func awardXP(_ amount: Int, to profile: UserProfile, context: ModelContext) -> (didLevelUp: Bool, newLevel: Int) {
        let oldLevel = profile.level
        profile.xp += amount
        profile.level = XPService.calculateLevel(xp: profile.xp)
        
        let didLevelUp = profile.level > oldLevel
        
        if didLevelUp {
            // Award coins for leveling up - use CurrencyManager directly
            let coinsReward = profile.level * 10
            CurrencyManager.shared.coins += coinsReward
            
            // Check for XP milestone badges
            checkXPBadges(for: profile, context: context)
            
            // Trigger level up popup
            newLevel = profile.level
            showLevelUpPopup = true
            HapticManager.shared.success()
        }
        
        try? context.save()
        return (didLevelUp, profile.level)
    }
    
    /// Check and update XP milestone badges
    private func checkXPBadges(for profile: UserProfile, context: ModelContext) {
        let descriptor = FetchDescriptor<Badge>(
            predicate: #Predicate<Badge> { $0.category == "xpMilestone" && !$0.isEarned }
        )
        
        guard let badges = try? context.fetch(descriptor) else { return }
        
        for badge in badges {
            if profile.xp >= badge.requirement {
                badge.isEarned = true
                badge.earnedDate = Date()
                CurrencyManager.shared.coins += 50 // Bonus coins for earning badge
            } else {
                badge.progress = profile.xp
            }
        }
    }
}
