//
//  RetroTerminalTheme.swift
//  benk
//
//  Created on 2025-12-11
//

import SwiftUI

struct RetroTerminalTheme: AppTheme {
    let id = "retro"
    let name = "Retro Terminal"
    let price = 250
    let isDark = true
    
    var background: LinearGradient {
        LinearGradient(
            colors: [
                Color(hex: "#0C0C0C") ?? .black,
                Color(hex: "#1A1A1A") ?? .black
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    var surface: Color {
        Color(hex: "#1E1E1E")?.opacity(0.6) ?? .gray.opacity(0.1)
    }
    
    var primary: Color {
        Color(hex: "#00FF00") ?? .green
    }
    
    var accent: Color {
        Color(hex: "#00FF00") ?? .green
    }
    
    var text: Color {
        Color(hex: "#00FF00") ?? .green
    }
    
    var textSecondary: Color {
        Color(hex: "#00AA00") ?? .green.opacity(0.7)
    }
    
    var glow: Color {
        Color(hex: "#00FF00") ?? .green
    }
    
    var hasGlow: Bool { true }
    var hasScanline: Bool { true }
}
