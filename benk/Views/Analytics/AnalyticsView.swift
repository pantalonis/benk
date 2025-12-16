//
//  AnalyticsView.swift
//  benk
//
//  Created on 2025-12-11.
//

import SwiftUI
import SwiftData

struct AnalyticsView: View {
    @EnvironmentObject var themeService: ThemeService
    
    var body: some View {
        ZStack {
            ThemedBackground(theme: themeService.currentTheme)
            
            VStack {
                Text("Room")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(themeService.currentTheme.text)
                    .padding(.top, 60)
                
                Spacer()
                
                // Placeholder for future room feature
                VStack(spacing: 16) {
                    Image(systemName: "house.fill")
                        .font(.system(size: 60))
                        .foregroundColor(themeService.currentTheme.textSecondary.opacity(0.3))
                    
                    Text("Coming Soon")
                        .font(.headline)
                        .foregroundColor(themeService.currentTheme.textSecondary.opacity(0.5))
                }
                
                Spacer()
                Spacer()
            }
        }
    }
}

#Preview {
    AnalyticsView()
        .environmentObject(ThemeService.shared)
}
