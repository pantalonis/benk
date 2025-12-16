//
//  TitleTag.swift
//  benk
//
//  Created on 2025-12-14
//

import SwiftUI

/// An animated tag component for displaying equipped badge titles
struct TitleTag: View {
    let title: String
    let color: Color
    var isCompact: Bool = false
    
    @State private var glowPulse = false
    
    var body: some View {
        Text(title)
            .font(.system(size: isCompact ? 10 : 11, weight: .bold))
            .foregroundColor(color)
            .padding(.horizontal, isCompact ? 6 : 8)
            .padding(.vertical, isCompact ? 3 : 4)
            .background(
                Capsule()
                    .fill(color.opacity(0.15))
            )
            .overlay(
                Capsule()
                    .stroke(
                        LinearGradient(
                            colors: [
                                color.opacity(0.8),
                                color.opacity(0.4),
                                color.opacity(0.8)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: color.opacity(glowPulse ? 0.6 : 0.3), radius: glowPulse ? 6 : 3, x: 0, y: 0)
            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: glowPulse)
            .onAppear {
                glowPulse = true
            }
    }
}

/// A larger version of TitleTag for profile display
struct TitleTagLarge: View {
    let title: String
    let color: Color
    
    @State private var glowPulse = false
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "star.fill")
                .font(.system(size: 10))
                .foregroundColor(color)
            
            Text(title)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(color)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(color.opacity(0.15))
        )
        .overlay(
            Capsule()
                .stroke(
                    LinearGradient(
                        colors: [
                            color.opacity(0.9),
                            color.opacity(0.5),
                            color.opacity(0.9)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(color: color.opacity(glowPulse ? 0.7 : 0.35), radius: glowPulse ? 8 : 4, x: 0, y: 0)
        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: glowPulse)
        .onAppear {
            glowPulse = true
        }
    }
}

// MARK: - Title Dropdown Large (for Profile)
/// A larger dropdown for selecting titles, styled for profile display
struct TitleDropdownLarge: View {
    let selectedBadge: Badge?
    let earnedBadges: [Badge]
    let onSelect: (UUID?) -> Void
    
    @EnvironmentObject var themeService: ThemeService
    @State private var glowPulse = false
    
    private var displayColor: Color {
        selectedBadge?.badgeColor ?? themeService.currentTheme.textSecondary
    }
    
    var body: some View {
        Menu {
            // None option
            Button {
                onSelect(nil)
            } label: {
                HStack {
                    Text("No Title")
                    if selectedBadge == nil {
                        Image(systemName: "checkmark")
                    }
                }
            }
            
            if !earnedBadges.isEmpty {
                Divider()
                
                ForEach(earnedBadges) { badge in
                    Button {
                        onSelect(badge.id)
                    } label: {
                        HStack {
                            Image(systemName: badge.iconName)
                            Text(badge.titleName)
                            if selectedBadge?.id == badge.id {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 6) {
                if let badge = selectedBadge {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundColor(badge.badgeColor)
                    
                    Text(badge.titleName)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(badge.badgeColor)
                } else {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(themeService.currentTheme.textSecondary)
                    
                    Text("Add Title")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(themeService.currentTheme.textSecondary)
                }
                
                Image(systemName: "chevron.down")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(displayColor.opacity(0.7))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(displayColor.opacity(0.15))
            )
            .overlay(
                Capsule()
                    .stroke(
                        LinearGradient(
                            colors: [
                                displayColor.opacity(0.9),
                                displayColor.opacity(0.5),
                                displayColor.opacity(0.9)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .shadow(color: displayColor.opacity(glowPulse ? 0.6 : 0.3), radius: glowPulse ? 7 : 3, x: 0, y: 0)
        }
        .menuStyle(.borderlessButton)
        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: glowPulse)
        .onAppear {
            if selectedBadge != nil {
                glowPulse = true
            }
        }
        .onChange(of: selectedBadge?.id) {
            glowPulse = selectedBadge != nil
        }
    }
}

// MARK: - Title Dropdown Trigger
/// A compact dropdown for selecting titles, styled like TitleTag
struct TitleDropdownTrigger: View {
    let selectedBadge: Badge?
    let earnedBadges: [Badge]
    @Binding var isExpanded: Bool
    let onSelect: (UUID?) -> Void
    
    @EnvironmentObject var themeService: ThemeService
    @State private var glowPulse = false
    
    private var displayColor: Color {
        selectedBadge?.badgeColor ?? themeService.currentTheme.textSecondary
    }
    
    var body: some View {
        Menu {
            // None option
            Button {
                onSelect(nil)
            } label: {
                HStack {
                    Text("No Title")
                    if selectedBadge == nil {
                        Image(systemName: "checkmark")
                    }
                }
            }
            
            if !earnedBadges.isEmpty {
                Divider()
                
                ForEach(earnedBadges) { badge in
                    Button {
                        onSelect(badge.id)
                    } label: {
                        HStack {
                            Image(systemName: badge.iconName)
                            Text(badge.titleName)
                            if selectedBadge?.id == badge.id {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 4) {
                if let badge = selectedBadge {
                    Text(badge.titleName)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(badge.badgeColor)
                } else {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 10))
                        .foregroundColor(themeService.currentTheme.textSecondary)
                }
                
                Image(systemName: "chevron.down")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(displayColor.opacity(0.7))
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)
                    .background(displayColor.opacity(0.1))
                    .clipShape(Capsule())
            )
            .overlay(
                Capsule()
                    .stroke(
                        LinearGradient(
                            colors: [
                                displayColor.opacity(0.6),
                                displayColor.opacity(0.2),
                                displayColor.opacity(0.6)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: displayColor.opacity(glowPulse ? 0.4 : 0.1), radius: glowPulse ? 8 : 4, x: 0, y: 2)
        }
        .menuStyle(.borderlessButton)
        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: glowPulse)
        .onAppear {
            if selectedBadge != nil {
                glowPulse = true
            }
        }
        .onChange(of: selectedBadge?.id) {
            glowPulse = selectedBadge != nil
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        TitleTag(title: "Immortal", color: Color(hex: "#B9F2FF") ?? .cyan)
        TitleTag(title: "Legend", color: Color(hex: "#D4AF37") ?? .yellow)
        TitleTag(title: "Phoenix", color: Color(hex: "#B22222") ?? .red, isCompact: true)
        
        TitleTagLarge(title: "Time Lord", color: Color(hex: "#D4AF37") ?? .yellow)
    }
    .padding()
    .background(Color.black)
}

