//
//  QuestService.swift
//  benk
//
//  Created on 2025-12-11
//

import Foundation
import SwiftData

@MainActor
class QuestService: ObservableObject {
    static let shared = QuestService()
    
    private init() {}
    
    // Quest templates
    private let dailyQuestTemplates: [(title: String, description: String, target: Int, xp: Int, coins: Int)] = [
        ("Morning Warrior", "Study for 30 minutes", 30, 100, 20),
        ("Task Master", "Complete 3 tasks", 3, 80, 15),
        ("Focus Champion", "Complete 1 pomodoro session", 1, 60, 10),
        ("Quick Win", "Study for 15 minutes", 15, 50, 10),
        ("Subject Explorer", "Study 2 different subjects", 2, 90, 18)
    ]
    
    private let weeklyQuestTemplates: [(title: String, description: String, target: Int, xp: Int, coins: Int)] = [
        ("Weekly Grind", "Study for 300 minutes this week", 300, 500, 100),
        ("Streak Keeper", "Maintain a 7-day streak", 7, 400, 80),
        ("Task Crusher", "Complete 20 tasks this week", 20, 350, 70),
        ("Subject Master", "Study all subjects this week", 5, 450, 90),
        ("Pomodoro Pro", "Complete 15 pomodoro sessions", 15, 380, 75)
    ]
    
    /// Check and generate daily quests if needed
    func checkAndGenerateDailyQuests(context: ModelContext) {
        let calendar = Calendar.current
        let _ = calendar.startOfDay(for: Date())
        
        let descriptor = FetchDescriptor<Quest>(
            predicate: #Predicate<Quest> { $0.type == "daily" }
        )
        
        guard let quests = try? context.fetch(descriptor) else { return }
        
        // Check if we have valid daily quests for today
        let validQuests = quests.filter { quest in
            return quest.expiresAt > Date()
        }
        
        if validQuests.count < 3 {
            // Remove expired quests
            quests.forEach { context.delete($0) }
            
            // Generate new daily quests
            generateDailyQuests(context: context)
        }
    }
    
    private func generateDailyQuests(context: ModelContext) {
        let calendar = Calendar.current
        let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: Date()) ?? Date()
        
        // Select 3 random quest templates
        let selectedTemplates = dailyQuestTemplates.shuffled().prefix(3)
        
        for template in selectedTemplates {
            let quest = Quest(
                title: template.title,
                questDescription: template.description,
                type: .daily,
                target: template.target,
                xpReward: template.xp,
                coinReward: template.coins,
                expiresAt: endOfDay
            )
            context.insert(quest)
        }
        
        try? context.save()
    }
    
    /// Check and generate weekly quests if needed
    func checkAndGenerateWeeklyQuests(context: ModelContext) {
        let _ = Calendar.current
        
        let descriptor = FetchDescriptor<Quest>(
            predicate: #Predicate<Quest> { $0.type == "weekly" }
        )
        
        guard let quests = try? context.fetch(descriptor) else { return }
        
        let validQuests = quests.filter { $0.expiresAt > Date() }
        
        if validQuests.count < 3 {
            // Remove expired quests
            quests.forEach { context.delete($0) }
            
            // Generate new weekly quests
            generateWeeklyQuests(context: context)
        }
    }
    
    private func generateWeeklyQuests(context: ModelContext) {
        let calendar = Calendar.current
        
        // Set expiration to end of next Sunday
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        components.weekOfYear! += 1
        components.weekday = 1 // Sunday
        
        let endOfWeek = calendar.date(from: components) ?? Date().addingTimeInterval(7 * 24 * 60 * 60)
        
        // Select 3 random quest templates
        let selectedTemplates = weeklyQuestTemplates.shuffled().prefix(3)
        
        for template in selectedTemplates {
            let quest = Quest(
                title: template.title,
                questDescription: template.description,
                type: .weekly,
                target: template.target,
                xpReward: template.xp,
                coinReward: template.coins,
                expiresAt: endOfWeek
            )
            context.insert(quest)
        }
        
        try? context.save()
    }
    
    /// Update quest progress
    func updateQuestProgress(_ questId: UUID, increment: Int, context: ModelContext) {
        let descriptor = FetchDescriptor<Quest>(
            predicate: #Predicate<Quest> { $0.id == questId }
        )
        
        guard let quests = try? context.fetch(descriptor),
              let quest = quests.first else { return }
        
        quest.progress = min(quest.progress + increment, quest.target)
        try? context.save()
    }
    
    /// Claim a completed quest
    func claimQuest(_ quest: Quest, profile: UserProfile, context: ModelContext) -> Bool {
        guard quest.canClaim else { return false }
        
        quest.isClaimed = true
        profile.xp += quest.xpReward
        
        // Add coins to CurrencyManager (the single source)
        CurrencyManager.shared.coins += quest.coinReward
        
        // Recalculate level
        profile.level = XPService.calculateLevel(xp: profile.xp)
        
        try? context.save()
        
        HapticManager.shared.success()
        return true
    }
}

