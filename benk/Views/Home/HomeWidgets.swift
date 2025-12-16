//
//  HomeWidgets.swift
//  benk
//
//  Created on 2025-12-13.
//

import SwiftUI

// Simple static storage that persists across tab switches but resets on app restart
enum WidgetState {
    static var showHoursLeft = false
    static var showXPLeft = false
}

// Helper for dynamic font sizing
private func getDynamicFontSize(text: String) -> CGFloat {
    let length = text.count
    if length <= 2 { return 32 }
    else if length == 3 { return 28 }
    else if length == 4 { return 24 }
    else { return 20 }
}

struct DailyGoalWidget: View {
    let dayMinutes: Int
    let goalMinutes: Int
    let isVisible: Bool
    
    @EnvironmentObject var themeService: ThemeService
    @State private var animatedProgress: Double = 0
    @State private var displayShowHoursLeft = WidgetState.showHoursLeft
    
    // Convert to hours for display
    var studiedHours: Double {
        Double(dayMinutes) / 60.0
    }
    
    var goalHours: Double {
        Double(goalMinutes) / 60.0
    }
    
    var hoursLeft: Double {
        max(0, goalHours - studiedHours)
    }
    
    var progress: Double {
        guard goalMinutes > 0 else { return 0 }
        return Double(dayMinutes) / Double(goalMinutes)
    }
    
    // Check if goal is reached
    var isGoalReached: Bool {
        dayMinutes >= goalMinutes
    }
    
    // Progress color based on goal completion
    var progressGradient: LinearGradient {
        if isGoalReached {
            return LinearGradient(
                colors: [
                    Color.green,
                    Color.green.opacity(0.8)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [
                    themeService.currentTheme.primary,
                    themeService.currentTheme.accent
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    var body: some View {
        GlassCard(padding: 0) {
            GeometryReader { geometry in
                let size = min(geometry.size.width, geometry.size.height)
                let lineWidth: CGFloat = 8
                
                VStack(spacing: 4) {
                    ZStack {
                        // Track
                        Circle()
                            .stroke(themeService.currentTheme.surface.opacity(0.3), lineWidth: lineWidth)
                        
                        // Animated Progress
                        Circle()
                            .trim(from: 0, to: min(1.0, animatedProgress))
                            .stroke(
                                progressGradient,
                                style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                            .shadow(color: isGoalReached ? Color.green.opacity(0.6) : themeService.currentTheme.accent.opacity(0.4), radius: isGoalReached ? 10 : 6, x: 0, y: 2)
                        
                        // Center Text - Tap to toggle
                        VStack(spacing: 0) {
                            if displayShowHoursLeft {
                                // Show hours left
                                let text = String(format: "%.1f", hoursLeft)
                                Text(text)
                                    .font(.system(size: getDynamicFontSize(text: text), weight: .bold, design: .rounded))
                                    .foregroundColor(isGoalReached ? .green : themeService.currentTheme.text)
                                
                                Text(isGoalReached ? "Goal Reached!" : "Hours Left")
                                    .font(.system(size: 9, weight: .medium))
                                    .foregroundColor(isGoalReached ? .green : themeService.currentTheme.textSecondary)
                            } else {
                                // Show studied/goal hours
                                HStack(alignment: .lastTextBaseline, spacing: 2) {
                                    let text = String(format: "%.1f", studiedHours)
                                    Text(text)
                                        .font(.system(size: getDynamicFontSize(text: text), weight: .bold, design: .rounded))
                                    Text("/")
                                        .font(.system(size: 12, weight: .bold))
                                    Text(String(format: "%.1f", goalHours))
                                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                                }
                                .foregroundColor(isGoalReached ? .green : themeService.currentTheme.text)
                                
                                Text("Hours Today")
                                    .font(.system(size: 9, weight: .medium))
                                    .foregroundColor(isGoalReached ? .green : themeService.currentTheme.textSecondary)
                            }
                        }
                    }
                    .frame(width: max(1, size - 24), height: max(1, size - 24))

                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
        // Green glow effect when goal is reached
        .shadow(color: isGoalReached ? Color.green.opacity(0.4) : Color.clear, radius: 15, x: 0, y: 0)
        .aspectRatio(1.0, contentMode: .fit)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                displayShowHoursLeft.toggle()
                WidgetState.showHoursLeft = displayShowHoursLeft
            }
            HapticManager.shared.selection()
        }
        .onAppear {
            // Sync from static state when view appears
            displayShowHoursLeft = WidgetState.showHoursLeft
            
            // Animate progress only if visible
            if isVisible {
                animatedProgress = 0
                withAnimation(.spring(response: 1.0, dampingFraction: 0.7).delay(0.1)) {
                    animatedProgress = progress
                }
            } else {
                animatedProgress = 0
            }
        }
        .onChange(of: isVisible) { _, visible in
            if visible {
                // Reset and animate up
                animatedProgress = 0
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    withAnimation(.spring(response: 1.0, dampingFraction: 0.7).delay(0.1)) {
                        animatedProgress = progress
                    }
                }
            } else {
                // Reset immediately when hidden
                withAnimation(.none) {
                    animatedProgress = 0
                }
            }
        }
        .onChange(of: dayMinutes) { _, newValue in
            let newProgress = goalMinutes > 0 ? Double(newValue) / Double(goalMinutes) : 0
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                animatedProgress = newProgress
            }
        }
        .onChange(of: goalMinutes) { _, newValue in
            let newProgress = newValue > 0 ? Double(dayMinutes) / Double(newValue) : 0
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                animatedProgress = newProgress
            }
        }
    }
}

struct XPLevelWidget: View {
    let currentXP: Int
    let currentLevel: Int
    let nextLevelXP: Int
    let currentLevelXP: Int
    let isVisible: Bool
    
    @EnvironmentObject var themeService: ThemeService
    @State private var animatedProgress: Double = 0
    @State private var displayShowXPLeft = WidgetState.showXPLeft
    
    // XP within current level (not cumulative)
    var xpInLevel: Int {
        currentXP - currentLevelXP
    }
    
    // XP needed to complete current level
    var xpNeededForLevel: Int {
        nextLevelXP - currentLevelXP
    }
    
    // XP left to reach next level
    var xpLeft: Int {
        max(0, nextLevelXP - currentXP)
    }
    
    var progress: Double {
        guard xpNeededForLevel > 0 else { return 0 }
        return Double(xpInLevel) / Double(xpNeededForLevel)
    }
    
    var levelColor: Color {
        LevelTier.color(for: currentLevel)
    }
    
    var tierName: String {
        LevelTier.name(for: currentLevel)
    }
    
    var body: some View {
        GlassCard(padding: 0) {
            GeometryReader { geometry in
                let size = min(geometry.size.width, geometry.size.height)
                let lineWidth: CGFloat = 8
                
                VStack(spacing: 4) {
                    ZStack {
                        // Track
                        Circle()
                            .stroke(themeService.currentTheme.surface.opacity(0.3), lineWidth: lineWidth)
                        
                        // Animated Progress
                        Circle()
                            .trim(from: 0, to: min(1.0, animatedProgress))
                            .stroke(
                                AngularGradient(
                                    colors: [
                                        levelColor.opacity(0.6),
                                        levelColor,
                                        levelColor.opacity(0.8)
                                    ],
                                    center: .center,
                                    angle: .degrees(0)
                                ),
                                style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                            .shadow(color: levelColor.opacity(0.4), radius: 6, x: 0, y: 2)
                        
                        // Center Text - Tap to toggle
                        VStack(spacing: 0) {
                            if displayShowXPLeft {
                                // Show XP left to next level
                                let text = "\(xpLeft)"
                                Text(text)
                                    .font(.system(size: getDynamicFontSize(text: text), weight: .bold, design: .rounded))
                                    .foregroundColor(themeService.currentTheme.text)
                                
                                Text("XP to Lvl \(currentLevel + 1)")
                                    .font(.system(size: 9, weight: .medium))
                                    .foregroundColor(themeService.currentTheme.textSecondary)
                            } else {
                                // Show XP in level / XP needed for level
                                HStack(alignment: .lastTextBaseline, spacing: 2) {
                                    let text = "\(xpInLevel)"
                                    Text(text)
                                        .font(.system(size: getDynamicFontSize(text: text), weight: .bold, design: .rounded))
                                        .foregroundColor(levelColor)
                                    Text("/")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(themeService.currentTheme.textSecondary)
                                    Text("\(xpNeededForLevel)")
                                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                                        .foregroundColor(themeService.currentTheme.textSecondary)
                                }
                                
                                Text(tierName)
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(levelColor)
                            }
                        }
                    }
                    .frame(width: max(1, size - 24), height: max(1, size - 24))

                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
        .aspectRatio(1.0, contentMode: .fit)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                displayShowXPLeft.toggle()
                WidgetState.showXPLeft = displayShowXPLeft
            }
            HapticManager.shared.selection()
        }
        .onAppear {
            // Sync from static state when view appears
            displayShowXPLeft = WidgetState.showXPLeft
            
            // Animate progress only if visible
            if isVisible {
                animatedProgress = 0
                withAnimation(.spring(response: 1.0, dampingFraction: 0.7).delay(0.2)) {
                    animatedProgress = progress
                }
            } else {
                animatedProgress = 0
            }
        }
        .onChange(of: isVisible) { _, visible in
            if visible {
                // Reset and animate up
                animatedProgress = 0
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    withAnimation(.spring(response: 1.0, dampingFraction: 0.7).delay(0.2)) {
                        animatedProgress = progress
                    }
                }
            } else {
                // Reset immediately when hidden
                withAnimation(.none) {
                    animatedProgress = 0
                }
            }
        }
        .onChange(of: currentXP) { _, _ in
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                animatedProgress = progress
            }
        }

    }
}
