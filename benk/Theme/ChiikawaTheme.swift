//
//  ChiikawaTheme.swift
//  benk
//
//  Sakura Dream - Elegant kawaii liquid glass theme
//

import SwiftUI

struct ChiikawaTheme: AppTheme {
    let id = "chiikawa"
    let name = "Sakura Dream"
    let price = 400
    let isDark = false
    
    var background: LinearGradient {
        LinearGradient(
            colors: [
                Color(hex: "#FFF5F8") ?? .pink,        // Soft blush
                Color(hex: "#FFE4EC") ?? .pink,        // Cherry blossom pink
                Color(hex: "#FFF0E8") ?? .orange,      // Warm cream
                Color(hex: "#FFF8F5") ?? .white        // Delicate fade
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var surface: Color {
        Color(hex: "#FFFFFF")?.opacity(0.85) ?? .white.opacity(0.85)
    }
    
    var primary: Color {
        Color(hex: "#E91E8C") ?? .pink    // Vivid magenta pink
    }
    
    var accent: Color {
        Color(hex: "#5BA0D0") ?? .blue    // Soft sky blue
    }
    
    var text: Color {
        Color(hex: "#3D2C29") ?? .brown   // Deep brown for readability
    }
    
    var textSecondary: Color {
        Color(hex: "#6B5750") ?? .brown   // Warm taupe
    }
    
    var glow: Color {
        Color(hex: "#FFB5D5") ?? .pink    // Soft pink glow
    }
    
    var hasCuteElements: Bool { true }
    var hasGlow: Bool { true }
}
