//
//  CalendarBar.swift
//  benk
//
//  Created on 2025-12-13.
//

import SwiftUI
import SwiftData

struct CalendarBar: View {
    @Binding var selectedDate: Date
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var themeService: ThemeService
    
    @Query private var userProfiles: [UserProfile]
    @Query(filter: #Predicate<StudySession> { $0.isCompleted })
    private var completedSessions: [StudySession]
    
    // Structure to hold weeks
    struct Week: Identifiable, Hashable {
        let id = UUID()
        let days: [Date]
    }
    
    @State private var weeks: [Week] = []
    @State private var selectedWeekId: UUID?
    
    var userProfile: UserProfile {
        userProfiles.first ?? UserProfile()
    }
    
    var dailyGoalMinutes: Int {
        max(1, userProfile.dailyGoalMinutes)
    }
    
    // Pre-calculate session lookup dictionary for O(1) access per day
    private var sessionsByDay: [Date: [StudySession]] {
        Dictionary(grouping: completedSessions) { session in
            Calendar.current.startOfDay(for: session.timestamp)
        }
    }
    
    private func generateWeeks() {
        var calendar = Calendar.current
        // Force Monday as start of week for this logic
        calendar.firstWeekday = 2 // Monday
        
        // Normalize the externally provided selection
        let referenceDate = calendar.startOfDay(for: selectedDate)
        selectedDate = referenceDate
        
        // Calculate the start of the current week (Monday)
        let weekday = calendar.component(.weekday, from: referenceDate) // Sun=1, Mon=2 ...
        // We want to shift to Monday (2).
        // If 2 (Mon), shift 0.
        // If 3 (Tue), shift -1.
        // If 1 (Sun), shift -6.
        let daysActive = (weekday + 5) % 7 // Mon(2)->0, Tue(3)->1, Sun(1)->6
        
        guard let currentWeekMonday = calendar.date(byAdding: .day, value: -daysActive, to: referenceDate) else { return }
        
        // We want 5 weeks: 3 past, Current, 1 Future.
        // Start date = CurrentMonday - 3 weeks
        guard let startOfTimeline = calendar.date(byAdding: .weekOfYear, value: -3, to: currentWeekMonday) else { return }
        
        var newWeeks: [Week] = []
        var currentWeekIdIfFound: UUID?
        
        for w in 0..<5 {
            guard let weekStart = calendar.date(byAdding: .weekOfYear, value: w, to: startOfTimeline) else { continue }
            
            var weekDays: [Date] = []
            for d in 0..<7 {
                if let day = calendar.date(byAdding: .day, value: d, to: weekStart) {
                    weekDays.append(day)
                }
            }
            
            let week = Week(days: weekDays)
            newWeeks.append(week)
            
            // Check if this week contains the selected day to set initial selection
            if weekDays.contains(where: { calendar.isDate($0, inSameDayAs: referenceDate) }) {
                currentWeekIdIfFound = week.id
            }
        }
        
        self.weeks = newWeeks
        // Set selection to current week
        if let current = currentWeekIdIfFound {
            self.selectedWeekId = current
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            // Add padding between weeks by counting it in the width calculation
            let weekPadding: CGFloat = 16 // Gap between weeks
            let itemWidth = (geometry.size.width - weekPadding) / 7
            
            if !weeks.isEmpty {
                TabView(selection: $selectedWeekId) {
                    ForEach(weeks) { week in
                        HStack(spacing: 0) {
                            ForEach(week.days, id: \.self) { date in
                                let dayStart = Calendar.current.startOfDay(for: date)
                                let daySessions = sessionsByDay[dayStart] ?? []
                                
                                CalendarDayItem(
                                    date: date,
                                    width: itemWidth,
                                    goalMinutes: dailyGoalMinutes,
                                    userCreatedAt: userProfile.createdAt,
                                    daySessions: daySessions,
                                    isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate)
                                )
                                .onTapGesture {
                                    selectedDate = Calendar.current.startOfDay(for: date)
                                    HapticManager.shared.selection()
                                }
                            }
                        }
                        .padding(.horizontal, weekPadding / 2) // Half gap on each side
                        .tag(week.id as UUID?)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
        }
        .frame(height: 80) // increased height for bigger touch target/glass
        .onAppear {
            generateWeeks()
        }
    }
}

// Optimized CalendarDayItem - receives pre-filtered sessions instead of filtering all sessions
struct CalendarDayItem: View {
    let date: Date
    let width: CGFloat
    let goalMinutes: Int
    let userCreatedAt: Date
    let daySessions: [StudySession]  // Pre-filtered sessions for this day
    let isSelected: Bool
    
    @EnvironmentObject var themeService: ThemeService
    
    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    var isChristmasDay: Bool {
        let components = Calendar.current.dateComponents([.month, .day], from: date)
        return components.month == 12 && components.day == 25
    }
    
    var isBeforeAppAndEmpty: Bool {
        let calendar = Calendar.current
        let isBeforeApp = calendar.startOfDay(for: date) < calendar.startOfDay(for: userCreatedAt)
        return isBeforeApp && daySessions.isEmpty
    }
    
    var dayProgress: Double {
        let totalSeconds = daySessions.reduce(0) { $0 + $1.duration }
        let totalMins = Double(totalSeconds) / 60.0
        
        return totalMins / Double(goalMinutes)
    }
    
    var body: some View {
        let progress = dayProgress
        let isExceeded = progress >= 1.0
        let showActivity = progress > 0
        
        VStack(spacing: 6) {
            // Day Name (Mon, Tue)
            Text(date.formatted(.dateTime.weekday(.abbreviated)))
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(
                    isSelected
                    ? themeService.currentTheme.text
                    : (isToday ? themeService.currentTheme.textSecondary : themeService.currentTheme.textSecondary)
                )
            
            // Circle Indicator
            ZStack {
                if isBeforeAppAndEmpty {
                    // Pre-download: Dashed (Ghost)
                    Circle()
                        .stroke(
                            themeService.currentTheme.textSecondary.opacity(0.3),
                            style: StrokeStyle(lineWidth: 1.5, lineCap: .round, dash: [4, 4])
                        )
                } else {
                    // Post-download: Solid Gray Track (Empty Bar)
                    Circle()
                        .stroke(themeService.currentTheme.textSecondary.opacity(0.2), lineWidth: 2)
                    
                    // Progress Fill
                    if showActivity {
                        Circle()
                            .trim(from: 0, to: min(1.0, progress))
                            .stroke(
                                isExceeded ? Color.green : themeService.currentTheme.accent,
                                style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                            .shadow(color: (isExceeded ? Color.green : themeService.currentTheme.accent).opacity(0.5), radius: 6)
                    }
                }
                
                // Date Number or Christmas Hat for the 25th
                if isChristmasDay && themeService.currentTheme.isChristmas {
                    Text("🎅")
                        .font(.system(size: 14))
                } else {
                    Text(date.formatted(.dateTime.day()))
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(
                            isSelected
                            ? themeService.currentTheme.text
                            : (isToday
                               ? themeService.currentTheme.textSecondary
                               : (showActivity ? themeService.currentTheme.text : themeService.currentTheme.textSecondary))
                        )
                }
            }
            .frame(width: 32, height: 32)
        }
        .frame(width: width)
        .padding(.vertical, 8)
        .background {
            // Highlight: selected is strong; today-only is subtle
            if isSelected {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(LinearGradient(
                                colors: [
                                    .white.opacity(0.5),
                                    .white.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    .padding(2) // slightly smaller highlight
            } else if isToday {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
                    .padding(2) // slightly smaller highlight
            }
        }
    }
}
