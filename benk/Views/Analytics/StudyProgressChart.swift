//
//  StudyProgressChart.swift
//  benk
//
//  Created on 2025-12-13.
//

import SwiftUI
import Charts
import SwiftData

struct StudyProgressChart: View {
    let sessions: [StudySession]
    @EnvironmentObject var themeService: ThemeService
    
    @State private var selectedRange: ChartTimeRange = .days90
    
    enum ChartTimeRange: String, CaseIterable {
        case days90 = "90D"
        case months6 = "6M"
        case year1 = "1Y"
        case all = "All"
        
        var days: Int? {
            switch self {
            case .days90: return 90
            case .months6: return 180
            case .year1: return 365
            case .all: return nil
            }
        }
    }
    
    struct DailyData: Identifiable {
        let date: Date
        let hours: Double
        var id: Date { date }
    }
    
    var chartData: [DailyData] {
        let calendar = Calendar.current
        let now = Date()
        
        // Filter by time range
        let filteredSessions: [StudySession]
        if let days = selectedRange.days,
           let startDate = calendar.date(byAdding: .day, value: -days, to: now) {
            filteredSessions = sessions.filter { $0.timestamp >= startDate }
        } else {
            filteredSessions = sessions
        }
        
        // Group by day
        let grouped = Dictionary(grouping: filteredSessions) { session in
            calendar.startOfDay(for: session.timestamp)
        }
        
        // Sum hours per day
        let data = grouped.map { (date, sessions) -> DailyData in
            let totalSeconds = sessions.reduce(0) { $0 + $1.duration }
            let totalHours = Double(totalSeconds) / 3600.0
            return DailyData(date: date, hours: totalHours)
        }
        
        return data.sorted { $0.date < $1.date }
    }
    
    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Study Progress")
                        .font(.headline)
                        .foregroundColor(themeService.currentTheme.text)
                    
                    Spacer()
                    
                    Picker("Range", selection: $selectedRange) {
                        ForEach(ChartTimeRange.allCases, id: \.self) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 160)
                }
                
                if chartData.isEmpty {
                    VStack {
                        Spacer()
                        Text("No data available for this period")
                            .font(.caption)
                            .foregroundColor(themeService.currentTheme.textSecondary)
                        Spacer()
                    }
                    .frame(height: 200)
                } else {
                    Chart(chartData) { item in
                        LineMark(
                            x: .value("Date", item.date),
                            y: .value("Hours", item.hours)
                        )
                        .foregroundStyle(themeService.currentTheme.accent)
                        .interpolationMethod(.catmullRom)
                        
                        AreaMark(
                            x: .value("Date", item.date),
                            y: .value("Hours", item.hours)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    themeService.currentTheme.accent.opacity(0.3),
                                    themeService.currentTheme.accent.opacity(0.0)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    }
                    .frame(height: 200)
                    .chartXAxis {
                        AxisMarks(values: .automatic) { _ in
                            AxisValueLabel(format: .dateTime.month().day())
                                .foregroundStyle(themeService.currentTheme.textSecondary)
                        }
                    }
                    .chartYAxis {
                        AxisMarks { _ in
                            AxisGridLine()
                            AxisValueLabel()
                                .foregroundStyle(themeService.currentTheme.textSecondary)
                        }
                    }
                }
            }
        }
    }
}
