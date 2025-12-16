//
//  BreakSession.swift
//  benk
//
//  Created on 2025-12-13
//

import Foundation
import SwiftData

@Model
final class BreakSession {
    var id: UUID
    var duration: Int // in seconds
    var timestamp: Date
    var tag: String // e.g. "#meals", "#rest"
    
    init(
        id: UUID = UUID(),
        duration: Int,
        timestamp: Date = Date(),
        tag: String
    ) {
        self.id = id
        self.duration = duration
        self.timestamp = timestamp
        self.tag = tag
    }
    
    var formattedDuration: String {
        let minutes = duration / 60
        let seconds = duration % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
