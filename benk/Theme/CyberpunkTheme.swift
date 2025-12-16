//
//  CyberpunkTheme.swift
//  benk
//
//  Created on 2025-12-11
//

import SwiftUI

struct CyberpunkTheme: AppTheme {
    let id = "cyberpunk"
    let name = "Cyberpunk"
    let price = 500
    let isDark = true
    
    var background: LinearGradient {
        LinearGradient(
            colors: [
                Color(hex: "#0A0A0F") ?? .black,
                Color(hex: "#1A0825") ?? .black,
                Color(hex: "#0F0522") ?? .black
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var surface: Color {
        Color(hex: "#1A0F2E")?.opacity(0.6) ?? .purple.opacity(0.1)
    }
    
    var primary: Color {
        Color(hex: "#FF0080") ?? .pink
    }
    
    var accent: Color {
        Color(hex: "#00FFFF") ?? .cyan
    }
    
    var text: Color {
        Color(hex: "#E0E0FF") ?? .white
    }
    
    var textSecondary: Color {
        Color(hex: "#A0A0FF") ?? .white.opacity(0.7)
    }
    
    var glow: Color {
        Color(hex: "#FF0080") ?? .pink
    }
    
    var hasGlow: Bool { true }
    var hasScanline: Bool { true }
}
