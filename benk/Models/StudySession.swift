//
//  StudySession.swift
//  benk
//
//  Created on 2025-12-11
//

import Foundation
import SwiftData

@Model
final class StudySession {
    var id: UUID
    var duration: Int // in seconds
    var xpEarned: Int
    var timestamp: Date
    var completedAt: Date?
    var subjectId: UUID?
    var techniqueId: UUID?
    var isCompleted: Bool
    
    init(
        id: UUID = UUID(),
        duration: Int,
        xpEarned: Int = 0,
        timestamp: Date = Date(),
        completedAt: Date? = nil,
        subjectId: UUID? = nil,
        techniqueId: UUID? = nil,
        isCompleted: Bool = false
    ) {
        self.id = id
        self.duration = duration
        self.xpEarned = xpEarned
        self.timestamp = timestamp
        self.completedAt = completedAt
        self.subjectId = subjectId
        self.techniqueId = techniqueId
        self.isCompleted = isCompleted
    }
    
    var durationInMinutes: Int {
        duration / 60
    }
}
