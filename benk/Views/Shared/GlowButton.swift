//
//  GlowButton.swift
//  benk
//
//  Created on 2025-12-11
//

import SwiftUI

struct GlowButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    
    @EnvironmentObject var themeService: ThemeService
    @State private var isPressed = false
    
    init(_ title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            HapticManager.shared.medium()
            action()
        }) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.headline)
                }
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(buttonBackground)
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .pressEvents {
            isPressed = true
        } onRelease: {
            isPressed = false
        }
    }
    
    private var buttonBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(
                LinearGradient(
                    colors: [
                        themeService.currentTheme.primary,
                        themeService.currentTheme.accent
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.25),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .center
                        )
                    )
            )
            .shadow(color: themeService.currentTheme.glow.opacity(isPressed ? 0.3 : 0.5), radius: isPressed ? 8 : 16, x: 0, y: isPressed ? 2 : 6)
    }
}

#Preview {
    VStack(spacing: 20) {
        GlowButton("Start Studying", icon: "play.fill") {}
        GlowButton("Claim Reward") {}
    }
    .padding()
    .environmentObject(ThemeService.shared)
    .background(Color.black)
}
