//
//  LightTheme.swift
//  benk
//
//  Frosted Pearl - Premium light liquid glass theme
//

import SwiftUI

struct LightTheme: AppTheme {
    let id = "light"
    let name = "Frosted Pearl"
    let price = 0 // Free (default)
    let isDark = false
    
    var background: LinearGradient {
        LinearGradient(
            colors: [
                Color(hex: "#FAFBFC") ?? .white,       // Soft pearl white
                Color(hex: "#EFF2F7") ?? .white,       // Silver mist
                Color(hex: "#E2E8F0") ?? .gray,        // Light slate
                Color(hex: "#F1F5F9") ?? .white        // Airy fade
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var surface: Color {
        Color.white.opacity(0.75)
    }
    
    var primary: Color {
        Color(hex: "#7C3AED") ?? .purple  // Vibrant violet
    }
    
    var accent: Color {
        Color(hex: "#F472B6") ?? .pink    // Rose pink
    }
    
    var text: Color {
        Color(hex: "#0F172A") ?? .black   // Deep navy for readability
    }
    
    var textSecondary: Color {
        Color(hex: "#475569") ?? .gray    // Slate for secondary
    }
    
    var glow: Color {
        Color(hex: "#A78BFA")?.opacity(0.4) ?? .purple.opacity(0.4)
    }
    
    var hasGlow: Bool { true }
}
