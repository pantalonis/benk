//
//  LightTheme.swift
//  benk
//
//  Created on 2025-12-11
//

import SwiftUI

struct LightTheme: AppTheme {
    let id = "light"
    let name = "Light Glass"
    let price = 0 // Free (default)
    let isDark = false
    
    var background: LinearGradient {
        LinearGradient(
            colors: [
                Color(hex: "#F0F4F8") ?? .white,
                Color(hex: "#D9E2EC") ?? .gray,
                Color(hex: "#BCCCDC") ?? .gray
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var surface: Color {
        Color.white.opacity(0.7)
    }
    
    var primary: Color {
        Color(hex: "#6366F1") ?? .blue
    }
    
    var accent: Color {
        Color(hex: "#EC4899") ?? .pink
    }
    
    var text: Color {
        Color(hex: "#1E293B") ?? .black
    }
    
    var textSecondary: Color {
        Color(hex: "#64748B") ?? .gray
    }
    
    var glow: Color {
        accent.opacity(0.3)
    }
}
