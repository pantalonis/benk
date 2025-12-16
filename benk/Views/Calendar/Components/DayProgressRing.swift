//
//  DayProgressRing.swift
//  benk
//
//  Created on 2025-12-15
//

import SwiftUI
import SwiftData

struct DayProgressRing: View {
    let date: Date
    let dailyGoalMinutes: Int
    let heatMapMode: HeatMapMode?
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var themeService: ThemeService
    
    @State private var animationProgress: CGFloat = 0
    
    var studyMinutes: Int {
        CalendarService.shared.getStudyMinutes(for: date, context: modelContext)
    }
    
    var progress: Double {
        guard dailyGoalMinutes > 0 else { return 0 }
        return min(1.0, Double(studyMinutes) / Double(dailyGoalMinutes))
    }
    
    var heatMapIntensity: Double {
        guard let mode = heatMapMode else { return 0 }
        return CalendarService.shared.calculateHeatMapIntensity(
            for: date,
            mode: mode,
            dailyGoalMinutes: dailyGoalMinutes,
            context: modelContext
        )
    }
    
    var dayNumber: String {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        return "\(day)"
    }
    
    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    var isChristmasDay: Bool {
        let components = Calendar.current.dateComponents([.month, .day], from: date)
        return components.month == 12 && components.day == 25
    }
    
    var body: some View {
        ZStack {
            // Heat map background (if enabled)
            if let _ = heatMapMode {
                Circle()
                    .fill(heatMapColor.opacity(heatMapIntensity * 0.6))
                    .frame(width: 36, height: 36)
            }
            
            // Progress ring
            if studyMinutes > 0 {
                Circle()
                    .stroke(
                        themeService.currentTheme.textSecondary.opacity(0.2),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                    )
                    .frame(width: 32, height: 32)
                
                Circle()
                    .trim(from: 0, to: progress * animationProgress)
                    .stroke(
                        ringColor,
                        style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                    )
                    .frame(width: 32, height: 32)
                    .rotationEffect(.degrees(-90))
            } else {
                // Broken ring for no activity
                ForEach(0..<8, id: \.self) { index in
                    Circle()
                        .trim(from: Double(index) / 8.0, to: Double(index) / 8.0 + 0.08)
                        .stroke(
                            themeService.currentTheme.textSecondary.opacity(0.3),
                            style: StrokeStyle(lineWidth: 2, lineCap: .round)
                        )
                        .frame(width: 32, height: 32)
                        .rotationEffect(.degrees(-90))
                }
            }
            
            // Day number or Santa emoji for Christmas
            if isChristmasDay && themeService.currentTheme.isChristmas {
                Text("🎅")
                    .font(.system(size: 14))
            } else {
                Text(dayNumber)
                    .font(.system(size: 12, weight: isToday ? .bold : .medium))
                    .foregroundColor(isToday ? themeService.currentTheme.primary : themeService.currentTheme.text)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
                animationProgress = 1
            }
        }
    }
    
    private var ringColor: Color {
        if progress >= 1.0 {
            return themeService.currentTheme.primary
        } else {
            return themeService.currentTheme.accent
        }
    }
    
    private var heatMapColor: Color {
        guard let mode = heatMapMode else { return .clear }
        switch mode {
        case .productivity:
            return themeService.currentTheme.primary
        case .examLoad:
            return .red
        case .assignmentLoad:
            return .orange
        }
    }
}

#Preview {
    DayProgressRing(date: Date(), dailyGoalMinutes: 60, heatMapMode: nil)
        .environmentObject(ThemeService.shared)
        .modelContainer(for: [StudySession.self])
}
