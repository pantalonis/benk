//
//  Quest.swift
//  benk
//
//  Created on 2025-12-11
//

import Foundation
import SwiftData

enum QuestType: String, Codable {
    case daily
    case weekly
}

@Model
final class Quest {
    var id: UUID
    var title: String
    var questDescription: String
    var type: String // "daily" or "weekly"
    var progress: Int
    var target: Int
    var xpReward: Int
    var coinReward: Int
    var isClaimed: Bool
    var expiresAt: Date
    var createdAt: Date
    
    init(
        id: UUID = UUID(),
        title: String,
        questDescription: String,
        type: QuestType,
        progress: Int = 0,
        target: Int,
        xpReward: Int,
        coinReward: Int = 0,
        isClaimed: Bool = false,
        expiresAt: Date,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.questDescription = questDescription
        self.type = type.rawValue
        self.progress = progress
        self.target = target
        self.xpReward = xpReward
        self.coinReward = coinReward
        self.isClaimed = isClaimed
        self.expiresAt = expiresAt
        self.createdAt = createdAt
    }
    
    var questType: QuestType {
        QuestType(rawValue: type) ?? .daily
    }
    
    var isCompleted: Bool {
        progress >= target
    }
    
    var canClaim: Bool {
        isCompleted && !isClaimed && Date() < expiresAt
    }
    
    var progressPercentage: Double {
        guard target > 0 else { return 0 }
        return min(Double(progress) / Double(target), 1.0)
    }
    
    var isExpired: Bool {
        Date() >= expiresAt
    }
}
