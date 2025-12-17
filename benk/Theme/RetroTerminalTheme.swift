//
//  RetroTerminalTheme.swift
//  benk
//
//  Matrix Glass - Premium hacker liquid glass theme
//

import SwiftUI

struct RetroTerminalTheme: AppTheme {
    let id = "retro"
    let name = "Matrix Glass"
    let price = 250
    let isDark = true
    
    var background: LinearGradient {
        LinearGradient(
            colors: [
                Color(hex: "#000000") ?? .black,       // Pure black
                Color(hex: "#001A0A") ?? .green,       // Dark emerald hint
                Color(hex: "#000F05") ?? .black,       // Subtle green-black
                Color(hex: "#000000") ?? .black        // Back to black
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    var surface: Color {
        Color(hex: "#0A1A0F")?.opacity(0.65) ?? .green.opacity(0.1)
    }
    
    var primary: Color {
        Color(hex: "#00FF41") ?? .green   // Matrix green
    }
    
    var accent: Color {
        Color(hex: "#39FF14") ?? .green   // Neon green
    }
    
    var text: Color {
        Color(hex: "#00FF41") ?? .green   // Matrix green text
    }
    
    var textSecondary: Color {
        Color(hex: "#00AA2A") ?? .green   // Dimmer green
    }
    
    var glow: Color {
        Color(hex: "#00FF41") ?? .green   // Green glow
    }
    
    var hasGlow: Bool { true }
    var hasScanline: Bool { true }
}
