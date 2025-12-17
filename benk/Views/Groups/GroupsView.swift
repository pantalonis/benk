//
//  GroupsView.swift
//  benk
//
//  Created on 2025-12-15
//

import SwiftUI

struct GroupsView: View {
    @EnvironmentObject var themeService: ThemeService
    
    var body: some View {
        ZStack {
            // Themed background with effects
            ThemedBackground(theme: themeService.currentTheme)            
            VStack(spacing: 20) {
                // Header
                Text("Study Groups")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(themeService.currentTheme.primary)
                
                Spacer()
                
                // Placeholder content
                VStack(spacing: 12) {
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    themeService.currentTheme.accent,
                                    themeService.currentTheme.glow
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Text("Study Groups")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(themeService.currentTheme.primary)
                    
                    Text("Coming Soon")
                        .font(.body)
                        .foregroundColor(themeService.currentTheme.textSecondary)
                }
                
                Spacer()
            }
            .padding()
            .padding(.bottom, 100) // Extra padding for tab bar
        }
    }
}

#Preview {
    GroupsView()
        .environmentObject(ThemeService.shared)
}
