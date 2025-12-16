//
//  MonthView.swift
//  benk
//
//  Created on 2025-12-15
//

import SwiftUI
import SwiftData

struct MonthView: View {
    @ObservedObject var viewModel: CalendarViewModel
    @Binding var showingDayDetail: Bool
    var contentTopPadding: CGFloat = 0 // New parameter
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var themeService: ThemeService
    @Query private var userProfiles: [UserProfile]
    
    @State private var showingHeatMapMenu = false
    
    var userProfile: UserProfile {
        userProfiles.first ?? UserProfile()
    }
    
    // Fixed anchor: the first of this month
    private var todayMonthAnchor: Date {
        let calendar = Calendar.current
        let today = Date()
        let components = calendar.dateComponents([.year, .month], from: today)
        return calendar.date(from: components) ?? today
    }
    
    // Generate 12 months: 6 past, current, 5 future (from fixed anchor)
    var months: [Date] {
        let calendar = Calendar.current
        var result: [Date] = []
        
        for offset in -6...5 {
            if let month = calendar.date(byAdding: .month, value: offset, to: todayMonthAnchor) {
                result.append(month)
            }
        }
        return result
    }
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Main content - Free scroll without snapping
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        ForEach(months, id: \.self) { month in
                            MonthGridView(
                                month: month,
                                viewModel: viewModel,
                                showingDayDetail: $showingDayDetail,
                                userProfile: userProfile
                            )
                            .id(month)
                        }
                    }
                }
                .contentMargins(.top, contentTopPadding, for: .scrollContent)
                .onAppear {
                    // Only scroll to current month on initial appear
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        proxy.scrollTo(todayMonthAnchor, anchor: .top)
                    }
                }
                .onChange(of: viewModel.currentMonth) { oldValue, newValue in
                    // Check if goToToday was called (currentMonth is set to today's month)
                    let calendar = Calendar.current
                    let isSameAsToday = calendar.isDate(newValue, equalTo: Date(), toGranularity: .month)
                    
                    if isSameAsToday {
                        // Use todayMonthAnchor for consistent scrolling
                        withAnimation(.easeInOut(duration: 0.3)) {
                            proxy.scrollTo(todayMonthAnchor, anchor: .top)
                        }
                    } else {
                        // Scroll to the specific month
                        withAnimation(.easeInOut(duration: 0.3)) {
                            proxy.scrollTo(newValue, anchor: .top)
                        }
                    }
                }
                .onChange(of: viewModel.scrollToTodayTrigger) { _, _ in
                    // Manually triggered "Today" scroll (even if month didn't change)
                    withAnimation(.easeInOut(duration: 0.3)) {
                        proxy.scrollTo(todayMonthAnchor, anchor: .top)
                    }
                }
            }
            
            // Floating Heat Map Button
            VStack(spacing: 0) {
                // Drop-up menu - 2x2 Grid
                if showingHeatMapMenu {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        // Off option
                        HeatMapOptionButton(
                            icon: "xmark.circle.fill",
                            label: "Off",
                            isSelected: viewModel.heatMapMode == nil,
                            themeService: themeService
                        ) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                viewModel.heatMapMode = nil
                                showingHeatMapMenu = false
                            }
                            HapticManager.shared.selection()
                        }
                        
                        // Productivity option
                        HeatMapOptionButton(
                            icon: "chart.bar.fill",
                            label: "Productivity",
                            isSelected: viewModel.heatMapMode == .productivity,
                            themeService: themeService
                        ) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                viewModel.heatMapMode = .productivity
                                showingHeatMapMenu = false
                            }
                            HapticManager.shared.selection()
                        }
                        
                        // Exam Load option
                        HeatMapOptionButton(
                            icon: "doc.text.fill",
                            label: "Exam Load",
                            isSelected: viewModel.heatMapMode == .examLoad,
                            themeService: themeService
                        ) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                viewModel.heatMapMode = .examLoad
                                showingHeatMapMenu = false
                            }
                            HapticManager.shared.selection()
                        }
                        
                        // Assignment Load option
                        HeatMapOptionButton(
                            icon: "checkmark.square.fill",
                            label: "Assignment",
                            isSelected: viewModel.heatMapMode == .assignmentLoad,
                            themeService: themeService
                        ) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                viewModel.heatMapMode = .assignmentLoad
                                showingHeatMapMenu = false
                            }
                            HapticManager.shared.selection()
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                // Main button
                Button(action: {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                        showingHeatMapMenu.toggle()
                    }
                    HapticManager.shared.selection()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 16))
                        Text(viewModel.heatMapMode?.displayName ?? "Heat Map")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(themeService.currentTheme.primary)
                            .shadow(color: themeService.currentTheme.primary.opacity(0.4), radius: 8, x: 0, y: 4)
                    )
                }
            }
            .padding(.leading, 16)
            .padding(.bottom, 16)
        }
    }
}

// MARK: - Month Grid View
struct MonthGridView: View, Equatable {
    let month: Date
    @ObservedObject var viewModel: CalendarViewModel
    @Binding var showingDayDetail: Bool
    let userProfile: UserProfile
    @EnvironmentObject var themeService: ThemeService
    
    // Cached DateFormatter for better performance
    private static let monthYearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    var monthYearText: String {
        Self.monthYearFormatter.string(from: month)
    }
    
    var calendarGrid: [Date?] {
        CalendarViewModel.generateCalendarGrid(for: month)
    }
    
    // Equatable conformance for performance
    static func == (lhs: MonthGridView, rhs: MonthGridView) -> Bool {
        lhs.month == rhs.month && lhs.userProfile.id == rhs.userProfile.id
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Month/Year Header
            Text(monthYearText)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(themeService.currentTheme.text)
                .padding(.top, 16)
                .padding(.bottom, 8)
            
            // Weekday Headers
            HStack(spacing: 0) {
                ForEach(Array(["S", "M", "T", "W", "T", "F", "S"].enumerated()), id: \.offset) { index, day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(themeService.currentTheme.textSecondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
            
            // Calendar Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 8) {
                ForEach(Array(calendarGrid.enumerated()), id: \.offset) { index, date in
                    if let date = date {
                        Button(action: {
                            viewModel.selectDate(date)
                            showingDayDetail = true
                            HapticManager.shared.selection()
                        }) {
                            DayProgressRing(
                                date: date,
                                dailyGoalMinutes: userProfile.dailyGoalMinutes,
                                heatMapMode: viewModel.heatMapMode
                            )
                        }
                        .buttonStyle(.plain)
                    } else {
                        Color.clear
                            .frame(height: 40)
                    }
                }
            }
            .drawingGroup()
            .padding(.horizontal)
            .padding(.bottom, 16)
        }
    }
}

// MARK: - Heat Map Option Button
struct HeatMapOptionButton: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let themeService: ThemeService
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? themeService.currentTheme.primary : themeService.currentTheme.textSecondary)
                
                Text(label)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? themeService.currentTheme.primary : themeService.currentTheme.text)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? themeService.currentTheme.primary.opacity(0.15) : Color.clear)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? themeService.currentTheme.primary : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    MonthView(viewModel: CalendarViewModel(), showingDayDetail: .constant(false))
        .environmentObject(ThemeService.shared)
        .modelContainer(for: [UserProfile.self, StudySession.self])
}
