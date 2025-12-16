//
//  GlassUIComponents.swift
//  benk
//
//  Created on 2025-12-16
//

import SwiftUI

// MARK: - Glass Sort Pill
struct GlassSortPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    @EnvironmentObject var themeService: ThemeService
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? themeService.currentTheme.accent : themeService.currentTheme.text)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(isSelected ? themeService.currentTheme.accent.opacity(0.15) : themeService.currentTheme.surface.opacity(0.3))
                )
                .overlay(
                    Capsule()
                        .stroke(
                            isSelected ? themeService.currentTheme.accent.opacity(0.5) : themeService.currentTheme.textSecondary.opacity(0.1),
                            lineWidth: 1
                        )
                )
        }
        .buttonStyle(.plain)
    }
}
