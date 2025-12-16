//
//  Exam.swift
//  benk
//
//  Created on 2025-12-15
//

import Foundation
import SwiftUI
import SwiftData

@Model
final class Exam {
    var id: UUID
    var subjectId: UUID?
    var paperName: String // Paper name (e.g., "P1", "Paper 2", etc.)
    var examDate: Date
    var duration: Int? // Duration in minutes (optional)
    var examDescription: String
    var alertsRaw: String // Stored as comma-separated minutes before exam
    
    // Computed property for alerts
    var alerts: [Int] {
        get {
            alertsRaw.isEmpty ? [] : alertsRaw.components(separatedBy: ",").compactMap { Int($0) }
        }
        set {
            alertsRaw = newValue.map { String($0) }.joined(separator: ",")
        }
    }
    
    // Computed property: Days until exam
    var daysUntil: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: examDate).day ?? 0
    }
    
    // Computed property: Countdown text
    var countdownText: String {
        let days = daysUntil
        if days < 0 {
            return "Past"
        } else if days == 0 {
            return "Today"
        } else if days == 1 {
            return "Tomorrow"
        } else {
            return "in \(days) days"
        }
    }
    
    // Computed property: Is exam today
    var isToday: Bool {
        Calendar.current.isDateInToday(examDate)
    }
    
    // Computed property: Urgency level for color coding
    var urgency: UrgencyLevel {
        let days = daysUntil
        if days < 0 {
            return .past
        } else if days == 0 {
            return .today
        } else if days <= 3 {
            return .urgent
        } else if days <= 7 {
            return .soon
        } else {
            return .distant
        }
    }
    
    init(
        id: UUID = UUID(),
        subjectId: UUID? = nil,
        paperName: String = "",
        examDate: Date = Date(),
        duration: Int? = nil,
        examDescription: String = "",
        alerts: [Int] = [60, 1440] // 1 hour and 1 day before
    ) {
        self.id = id
        self.subjectId = subjectId
        self.paperName = paperName
        self.examDate = examDate
        self.duration = duration
        self.examDescription = examDescription
        self.alertsRaw = alerts.map { String($0) }.joined(separator: ",")
    }
}

// MARK: - Urgency Level
enum UrgencyLevel {
    case past
    case today
    case urgent // 1-3 days
    case soon // 4-7 days
    case distant // 8+ days
    
    var color: Color {
        switch self {
        case .past:
            return .gray
        case .today:
            return .red
        case .urgent:
            return .orange
        case .soon:
            return .yellow
        case .distant:
            return .green
        }
    }
}
