//
//  WeekCalendarBar.swift
//  benk
//
//  Created on 2025-12-15
//

import SwiftUI

struct WeekCalendarBar: View {
    @Binding var selectedDate: Date
    @EnvironmentObject var themeService: ThemeService
    
    var weekDates: [Date] {
        let calendar = Calendar.current
        guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: selectedDate)?.start else {
            return []
        }
        
        return (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: weekStart)
        }
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(weekDates, id: \.self) { date in
                        DayCell(
                            date: date,
                            isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate),
                            action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedDate = date
                                }
                                HapticManager.shared.selection()
                            }
                        )
                        .id(date)
                    }
                }
                .padding(.horizontal)
            }
            .onAppear {
                // Auto-scroll to selected date
                proxy.scrollTo(selectedDate, anchor: .center)
            }
        }
    }
}

struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let action: () -> Void
    @EnvironmentObject var themeService: ThemeService
    
    var dayLetter: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return String(formatter.string(from: date).prefix(1))
    }
    
    var dayNumber: String {
        let calendar = Calendar.current
        return "\(calendar.component(.day, from: date))"
    }
    
    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(dayLetter)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : themeService.currentTheme.textSecondary)
                
                Text(dayNumber)
                    .font(.subheadline)
                    .fontWeight(isToday ? .bold : .semibold)
                    .foregroundColor(isSelected ? .white : (isToday ? themeService.currentTheme.primary : themeService.currentTheme.text))
            }
            .frame(width: 44, height: 60)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? themeService.currentTheme.primary : (isToday ? themeService.currentTheme.primary.opacity(0.1) : Color.clear))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isToday && !isSelected ? themeService.currentTheme.primary : Color.clear, lineWidth: 1.5)
            )
        }
    }
}

#Preview {
    WeekCalendarBar(selectedDate: .constant(Date()))
        .environmentObject(ThemeService.shared)
        .padding()
}
