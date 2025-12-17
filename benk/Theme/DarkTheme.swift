//
//  DarkTheme.swift
//  benk
//
//  Obsidian Glass - Premium dark liquid glass theme
//

import SwiftUI

struct DarkTheme: AppTheme {
    let id = "dark"
    let name = "Obsidian Glass"
    let price = 0 // Free (default)
    let isDark = true
    
    var background: LinearGradient {
        LinearGradient(
            colors: [
                Color(hex: "#0A0A0F") ?? .black,       // Deep obsidian
                Color(hex: "#12121A") ?? .black,       // Dark slate
                Color(hex: "#1A1A28") ?? .black,       // Subtle navy tint
                Color(hex: "#0E0E14") ?? .black        // Back to deep
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var surface: Color {
        Color(hex: "#1E1E2E")?.opacity(0.45) ?? .white.opacity(0.05)
    }
    
    var primary: Color {
        Color(hex: "#A78BFA") ?? .purple  // Soft violet
    }
    
    var accent: Color {
        Color(hex: "#22D3EE") ?? .cyan    // Electric cyan
    }
    
    var text: Color {
        Color(hex: "#F8FAFC") ?? .white   // Pure white for readability
    }
    
    var textSecondary: Color {
        Color(hex: "#94A3B8") ?? .gray    // Soft slate for secondary
    }
    
    var glow: Color {
        Color(hex: "#6366F1") ?? .purple  // Indigo glow
    }
    
    var hasGlow: Bool { true }
}
