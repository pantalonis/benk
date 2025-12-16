//
//  DarkTheme.swift
//  benk
//
//  Created on 2025-12-11
//

import SwiftUI

struct DarkTheme: AppTheme {
    let id = "dark"
    let name = "Dark Glass"
    let price = 0 // Free (default)
    let isDark = true
    
    var background: LinearGradient {
        LinearGradient(
            colors: [
                Color(hex: "#0F0F23") ?? .black,
                Color(hex: "#1A1A2E") ?? .black,
                Color(hex: "#16213E") ?? .black
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var surface: Color {
        Color.white.opacity(0.05)
    }
    
    var primary: Color {
        Color(hex: "#BB86FC") ?? .purple
    }
    
    var accent: Color {
        Color(hex: "#03DAC6") ?? .cyan
    }
    
    var text: Color {
        .white
    }
    
    var textSecondary: Color {
        Color.white.opacity(0.6)
    }
    
    var glow: Color {
        accent
    }
    
    var hasGlow: Bool { true }
    var hasParticles: Bool { false }
}
