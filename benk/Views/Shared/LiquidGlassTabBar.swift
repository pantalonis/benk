//
//  LiquidGlassTabBar.swift
//  benk
//
//  Created on 2025-12-12
//

import SwiftUI

struct TabBarItem: Identifiable {
    let id: Int
    let icon: String
    let label: String
}

struct LiquidGlassTabBar: View {
    @Binding var selectedTab: Int
    @EnvironmentObject var themeService: ThemeService
    @Namespace private var animation
    
    let items: [TabBarItem] = [
        TabBarItem(id: 0, icon: "house.fill", label: "Home"),
        TabBarItem(id: 1, icon: "bed.double.fill", label: "Room"),
        TabBarItem(id: 2, icon: "person.3.fill", label: "Groups"),
        TabBarItem(id: 3, icon: "person.fill", label: "Profile")
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(items) { item in
                TabBarItemView(
                    item: item,
                    isSelected: selectedTab == item.id,
                    animation: animation,
                    action: {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            selectedTab = item.id
                        }
                        HapticManager.shared.selection()
                    }
                )
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background(
            LiquidGlassBackground()
        )
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .shadow(color: themeService.currentTheme.glow.opacity(0.2), radius: 20, x: 0, y: 10)
    }
}

struct TabBarItemView: View {
    let item: TabBarItem
    let isSelected: Bool
    let animation: Namespace.ID
    let action: () -> Void
    
    @EnvironmentObject var themeService: ThemeService
    @State private var isPressed = false
    
    var iconGradient: LinearGradient {
        isSelected
        ? LinearGradient(
            colors: [
                themeService.currentTheme.accent,
                themeService.currentTheme.glow
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        : LinearGradient(
            colors: [
                themeService.currentTheme.primary.opacity(0.5),
                themeService.currentTheme.primary.opacity(0.4)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var body: some View {
        Button(action: {
            action()
        }) {
            VStack(spacing: 4) {
                ZStack {
                    // Animated pill background
                    if isSelected {
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        themeService.currentTheme.accent.opacity(0.3),
                                        themeService.currentTheme.accent.opacity(0.15)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                Capsule()
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                themeService.currentTheme.accent.opacity(0.6),
                                                themeService.currentTheme.glow.opacity(0.4)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1.5
                                    )
                            )
                            .frame(width: 60, height: 36)
                            .shadow(color: themeService.currentTheme.accent.opacity(0.3), radius: 8, x: 0, y: 4)
                            .matchedGeometryEffect(id: "pill", in: animation)
                    }
                    
                    // Icon
                    Image(systemName: item.icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(iconGradient)
                        .scaleEffect(isSelected ? 1.1 : 0.9)
                        .scaleEffect(isPressed ? 0.85 : 1.0)
                }
                .frame(height: 36)
                
                // Label
                Text(item.label)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(
                        isSelected
                        ? themeService.currentTheme.accent
                        : themeService.currentTheme.primary.opacity(0.6)
                    )
                    .opacity(isSelected ? 1.0 : 0.7)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .pressEvents {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
        } onRelease: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = false
            }
        }
    }
}

// Optimized LiquidGlassBackground - reduced from 4 overlapping shapes to 2
struct LiquidGlassBackground: View {
    @EnvironmentObject var themeService: ThemeService
    
    var body: some View {
        ZStack {
            // Ultra-thin material base with gradient overlay combined
            RoundedRectangle(cornerRadius: 30)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(
                            LinearGradient(
                                colors: [
                                    themeService.currentTheme.surface.opacity(0.3),
                                    themeService.currentTheme.surface.opacity(0.1)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                )
            
            // Combined gradient border with inner glow effect
            // Uses a single stroke with a composite gradient instead of two separate strokes
            RoundedRectangle(cornerRadius: 30)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            themeService.currentTheme.glow.opacity(0.15),
                            themeService.currentTheme.primary.opacity(0.4),
                            themeService.currentTheme.accent.opacity(0.3),
                            themeService.currentTheme.glow.opacity(0.1)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 1.5
                )
        }
    }
}


#Preview {
    @Previewable @State var selectedTab = 0
    
    ZStack {
        LinearGradient(
            colors: [.black, .gray.opacity(0.8)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        
        VStack {
            Spacer()
            LiquidGlassTabBar(selectedTab: $selectedTab)
        }
    }
    .environmentObject(ThemeService.shared)
}
