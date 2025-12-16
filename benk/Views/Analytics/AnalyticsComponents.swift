//
//  AnalyticsComponents.swift
//  benk
//
//  Created on 2025-12-13.
//

import SwiftUI
import SwiftData

// MARK: - Rolling Number View
struct RollingNumberAnimation: ViewModifier {
    var number: Double
    var decimalPlaces: Int = 0
    
    @State private var displayedNumber: Double = 0
    
    func body(content: Content) -> some View {
        Text(String(format: "%.\(decimalPlaces)f", displayedNumber))
            .onAppear {
                withAnimation(.easeOut(duration: 1.5)) {
                    displayedNumber = number
                }
            }
            .onChange(of: number) { _, newValue in
                withAnimation(.easeOut(duration: 1.0)) {
                    displayedNumber = newValue
                }
            }
            // Fallback for iOS 16 logic if needed, simplify:
            // Just using Animatable would be better for smooth counting, 
            // but for simplicity let's stick to standard Text init in parent 
            // or use specific Animatable logic.
            // Let's implement a proper Animatable View instead.
    }
}

struct RollingText: View, Animatable {
    var value: Double
    var formatString: String
    
    var animatableData: Double {
        get { value }
        set { value = newValue }
    }
    
    var body: some View {
        Text(String(format: formatString, value))
    }
}


// MARK: - Stat Card (Square)
struct StatCard: View {
    let title: String
    let value: Double? // Numeric for animation
    let valueString: String? // String override (e.g. time formatted)
    let icon: String
    let color: Color
    
    @EnvironmentObject var themeService: ThemeService
    
    // Helper to determine display
    // If value provided, animate. If string provided, static.
    
    var body: some View {
        GlassCard(padding: 12) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(color)
                    .frame(height: 40)
                
                if let val = value {
                    RollingText(value: val, formatString: "%.0f")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(themeService.currentTheme.text)
                        .minimumScaleFactor(0.8)
                        .lineLimit(1)
                } else {
                    Text(valueString ?? "")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(themeService.currentTheme.text)
                        .minimumScaleFactor(0.8)
                        .lineLimit(1)
                }
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(themeService.currentTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .aspectRatio(1.0, contentMode: .fit) // Force Square
    }
}

// MARK: - History Rows
struct BreakHistoryRow: View {
    let breakSession: BreakSession
    @EnvironmentObject var themeService: ThemeService
    
    var body: some View {
        GlassCard {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(themeService.currentTheme.surface.opacity(0.5))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "cup.and.saucer.fill")
                        .foregroundColor(themeService.currentTheme.accent)
                        .font(.system(size: 18))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Break")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(themeService.currentTheme.text)
                    
                    Text(breakSession.tag)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(themeService.currentTheme.accent.opacity(0.2))
                        .clipShape(Capsule())
                        .foregroundColor(themeService.currentTheme.accent)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(breakSession.formattedDuration)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(themeService.currentTheme.text)
                    
                    Text(breakSession.timestamp.formatted(date: .omitted, time: .shortened))
                        .font(.caption)
                        .foregroundColor(themeService.currentTheme.textSecondary)
                }
            }
        }
    }
}

struct SessionHistoryRow: View {
    let session: StudySession
    
    @EnvironmentObject var themeService: ThemeService
    @Query private var subjects: [Subject]
    @Query private var techniques: [Technique]
    
    var subject: Subject? {
        subjects.first { $0.id == session.subjectId }
    }
    
    var technique: Technique? {
        techniques.first { $0.id == session.techniqueId }
    }
    
    // Check if this is a task completion (0 duration)
    var isTaskCompletion: Bool {
        session.duration == 0
    }
    
    var body: some View {
        GlassCard {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(subject?.name ?? "General")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(themeService.currentTheme.text)
                    
                    if let technique = technique {
                        HStack(spacing: 6) {
                            Text(technique.name)
                                .font(.caption)
                                .foregroundColor(themeService.currentTheme.textSecondary)
                            
                            if let subcategory = technique.subcategory {
                                Text(subcategory)
                                    .font(.caption2)
                                    .fontWeight(.medium)
                                    .foregroundColor(themeService.currentTheme.accent)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Capsule().fill(themeService.currentTheme.accent.opacity(0.2)))
                            }
                        }
                    } else if isTaskCompletion {
                        Text("Task Completed")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.green)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(Color.green.opacity(0.2)))
                    }
                    
                    Text(session.timestamp.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption2)
                        .foregroundColor(themeService.currentTheme.textSecondary.opacity(0.7))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    if isTaskCompletion {
                        // Show checkmark for task completions
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.title2)
                    } else {
                        Text(session.duration.timeFormatted)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(themeService.currentTheme.text)
                        
                        if session.xpEarned > 0 {
                            Text("+\(session.xpEarned) XP")
                                .font(.caption)
                                .foregroundColor(themeService.currentTheme.accent)
                        }
                    }
                }
            }
        }
    }
}
