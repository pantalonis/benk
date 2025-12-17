//
//  CloudyDayTheme.swift
//  benk
//
//  Serene Sky - Peaceful liquid glass theme with floating clouds
//

import SwiftUI

struct CloudyDayTheme: AppTheme {
    let id = "cloudyday"
    let name = "Serene Sky"
    let price = 350
    let isDark = false
    
    var background: LinearGradient {
        LinearGradient(
            colors: [
                Color(hex: "#A8D5F2") ?? .blue,        // Soft azure
                Color(hex: "#89C4E8") ?? .blue,        // Sky blue
                Color(hex: "#B8D4E8") ?? .blue,        // Pale blue
                Color(hex: "#D4E5F2") ?? .blue         // Light lavender hint
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    var surface: Color {
        Color.white.opacity(0.80)
    }
    
    var primary: Color {
        Color(hex: "#3B82F6") ?? .blue    // Vivid blue
    }
    
    var accent: Color {
        Color(hex: "#06B6D4") ?? .cyan    // Teal accent
    }
    
    var text: Color {
        Color(hex: "#1E3A5F") ?? .blue    // Deep navy for readability
    }
    
    var textSecondary: Color {
        Color(hex: "#4A6B8A") ?? .gray    // Slate blue
    }
    
    var glow: Color {
        Color.white.opacity(0.6)
    }
    
    var hasClouds: Bool { true }
    var hasGlow: Bool { true }
}
