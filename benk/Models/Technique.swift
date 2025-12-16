//
//  Technique.swift
//  benk
//
//  Created on 2025-12-11
//

import Foundation
import SwiftData

@Model
final class Technique {
    var id: UUID
    var name: String
    var techniqueDescription: String
    var iconName: String
    var xpMultiplier: Double
    var category: String = "General"
    var subcategory: String?
    var effectivenessRating: Int = 5
    
    init(
        id: UUID = UUID(),
        name: String,
        techniqueDescription: String,
        iconName: String,
        xpMultiplier: Double = 1.0,
        category: String = "General",
        subcategory: String? = nil,
        effectivenessRating: Int = 5
    ) {
        self.id = id
        self.name = name
        self.techniqueDescription = techniqueDescription
        self.iconName = iconName
        self.xpMultiplier = xpMultiplier
        self.category = category
        self.subcategory = subcategory
        self.effectivenessRating = effectivenessRating
    }
}

