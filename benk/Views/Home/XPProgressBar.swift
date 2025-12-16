//
//  XPProgressBar.swift
//  benk
//
//  Created on 2025-12-11
//

import SwiftUI

struct XPProgressBar: View {
    let currentXP: Int
    let currentLevel: Int
    let nextLevelXP: Int
    let currentLevelXP: Int
    
    @EnvironmentObject var themeService: ThemeService
    @State private var animatedProgress: CGFloat = 0
    
    var progress: Double {
        let xpInLevel = currentXP - currentLevelXP
        let xpNeeded = nextLevelXP - currentLevelXP
        return Double(xpInLevel) / Double(xpNeeded)
    }
    
    var body: some View {
        GlassCard(padding: 16) {
            VStack(spacing: 12) {
                HStack {
                    Text("Level \(currentLevel)")
                        .font(.headline)
                        .foregroundColor(themeService.currentTheme.text)
                    
                    Spacer()
                    
                    Text("Level \(currentLevel + 1)")
                        .font(.subheadline)
                        .foregroundColor(themeService.currentTheme.textSecondary)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background track
                        RoundedRectangle(cornerRadius: 10)
                            .fill(themeService.currentTheme.surface.opacity(0.3))
                            .frame(height: 20)
                        
                        // Progress fill
                        RoundedRectangle(cornerRadius: 10)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        XPService.shared.getLevelColor(level: currentLevel).opacity(0.7),
                                        XPService.shared.getLevelColor(level: currentLevel)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * animatedProgress, height: 20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(XPService.shared.getLevelColor(level: currentLevel), lineWidth: 2)
                                    .frame(width: geometry.size.width * animatedProgress, height: 20)
                            )
                            .glowEffect(color: XPService.shared.getLevelColor(level: currentLevel), radius: 8, opacity: 0.6)
                    }
                }
                .frame(height: 20)
                
                HStack {
                    Text("\(currentXP - currentLevelXP) / \(nextLevelXP - currentLevelXP) XP")
                        .font(.caption)
                        .foregroundColor(themeService.currentTheme.textSecondary)
                    
                    Spacer()
                    
                    Text("\(Int(progress * 100))%")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(themeService.currentTheme.accent)
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 1.0, dampingFraction: 0.7)) {
                animatedProgress = CGFloat(progress)
            }
        }
        .onChange(of: currentXP) { _, _ in
            withAnimation(.spring(response: 1.0, dampingFraction: 0.7)) {
                animatedProgress = CGFloat(progress)
            }
        }
    }
}

#Preview {
    XPProgressBar(
        currentXP: 1750,
        currentLevel: 4,
        nextLevelXP: 2500,
        currentLevelXP: 1600
    )
    .padding()
    .environmentObject(ThemeService.shared)
    .background(Color.black)
}
