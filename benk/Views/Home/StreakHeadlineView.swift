//
//  StreakHeadlineView.swift
//  benk
//
//  Created on 2025-12-11
//

import SwiftUI

struct StreakHeadlineView: View {
    let streak: Int
    let isActive: Bool
    
    @EnvironmentObject var themeService: ThemeService
    
    var body: some View {
        GlassCard {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.orange, .red],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                        .glowEffect(color: .orange, radius: 15, opacity: isActive ? 0.8 : 0.3)
                    
                    Image(systemName: "flame.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                        .pulsingEffect(duration: isActive ? 1.5 : 3.0)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(streak) Day Streak!")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(themeService.currentTheme.text)
                    
                    Text(isActive ? "Keep it going! 🔥" : "Study today to continue!")
                        .font(.subheadline)
                        .foregroundColor(themeService.currentTheme.textSecondary)
                }
                
                Spacer()
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        StreakHeadlineView(streak: 7, isActive: true)
        StreakHeadlineView(streak: 0, isActive: false)
    }
    .padding()
    .environmentObject(ThemeService.shared)
    .background(Color.black)
}
