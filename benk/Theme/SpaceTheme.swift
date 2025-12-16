//
//  SpaceTheme.swift
//  benk
//
//  Created on 2025-12-11
//

import SwiftUI

struct SpaceTheme: AppTheme {
    let id = "space"
    let name = "Cosmic Space"
    let price = 300
    let isDark = true
    
    var background: LinearGradient {
        LinearGradient(
            colors: [
                Color(hex: "#000428") ?? .black,
                Color(hex: "#004e92") ?? .blue,
                Color(hex: "#1a1a2e") ?? .black
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var surface: Color {
        Color(hex: "#1a2f4d")?.opacity(0.4) ?? .blue.opacity(0.1)
    }
    
    var primary: Color {
        Color(hex: "#8B5CF6") ?? .purple
    }
    
    var accent: Color {
        Color(hex: "#F59E0B") ?? .orange
    }
    
    var text: Color {
        Color(hex: "#E0E7FF") ?? .white
    }
    
    var textSecondary: Color {
        Color(hex: "#A5B4FC") ?? .white.opacity(0.7)
    }
    
    var glow: Color {
        Color(hex: "#8B5CF6") ?? .purple
    }
    
    var hasGlow: Bool { true }
    var hasStars: Bool { true }
    var hasParticles: Bool { true }
}
