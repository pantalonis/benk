//
//  ThemeManager.swift
//  Pixel Room Customizer
//
//  Manages app theme (dark/light mode) and color scheme
//

import SwiftUI
import Combine

class ThemeManager: ObservableObject {
    @Published var isDarkMode: Bool = true
    
    private var cancellables = Set<AnyCancellable>()
    private var ambienceManager = AmbienceManager.shared
    
    init() {
        // Observe season changes
        ambienceManager.$currentSeason
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Background Colors
    var backgroundColor: Color {
        blendWithSeason(Color.clear)
    }
    
    var secondaryBackground: Color {
        blendSecondaryWithSeason(Color.clear)
    }
    
    var cardBackground: Color {
        blendCardWithSeason()
    }
    
    // MARK: - Seasonal Blending
    
    private func blendWithSeason(_ baseColor: Color) -> Color {
        let season = ambienceManager.currentSeason
        
        // Create a blended color based on season
        switch season {
        case .spring:
            // Fresh green tint
            return isDarkMode ? 
                Color(red: 0.10, green: 0.13, blue: 0.18) : 
                Color(red: 0.93, green: 0.97, blue: 0.95)
        case .summer:
            // Warm yellow/orange tint
            return isDarkMode ? 
                Color(red: 0.12, green: 0.11, blue: 0.16) : 
                Color(red: 0.98, green: 0.96, blue: 0.93)
        case .autumn:
            // Warm orange/red tint
            return isDarkMode ? 
                Color(red: 0.13, green: 0.10, blue: 0.17) : 
                Color(red: 0.98, green: 0.94, blue: 0.93)
        case .winter:
            // Cool blue tint
            return isDarkMode ? 
                Color(red: 0.08, green: 0.10, blue: 0.20) : 
                Color(red: 0.93, green: 0.95, blue: 0.98)
        }
    }
    
    private func blendSecondaryWithSeason(_ baseColor: Color) -> Color {
        let season = ambienceManager.currentSeason
        
        switch season {
        case .spring:
            return isDarkMode ? 
                Color(red: 0.15, green: 0.18, blue: 0.23) : 
                Color(red: 0.98, green: 1.0, blue: 0.98)
        case .summer:
            return isDarkMode ? 
                Color(red: 0.17, green: 0.16, blue: 0.21) : 
                Color(red: 1.0, green: 0.99, blue: 0.96)
        case .autumn:
            return isDarkMode ? 
                Color(red: 0.18, green: 0.15, blue: 0.22) : 
                Color(red: 1.0, green: 0.97, blue: 0.96)
        case .winter:
            return isDarkMode ? 
                Color(red: 0.13, green: 0.15, blue: 0.25) : 
                Color(red: 0.96, green: 0.98, blue: 1.0)
        }
    }
    
    private func blendCardWithSeason() -> Color {
        let season = ambienceManager.currentSeason
        let baseOpacity = isDarkMode ? 0.6 : 0.8
        
        switch season {
        case .spring:
            return isDarkMode ? 
                Color(red: 0.18, green: 0.21, blue: 0.26).opacity(baseOpacity) : 
                Color.white.opacity(baseOpacity)
        case .summer:
            return isDarkMode ? 
                Color(red: 0.20, green: 0.19, blue: 0.24).opacity(baseOpacity) : 
                Color(red: 1.0, green: 0.99, blue: 0.96).opacity(baseOpacity)
        case .autumn:
            return isDarkMode ? 
                Color(red: 0.21, green: 0.18, blue: 0.25).opacity(baseOpacity) : 
                Color(red: 1.0, green: 0.97, blue: 0.96).opacity(baseOpacity)
        case .winter:
            return isDarkMode ? 
                Color(red: 0.16, green: 0.18, blue: 0.28).opacity(baseOpacity) : 
                Color(red: 0.96, green: 0.98, blue: 1.0).opacity(baseOpacity)
        }
    }
    
    // MARK: - Text Colors
    var primaryText: Color {
        isDarkMode ? .white : Color(red: 0.1, green: 0.1, blue: 0.15)
    }
    
    var secondaryText: Color {
        isDarkMode ? Color.white.opacity(0.7) : Color.gray
    }
    
    // MARK: - Accent Colors
    var accentCyan: Color {
        Color(red: 0.0, green: 0.85, blue: 0.85)
    }
    
    var accentPurple: Color {
        Color(red: 0.61, green: 0.48, blue: 1.0)
    }
    
    var accentPink: Color {
        Color(red: 1.0, green: 0.42, blue: 0.62)
    }
    
    var accentOrange: Color {
        Color(red: 1.0, green: 0.58, blue: 0.0)
    }
    
    // MARK: - Gradients
    var primaryGradient: LinearGradient {
        LinearGradient(
            colors: [accentPurple, accentCyan],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    var secondaryGradient: LinearGradient {
        LinearGradient(
            colors: [accentPink, accentPurple],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var coinGradient: LinearGradient {
        LinearGradient(
            colors: [Color.yellow, accentOrange],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: - Tab Bar Colors
    var tabBarBackground: Color {
        blendSecondaryWithSeason(Color.clear).opacity(0.95)
    }
    
    var tabBarInactive: Color {
        isDarkMode ? Color.white.opacity(0.4) : Color.gray.opacity(0.6)
    }
    
    func toggleTheme() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isDarkMode.toggle()
        }
    }
}
