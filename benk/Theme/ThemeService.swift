//
//  ThemeService.swift
//  benk
//
//  Created on 2025-12-11
//

import SwiftUI
import SwiftData

@MainActor
class ThemeService: ObservableObject {
    static let shared = ThemeService()
    
    @Published var currentTheme: AppTheme
    @AppStorage("currentThemeId") private var currentThemeId: String = "dark"
    
    let allThemes: [AppTheme] = [ 
        DarkTheme(),
        LightTheme(),
        CyberpunkTheme(),
        SpaceTheme(),
        ChiikawaTheme(),
        RetroTerminalTheme(),
        ChristmasNightTheme()
    ]
    
    
    private init() {
        // Initialize with default dark theme first
        self.currentTheme = DarkTheme()
        
        // After initialization, load the saved theme preference
        loadSavedTheme()
    }
    
    private func loadSavedTheme() {
        let themes: [AppTheme] = allThemes
        if let savedTheme = themes.first(where: { $0.id == currentThemeId }) {
            currentTheme = savedTheme
        }
    }
    
    func applyTheme(_ theme: AppTheme) {
        currentTheme = theme
        currentThemeId = theme.id
        objectWillChange.send()
    }
    
    func purchaseTheme(_ theme: AppTheme, profile: UserProfile, context: ModelContext) -> Bool {
        // Check if already owned
        if profile.ownedThemeIds.contains(theme.id) {
            return false
        }
        
        // Check if enough coins using CurrencyManager
        guard CurrencyManager.shared.coins >= theme.price else {
            return false
        }
        
        // Deduct coins from CurrencyManager (the single source)
        CurrencyManager.shared.coins -= theme.price
        
        // Add to owned themes
        profile.ownedThemeIds.append(theme.id)
        
        try? context.save()
        HapticManager.shared.success()
        return true
    }
    
    func isThemeOwned(_ themeId: String, profile: UserProfile) -> Bool {
        profile.ownedThemeIds.contains(themeId)
    }
}
