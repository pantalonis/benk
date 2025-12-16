//
//  ChiikawaTheme.swift
//  benk
//
//  Created on 2025-12-11
//

import SwiftUI

struct ChiikawaTheme: AppTheme {
    let id = "chiikawa"
    let name = "Chiikawa Cute"
    let price = 400
    let isDark = false
    
    var background: LinearGradient {
        LinearGradient(
            colors: [
                Color(hex: "#FFF0F5") ?? .pink.opacity(0.1),
                Color(hex: "#FFE4E1") ?? .pink.opacity(0.2),
                Color(hex: "#FFDAB9") ?? .orange.opacity(0.2)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var surface: Color {
        Color(hex: "#FFFFFF")?.opacity(0.8) ?? .white.opacity(0.8)
    }
    
    var primary: Color {
        Color(hex: "#FF69B4") ?? .pink
    }
    
    var accent: Color {
        Color(hex: "#87CEEB") ?? .blue
    }
    
    var text: Color {
        Color(hex: "#5C4033") ?? .brown
    }
    
    var textSecondary: Color {
        Color(hex: "#8B7355") ?? .brown.opacity(0.7)
    }
    
    var glow: Color {
        Color(hex: "#FFB6C1") ?? .pink
    }
    
    var hasCuteElements: Bool { true }
    var hasParticles: Bool { true } // Sparkles
}
