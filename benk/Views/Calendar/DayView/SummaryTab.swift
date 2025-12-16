//
//  SummaryTab.swift
//  benk
//
//  Created on 2025-12-15
//

import SwiftUI
import SwiftData

struct SummaryTab: View {
    let selectedDate: Date
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var themeService: ThemeService
    @Query private var userProfiles: [UserProfile]
    
    var userProfile: UserProfile {
        userProfiles.first ?? UserProfile()
    }
    
    // Get week containing selected date
    var weekDates: [Date] {
        let calendar = Calendar.current
        guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: selectedDate)?.start else {
            return []
        }
        
        return (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: weekStart)
        }
    }
    
    var weeklyStudyMinutes: Int {
        weekDates.reduce(0) { total, date in
            total + CalendarService.shared.getStudyMinutes(for: date, context: modelContext)
        }
    }
    
    var weeklyExamCount: Int {
        guard let weekStart = weekDates.first, let weekEnd = weekDates.last else { return 0 }
        return CalendarService.shared.getExams(from: weekStart, to: weekEnd, context: modelContext).count
    }
    
    var weeklyAssignmentCount: Int {
        guard let weekStart = weekDates.first, let weekEnd = weekDates.last else { return 0 }
        let assignments = CalendarService.shared.getAssignments(from: weekStart, to: weekEnd, context: modelContext)
        return assignments.filter { $0.status != .completed }.count
    }
    
    var productivityScore: Double {
        let daysMetGoal = weekDates.filter { date in
            let minutes = CalendarService.shared.getStudyMinutes(for: date, context: modelContext)
            return minutes >= userProfile.dailyGoalMinutes
        }.count
        
        return (Double(daysMetGoal) / 7.0) * 100
    }
    
    var body: some View {
        GlassCard(padding: 20) {
            VStack(alignment: .leading, spacing: 20) {
                // Title
                Text("Weekly Summary")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(themeService.currentTheme.text)
                
                // Stats Grid
                VStack(spacing: 16) {
                    StatRow(
                        icon: "clock.fill",
                        label: "Total Study Time",
                        value: formatHoursAndMinutes(weeklyStudyMinutes),
                        color: themeService.currentTheme.primary
                    )
                    
                    Divider()
                    
                    StatRow(
                        icon: "flame.fill",
                        label: "Current Streak",
                        value: "\(userProfile.currentStreak) days",
                        color: StreakMilestone.color(for: userProfile.currentStreak)
                    )
                    
                    Divider()
                    
                    StatRow(
                        icon: "doc.text.fill",
                        label: "Exams This Week",
                        value: "\(weeklyExamCount)",
                        color: .red
                    )
                    
                    Divider()
                    
                    StatRow(
                        icon: "pencil",
                        label: "Assignments Due",
                        value: "\(weeklyAssignmentCount)",
                        color: .orange
                    )
                    
                    Divider()
                    
                    // Productivity Score
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "chart.bar.fill")
                                .foregroundColor(.green)
                                .font(.title3)
                            
                            Text("Productivity Score")
                                .font(.subheadline)
                                .foregroundColor(themeService.currentTheme.text)
                            
                            Spacer()
                            
                            Text("\(Int(productivityScore))%")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                        }
                        
                        // Progress bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(themeService.currentTheme.textSecondary.opacity(0.2))
                                    .frame(height: 8)
                                
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(
                                        LinearGradient(
                                            colors: [.green, .green.opacity(0.7)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geometry.size.width * (productivityScore / 100), height: 8)
                            }
                        }
                        .frame(height: 8)
                    }
                }
            }
        }
    }
    
    private func formatHoursAndMinutes(_ minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        
        if hours > 0 && mins > 0 {
            return "\(hours)h \(mins)m"
        } else if hours > 0 {
            return "\(hours)h"
        } else {
            return "\(mins)m"
        }
    }
}

// MARK: - Stat Row
struct StatRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    @EnvironmentObject var themeService: ThemeService
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
            
            Text(label)
                .font(.subheadline)
                .foregroundColor(themeService.currentTheme.text)
            
            Spacer()
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
    }
}

#Preview {
    SummaryTab(selectedDate: Date())
        .environmentObject(ThemeService.shared)
        .modelContainer(for: [UserProfile.self, StudySession.self, Exam.self, Assignment.self])
}
