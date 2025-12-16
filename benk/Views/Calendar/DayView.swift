//
//  DayView.swift
//  benk
//
//  Created on 2025-12-15
//  Updated on 2025-12-16 to integrate iOS Calendar-style timeline
//

import SwiftUI
import SwiftData

struct DayView: View {
    @ObservedObject var viewModel: CalendarViewModel
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var themeService: ThemeService
    
    @State private var selectedSegment: DaySegment = .timeline
    @State private var timelineZoom: CGFloat = 1.0
    @State private var editingItemId: UUID? = nil
    
    enum DaySegment: String, CaseIterable {
        case timeline = "Timeline"   // Main iOS Calendar-style view
        case activity = "Activity"   // Historical study sessions
        case summary = "Summary"     // Day statistics
    }
    
    var selectedDateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter.string(from: viewModel.selectedDate)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Date Header
            Text(selectedDateText)
                .font(.headline)
                .foregroundColor(themeService.currentTheme.text)
                .padding(.horizontal)
                .padding(.vertical, 12)
            
            // Segmented Control
            Picker("View", selection: $selectedSegment) {
                ForEach(DaySegment.allCases, id: \.self) { segment in
                    Text(segment.rawValue).tag(segment)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.bottom, 8)
            
            // Tab Content
            Group {
                switch selectedSegment {
                case .timeline:
                    // iOS Calendar-style day timeline with events, exams, sessions
                    DayTimelineView(
                        selectedDate: viewModel.selectedDate,
                        zoomLevel: $timelineZoom,
                        editingItemId: $editingItemId
                    )
                    
                case .activity:
                    // Historical activity log (scrollable list)
                    ScrollView(showsIndicators: false) {
                        ActivityTab(selectedDate: viewModel.selectedDate)
                            .padding(.horizontal)
                    }
                    
                case .summary:
                    // Day statistics summary
                    ScrollView(showsIndicators: false) {
                        SummaryTab(selectedDate: viewModel.selectedDate)
                            .padding(.horizontal)
                    }
                }
            }
        }
    }
}

#Preview {
    DayView(viewModel: CalendarViewModel())
        .environmentObject(ThemeService.shared)
        .modelContainer(for: [
            Event.self,
            Exam.self,
            Assignment.self,
            StudySession.self,
            BreakSession.self,
            Subject.self
        ])
}
