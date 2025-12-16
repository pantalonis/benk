//
//  QuickStatsCard.swift
//  benk
//
//  Created on 2025-12-11
//

import SwiftUI

struct QuickStatsCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    @EnvironmentObject var themeService: ThemeService
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0
    
    var body: some View {
        GlassCard(padding: 20) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(color)
                    .glowEffect(color: color, radius: 10, opacity: 0.5)
                
                Text(value)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(themeService.currentTheme.text)
                
                Text(label)
                    .font(.caption)
                    .foregroundColor(themeService.currentTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
        .aspectRatio(1, contentMode: .fit)
        .scaleEffect(scale)
        .opacity(opacity)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
}

#Preview {
    HStack(spacing: 16) {
        QuickStatsCard(
            icon: "clock.fill",
            value: "45m",
            label: "Today",
            color: .blue
        )
        
        QuickStatsCard(
            icon: "checkmark.circle.fill",
            value: "8",
            label: "Tasks Done",
            color: .green
        )
    }
    .padding()
    .environmentObject(ThemeService.shared)
    .background(Color.black)
}
