//
//  ChristmasTheme.swift
//  benk
//
//  Created on 2025-12-15
//

import SwiftUI

struct ChristmasNightTheme: AppTheme {
    let id = "christmas_night"
    let name = "Christmas Night"
    let price = 500
    let isDark = true
    
    var background: LinearGradient {
        LinearGradient(
            colors: [
                Color(hex: "#0A1628") ?? .black, // Deep night blue
                Color(hex: "#1A237E") ?? .indigo, // Dark indigo
                Color(hex: "#0D2137") ?? .blue   // Midnight blue
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    var surface: Color { Color(hex: "#1C2951") ?? .blue.opacity(0.3) }
    var primary: Color { Color(hex: "#C41E3A") ?? .red } // Christmas red
    var accent: Color { Color(hex: "#228B22") ?? .green } // Christmas green
    var text: Color { .white }
    var textSecondary: Color { Color(hex: "#B0C4DE") ?? .gray } // Light steel blue
    var glow: Color { Color(hex: "#FFD700") ?? .yellow } // Gold glow
    
    // Effects
    var hasGlow: Bool { true }
    var hasStars: Bool { true }
    var hasSnow: Bool { true }
    var hasSanta: Bool { true }
    var isChristmas: Bool { true }
}


