//
//  Task.swift
//  benk
//
//  Created on 2025-12-11
//

import Foundation
import SwiftData

@Model
final class Task {
    var id: UUID
    var title: String
    var isCompleted: Bool
    var xpReward: Int
    var createdAt: Date
    var completedAt: Date?
    var subjectId: UUID?
    
    init(
        id: UUID = UUID(),
        title: String,
        isCompleted: Bool = false,
        xpReward: Int = 50,
        createdAt: Date = Date(),
        completedAt: Date? = nil,
        subjectId: UUID? = nil
    ) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.xpReward = xpReward
        self.createdAt = createdAt
        self.completedAt = completedAt
        self.subjectId = subjectId
    }
}
