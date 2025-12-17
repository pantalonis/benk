//
//  NightCityTheme.swift
//  benk
//
//  Neon Nights - Cyberpunk liquid glass theme
//

import SwiftUI

struct NightCityTheme: AppTheme {
    let id = "nightcity"
    let name = "Neon Nights"
    let price = 500
    let isDark = true
    
    var background: LinearGradient {
        LinearGradient(
            colors: [
                Color(hex: "#0D0015") ?? .black,       // Deep purple-black
                Color(hex: "#1A0A2E") ?? .purple,      // Dark violet
                Color(hex: "#16213E") ?? .blue,        // Midnight blue
                Color(hex: "#0F0818") ?? .black        // Back to dark
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var surface: Color {
        Color(hex: "#2D1B4E")?.opacity(0.5) ?? .purple.opacity(0.15)
    }
    
    var primary: Color {
        Color(hex: "#FF6B9D") ?? .pink    // Neon pink
    }
    
    var accent: Color {
        Color(hex: "#00E5FF") ?? .cyan    // Electric cyan
    }
    
    var text: Color {
        Color(hex: "#F8F8FF") ?? .white   // Ghost white for readability
    }
    
    var textSecondary: Color {
        Color(hex: "#B8A9D0") ?? .gray    // Soft lavender
    }
    
    var glow: Color {
        Color(hex: "#FF6B9D") ?? .pink    // Neon pink glow
    }
    
    var hasGlow: Bool { true }
}
