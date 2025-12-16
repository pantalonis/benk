//
//  Subject.swift
//  benk
//
//  Created on 2025-12-11
//

import Foundation
import SwiftUI
import SwiftData

@Model
final class Subject {
    var id: UUID
    var name: String
    var colorHex: String
    var iconName: String
    var totalSeconds: Int = 0
    var lastStudied: Date?
    
    var totalMinutes: Int {
        get { totalSeconds / 60 }
        set { totalSeconds = newValue * 60 }
    }
    
    init(
        id: UUID = UUID(),
        name: String,
        colorHex: String,
        iconName: String,
        totalSeconds: Int = 0,
        lastStudied: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.colorHex = colorHex
        self.iconName = iconName
        self.totalSeconds = totalSeconds
        self.lastStudied = lastStudied
    }
    
    // Convenience init for backward compatibility or minutes-based creation
    init(
        id: UUID = UUID(),
        name: String,
        colorHex: String,
        iconName: String,
        totalMinutes: Int,
        lastStudied: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.colorHex = colorHex
        self.iconName = iconName
        self.totalSeconds = totalMinutes * 60
        self.lastStudied = lastStudied
    }
    
    var color: Color {
        Color(hex: colorHex) ?? .blue
    }
}

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        self.init(
            red: Double((rgb & 0xFF0000) >> 16) / 255.0,
            green: Double((rgb & 0x00FF00) >> 8) / 255.0,
            blue: Double(rgb & 0x0000FF) / 255.0
        )
    }
    
    func toHex() -> String? {
        guard let components = UIColor(self).cgColor.components, components.count >= 3 else {
            return nil
        }
        
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        
        return String(format: "#%02lX%02lX%02lX",
                     lroundf(r * 255),
                     lroundf(g * 255),
                     lroundf(b * 255))
    }
}
