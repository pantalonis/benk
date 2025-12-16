//
//  CustomReward.swift
//  benk
//
//  Created on 2025-12-11
//

import Foundation
import SwiftData

@Model
final class CustomReward {
    var id: UUID
    var title: String
    var iconName: String
    var requiredMinutes: Int
    var coinCost: Int
    var isClaimed: Bool
    var claimedAt: Date?
    var createdAt: Date
    
    init(
        id: UUID = UUID(),
        title: String,
        iconName: String = "star.fill",
        requiredMinutes: Int,
        coinCost: Int = 0,
        isClaimed: Bool = false,
        claimedAt: Date? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.iconName = iconName
        self.requiredMinutes = requiredMinutes
        self.coinCost = coinCost
        self.isClaimed = isClaimed
        self.claimedAt = claimedAt
        self.createdAt = createdAt
    }
}
