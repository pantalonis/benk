//
//  Badge.swift
//  benk
//
//  Created on 2025-12-11
//

import Foundation
import SwiftData
import SwiftUI

enum BadgeCategory: String, Codable, CaseIterable {
    case streak = "streak"
    case dailyGoal = "dailyGoal"
    case technique = "technique"
    case timeSpent = "timeSpent"
    case taskCompletion = "taskCompletion"
    case special = "special"
    case xpMilestone = "xpMilestone"
    case subjectMastery = "subjectMastery"
}

@Model
final class Badge {
    var id: UUID
    var name: String
    var titleName: String         // Short name for title display
    var badgeDescription: String  // Short description
    var lore: String              // Detailed story/lore text
    var iconName: String
    var category: String
    var requirement: Int
    var isEarned: Bool
    var earnedDate: Date?
    var progress: Int
    var sortOrder: Int            // For ordering within category
    var colorHex: String          // Badge color for visual differentiation
    
    init(
        id: UUID = UUID(),
        name: String,
        titleName: String? = nil,
        badgeDescription: String,
        lore: String = "",
        iconName: String,
        category: BadgeCategory,
        requirement: Int,
        isEarned: Bool = false,
        earnedDate: Date? = nil,
        progress: Int = 0,
        sortOrder: Int = 0,
        colorHex: String = "#808080"  // Default gray
    ) {
        self.id = id
        self.name = name
        self.titleName = titleName ?? name  // Default to name if no titleName provided
        self.badgeDescription = badgeDescription
        self.lore = lore
        self.iconName = iconName
        self.category = category.rawValue
        self.requirement = requirement
        self.isEarned = isEarned
        self.earnedDate = earnedDate
        self.progress = progress
        self.sortOrder = sortOrder
        self.colorHex = colorHex
    }
    
    var badgeCategory: BadgeCategory {
        BadgeCategory(rawValue: category) ?? .xpMilestone
    }
    
    var progressPercentage: Double {
        guard requirement > 0 else { return 0 }
        return min(Double(progress) / Double(requirement), 1.0)
    }
    
    var badgeColor: Color {
        Color(hex: colorHex) ?? .gray
    }
}
