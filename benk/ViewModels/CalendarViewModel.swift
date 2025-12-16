//
//  CalendarViewModel.swift
//  benk
//
//  Created on 2025-12-15
//

import Foundation
import SwiftUI
import SwiftData

@MainActor
class CalendarViewModel: ObservableObject {
    @Published var currentMonth: Date = Date()
    @Published var selectedDate: Date = Date()
    @Published var heatMapMode: HeatMapMode? = nil //nil means off
    @Published var searchQuery: String = ""
    @Published var activeFilters: [CalendarFilter] = []
    @Published var searchResults: [CalendarSearchResult] = []
    
    // Computed property: Days in current month
    var daysInMonth: [Date] {
        guard let monthStart = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: currentMonth)),
              let monthEnd = Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: monthStart) else {
            return []
        }
        
        var days: [Date] = []
        var currentDate = monthStart
        
        while currentDate <= monthEnd {
            days.append(currentDate)
            guard let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDay
        }
        
        return days
    }
    
    // Computed property: Full calendar grid (including padding days from previous/next month)
    var calendarGrid: [Date?] {
        guard let monthStart = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: currentMonth)) else {
            return []
        }
        
        let firstWeekday = Calendar.current.component(.weekday, from: monthStart)
        let daysInMonth = self.daysInMonth
        
        var grid: [Date?] = []
        
        // Add padding days from previous month
        for _ in 1..<firstWeekday {
            grid.append(nil)
        }
        
        // Add current month days
        grid.append(contentsOf: daysInMonth.map { $0 as Date? })
        
        // Pad to complete weeks
        while grid.count % 7 != 0 {
            grid.append(nil)
        }
        
        return grid
    }
    
    // Navigation functions
    func goToPreviousMonth() {
        if let newMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) {
            currentMonth = newMonth
        }
    }
    
    func goToNextMonth() {
        if let newMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) {
            currentMonth = newMonth
        }
    }
    
    func goToToday() {
        let today = Date()
        selectedDate = today
        // Get start of the current month
        let components = Calendar.current.dateComponents([.year, .month], from: today)
        currentMonth = Calendar.current.date(from: components) ?? today
    }
    
    func selectDate(_ date: Date) {
        selectedDate = date
    }
    
    // Search function
    func performSearch(context: ModelContext) {
        if searchQuery.isEmpty {
            searchResults = []
        } else {
            searchResults = CalendarService.shared.searchCalendar(
                query: searchQuery,
                filters: activeFilters,
                context: context
            )
        }
    }
    
    // Toggle filter
    func toggleFilter(_ filter: CalendarFilter, context: ModelContext) {
        if activeFilters.contains(filter) {
            activeFilters.removeAll { $0 == filter }
        } else {
            activeFilters.append(filter)
        }
        performSearch(context: context)
    }
    
    // Static helper for generating calendar grid for any month
    static func generateCalendarGrid(for month: Date) -> [Date?] {
        guard let monthStart = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: month)),
              let monthEnd = Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: monthStart) else {
            return []
        }
        
        var daysInMonth: [Date] = []
        var currentDate = monthStart
        
        while currentDate <= monthEnd {
            daysInMonth.append(currentDate)
            guard let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDay
        }
        
        let firstWeekday = Calendar.current.component(.weekday, from: monthStart)
        
        var grid: [Date?] = []
        
        // Add padding days from previous month
        for _ in 1..<firstWeekday {
            grid.append(nil)
        }
        
        // Add current month days
        grid.append(contentsOf: daysInMonth.map { $0 as Date? })
        
        // Pad to complete weeks
        while grid.count % 7 != 0 {
            grid.append(nil)
        }
        
        return grid
    }
}
