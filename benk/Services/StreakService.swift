//
//  StreakService.swift
//  benk
//
//  Created on 2025-12-11
//

import Foundation
import SwiftData

@MainActor
class StreakService: ObservableObject {
    static let shared = StreakService()
    
    private init() {}
    
    /// Update user's streak based on study activity
    func updateStreak(for profile: UserProfile, context: ModelContext) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        guard let lastStudyDate = profile.lastStudyDate else {
            // First time studying
            profile.currentStreak = 1
            profile.lastStudyDate = Date()
            checkStreakBadges(for: profile, context: context)
            try? context.save()
            return
        }
        
        let lastStudyDay = calendar.startOfDay(for: lastStudyDate)
        
        if calendar.isDate(lastStudyDay, inSameDayAs: today) {
            // Already studied today, no change to streak
            return
        }
        
        let daysSinceLastStudy = calendar.dateComponents([.day], from: lastStudyDay, to: today).day ?? 0
        
        if daysSinceLastStudy == 1 {
            // Studied yesterday, increment streak
            profile.currentStreak += 1
            profile.lastStudyDate = Date()
            
            if profile.currentStreak > profile.longestStreak {
                profile.longestStreak = profile.currentStreak
            }
            
            checkStreakBadges(for: profile, context: context)
        } else {
            // Missed a day, reset streak
            profile.currentStreak = 1
            profile.lastStudyDate = Date()
        }
        
        try? context.save()
    }
    
    /// Check if user's streak is still active (studied today)
    func isStreakActive(for profile: UserProfile) -> Bool {
        guard let lastStudyDate = profile.lastStudyDate else { return false }
        return Calendar.current.isDateInToday(lastStudyDate)
    }
    
    /// Check and update streak milestone badges
    private func checkStreakBadges(for profile: UserProfile, context: ModelContext) {
        let descriptor = FetchDescriptor<Badge>(
            predicate: #Predicate<Badge> { $0.category == "streak" && !$0.isEarned }
        )
        
        guard let badges = try? context.fetch(descriptor) else { return }
        
        for badge in badges {
            if profile.currentStreak >= badge.requirement {
                badge.isEarned = true
                badge.earnedDate = Date()
                badge.progress = badge.requirement
                CurrencyManager.shared.coins += 100 // Bonus coins for streak badges
                try? context.save()
                // Queue badge for popup using BadgeService
                BadgeService.shared.queueBadgeForPopup(badge)
            } else {
                badge.progress = profile.currentStreak
            }
        }
    }
}
