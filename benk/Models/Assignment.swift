//
//  Assignment.swift
//  benk
//
//  Created on 2025-12-15
//

import Foundation
import SwiftUI
import SwiftData

@Model
final class Assignment {
    var id: UUID
    var subjectId: UUID?
    var title: String
    var dueDate: Date
    var estimatedEffortHours: Double
    var priority: Priority
    var status: AssignmentStatus
    var notes: String
    
    // Computed property: Days until due
    var daysUntil: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: dueDate).day ?? 0
    }
    
    // Computed property: Countdown text
    var countdownText: String {
        let days = daysUntil
        if days < 0 {
            return "Overdue"
        } else if days == 0 {
            return "Due Today"
        } else if days == 1 {
            return "Due Tomorrow"
        } else {
            return "Due in \(days) days"
        }
    }
    
    // Computed property: Is overdue
    var isOverdue: Bool {
        daysUntil < 0 && status != .completed
    }
    
    // Computed property: Is due today
    var isDueToday: Bool {
        Calendar.current.isDateInToday(dueDate)
    }
    
    // Computed property: Urgency based on due date and priority
    var urgency: Int {
        let basePriority = priority.weight
        let days = daysUntil
        
        // Higher urgency for closer deadlines
        if days < 0 {
            return basePriority + 100 // Overdue gets highest urgency
        } else if days == 0 {
            return basePriority + 50
        } else if days <= 3 {
            return basePriority + 20
        } else if days <= 7 {
            return basePriority + 10
        } else {
            return basePriority
        }
    }
    
    // Computed property: Display color based on urgency
    var urgencyColor: Color {
        if isOverdue {
            return .red
        } else if isDueToday {
            return .orange
        } else if daysUntil <= 3 {
            return priority.color
        } else {
            return priority.color.opacity(0.7)
        }
    }
    
    init(
        id: UUID = UUID(),
        subjectId: UUID? = nil,
        title: String,
        dueDate: Date = Date().addingTimeInterval(7 * 24 * 3600), // 1 week default
        estimatedEffortHours: Double = 1.0,
        priority: Priority = .medium,
        status: AssignmentStatus = .notStarted,
        notes: String = ""
    ) {
        self.id = id
        self.subjectId = subjectId
        self.title = title
        self.dueDate = dueDate
        self.estimatedEffortHours = estimatedEffortHours
        self.priority = priority
        self.status = status
        self.notes = notes
    }
}

// MARK: - Priority
enum Priority: String, Codable, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    
    var displayName: String {
        self.rawValue
    }
    
    var color: Color {
        switch self {
        case .low:
            return .green
        case .medium:
            return .yellow
        case .high:
            return .red
        }
    }
    
    var weight: Int {
        switch self {
        case .low:
            return 1
        case .medium:
            return 5
        case .high:
            return 10
        }
    }
}

// MARK: - Assignment Status
enum AssignmentStatus: String, Codable, CaseIterable {
    case notStarted = "Not Started"
    case inProgress = "In Progress"
    case completed = "Completed"
    
    var displayName: String {
        self.rawValue
    }
    
    var icon: String {
        switch self {
        case .notStarted:
            return "circle"
        case .inProgress:
            return "circle.lefthalf.filled"
        case .completed:
            return "checkmark.circle.fill"
        }
    }
}
