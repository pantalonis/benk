//
//  Event.swift
//  benk
//
//  Created on 2025-12-15
//

import Foundation
import SwiftUI
import SwiftData

@Model
final class Event {
    var id: UUID
    var title: String
    var location: String
    var startTime: Date
    var endTime: Date
    var isAllDay: Bool
    var repeatOption: RepeatOption
    var alertsRaw: String // Stored as comma-separated minutes before event
    var notes: String
    var colorHex: String
    var url: String
    var isMultiDay: Bool
    
    // Computed property for alerts
    var alerts: [Int] {
        get {
            alertsRaw.isEmpty ? [] : alertsRaw.components(separatedBy: ",").compactMap { Int($0) }
        }
        set {
            alertsRaw = newValue.map { String($0) }.joined(separator: ",")
        }
    }
    
    var color: Color {
        Color(hex: colorHex) ?? .blue
    }
    
    init(
        id: UUID = UUID(),
        title: String,
        location: String = "",
        startTime: Date = Date(),
        endTime: Date = Date().addingTimeInterval(3600), // 1 hour default
        isAllDay: Bool = false,
        repeatOption: RepeatOption = .none,
        alerts: [Int] = [15], // 15 minutes before
        notes: String = "",
        colorHex: String = "#007AFF",
        url: String = "",
        isMultiDay: Bool = false
    ) {
        self.id = id
        self.title = title
        self.location = location
        self.startTime = startTime
        self.endTime = endTime
        self.isAllDay = isAllDay
        self.repeatOption = repeatOption
        self.alertsRaw = alerts.map { String($0) }.joined(separator: ",")
        self.notes = notes
        self.colorHex = colorHex
        self.url = url
        self.isMultiDay = isMultiDay
    }
}

// MARK: - Repeat Options
enum RepeatOption: String, Codable, CaseIterable {
    case none = "None"
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case yearly = "Yearly"
    
    var displayName: String {
        self.rawValue
    }
}
