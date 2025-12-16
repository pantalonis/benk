//
//  DayTimelineView.swift
//  benk
//
//  Created on 2025-12-15
//  Revamped on 2025-12-16 to match iOS Calendar Day timeline
//
//  Full iOS Calendar-style day timeline with:
//  - Vertical scrollable timeline from 00:00-24:00
//  - Hour markers + subtle grid lines
//  - Red current-time indicator
//  - Auto-scroll to current time when viewing today
//  - Overlap detection with dynamic width splitting
//  - Interactive drag/resize for events
//

import SwiftUI
import SwiftData

// MARK: - Format Duration Helper
fileprivate func formatDuration(seconds: Int) -> String {
    let hours = seconds / 3600
    let minutes = (seconds % 3600) / 60
    let secs = seconds % 60
    
    var parts: [String] = []
    if hours > 0 { parts.append("\(hours)h") }
    if minutes > 0 { parts.append("\(minutes)m") }
    if secs > 0 || parts.isEmpty { parts.append("\(secs)s") }
    
    return parts.joined(separator: " ")
}

// MARK: - Timeline Event Type (for detail sheet)
enum TimelineEvent: Identifiable {
    case session(StudySession, Subject?)
    case event(Event)
    case exam(Exam, Subject?)
    case breakSession(BreakSession)
    
    var id: String {
        switch self {
        case .session(let session, _): return "session-\(session.id)"
        case .event(let event): return "event-\(event.id)"
        case .exam(let exam, _): return "exam-\(exam.id)"
        case .breakSession(let breakSession): return "break-\(breakSession.id)"
        }
    }
}

// MARK: - Timeline Item Wrapper
struct TimelineItemWrapper: TimelineItemProtocol {
    let id: UUID
    let timelineStartTime: Date
    let timelineEndTime: Date
    let timelineColor: Color
    let timelineTitle: String
    let subtitle: String?
    let icon: String?
    let isDashed: Bool
    let sourceType: SourceType
    
    enum SourceType {
        case studySession(StudySession)
        case event(Event)
        case exam(Exam)
        case breakSession(BreakSession)
    }
    
    static func from(_ session: StudySession, subject: Subject?) -> TimelineItemWrapper {
        let endTime = session.timestamp.addingTimeInterval(TimeInterval(session.duration))
        return TimelineItemWrapper(
            id: session.id,
            timelineStartTime: session.timestamp,
            timelineEndTime: endTime,
            timelineColor: subject?.color ?? .blue,
            timelineTitle: subject?.name ?? "Study Session",
            subtitle: formatDuration(seconds: session.duration),
            icon: "book.fill",
            isDashed: false,
            sourceType: .studySession(session)
        )
    }
    
    static func from(_ event: Event) -> TimelineItemWrapper {
        TimelineItemWrapper(
            id: event.id,
            timelineStartTime: event.startTime,
            timelineEndTime: event.endTime,
            timelineColor: event.color,
            timelineTitle: event.title,
            subtitle: event.location.isEmpty ? nil : event.location,
            icon: "calendar",
            isDashed: false,
            sourceType: .event(event)
        )
    }
    
    static func from(_ exam: Exam, subject: Subject?) -> TimelineItemWrapper {
        let durationMinutes = exam.duration ?? 60
        let endTime = exam.examDate.addingTimeInterval(TimeInterval(durationMinutes * 60))
        
        let title = exam.paperName.isEmpty ? (subject?.name ?? "Exam") : exam.paperName
        let subtitle = exam.paperName.isEmpty ? nil : subject?.name
        
        return TimelineItemWrapper(
            id: exam.id,
            timelineStartTime: exam.examDate,
            timelineEndTime: endTime,
            timelineColor: subject?.color ?? .red,
            timelineTitle: title,
            subtitle: subtitle,
            icon: "doc.text.fill",
            isDashed: false,
            sourceType: .exam(exam)
        )
    }
    
    static func from(_ breakSession: BreakSession) -> TimelineItemWrapper {
        let endTime = breakSession.timestamp.addingTimeInterval(TimeInterval(breakSession.duration))
        return TimelineItemWrapper(
            id: breakSession.id,
            timelineStartTime: breakSession.timestamp,
            timelineEndTime: endTime,
            timelineColor: .gray,
            timelineTitle: "Break",
            subtitle: formatDuration(seconds: breakSession.duration),
            icon: "pause.circle.fill",
            isDashed: true,
            sourceType: .breakSession(breakSession)
        )
    }
}

// MARK: - Day Timeline View
struct DayTimelineView: View {
    let selectedDate: Date
    @Binding var zoomLevel: CGFloat
    
    /// Track which item is currently in edit mode (nil = none) - passed to parent to disable dismiss gesture
    @Binding var editingItemId: UUID?
    
    @EnvironmentObject var themeService: ThemeService
    @Environment(\.modelContext) private var modelContext
    
    // MARK: - State
    @State private var lastMagnification: CGFloat = 1.0
    @State private var selectedEvent: TimelineEvent? = nil
    @State private var showingEventDetail = false
    @State private var containerWidth: CGFloat = 0
    
    // MARK: - Queries
    @Query private var allSessions: [StudySession]
    @Query private var allBreakSessions: [BreakSession]
    @Query private var subjects: [Subject]
    
    // MARK: - Layout Constants
    private let hourLabelWidth: CGFloat = 50
    private let rightPadding: CGFloat = 8
    
    // MARK: - Computed Properties
    
    var hourHeight: CGFloat {
        60 * zoomLevel
    }
    
    var pixelsPerMinute: CGFloat {
        hourHeight / 60.0
    }
    
    var timelineHeight: CGFloat {
        24 * hourHeight
    }
    
    var eventAreaWidth: CGFloat {
        max(0, containerWidth - hourLabelWidth - rightPadding)
    }
    
    var sessionsForDay: [StudySession] {
        let calendar = Calendar.current
        let dayStart = calendar.startOfDay(for: selectedDate)
        guard let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) else { return [] }
        
        return allSessions.filter { session in
            session.isCompleted && session.timestamp >= dayStart && session.timestamp < dayEnd
        }.sorted { $0.timestamp < $1.timestamp }
    }
    
    var breakSessionsForDay: [BreakSession] {
        let calendar = Calendar.current
        let dayStart = calendar.startOfDay(for: selectedDate)
        guard let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) else { return [] }
        
        return allBreakSessions.filter { breakSession in
            breakSession.timestamp >= dayStart && breakSession.timestamp < dayEnd
        }.sorted { $0.timestamp < $1.timestamp }
    }
    
    var events: [Event] {
        CalendarService.shared.getEvents(for: selectedDate, context: modelContext)
    }
    
    var exams: [Exam] {
        CalendarService.shared.getExams(for: selectedDate, context: modelContext)
    }
    
    var allTimelineItems: [TimelineItemWrapper] {
        var items: [TimelineItemWrapper] = []
        
        for session in sessionsForDay {
            let subject = subjects.first { $0.id == session.subjectId }
            items.append(.from(session, subject: subject))
        }
        
        for event in events {
            items.append(.from(event))
        }
        
        for exam in exams {
            let subject = subjects.first { $0.id == exam.subjectId }
            items.append(.from(exam, subject: subject))
        }
        
        for breakSession in breakSessionsForDay {
            items.append(.from(breakSession))
        }
        
        return items
    }
    
    var isToday: Bool {
        Calendar.current.isDateInToday(selectedDate)
    }
    
    var currentTimeOffset: CGFloat {
        TimelineLayoutHelper.yPosition(for: Date(), pixelsPerMinute: pixelsPerMinute)
    }
    
    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: true) {
                    ZStack(alignment: .topLeading) {
                        // Hour grid background - tap here to exit edit mode
                        hourGrid
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if editingItemId != nil {
                                    exitEditMode()
                                }
                            }
                        
                        // Event blocks layer
                        eventBlocksLayer
                        
                        // Current time indicator
                        if isToday {
                            currentTimeIndicator
                        }
                    }
                    .frame(width: geometry.size.width, height: timelineHeight)
                }
                .gesture(magnificationGesture)
                .onAppear {
                    containerWidth = geometry.size.width
                    
                    if isToday {
                        let currentHour = Calendar.current.component(.hour, from: Date())
                        let targetHour = max(0, currentHour - 2)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation(.easeOut(duration: 0.3)) {
                                proxy.scrollTo(targetHour, anchor: .top)
                            }
                        }
                    }
                }
                .onChange(of: geometry.size.width) { _, newWidth in
                    containerWidth = newWidth
                }
                .sheet(isPresented: $showingEventDetail) {
                    if let event = selectedEvent {
                        EventDetailSheet(event: event)
                    }
                }
            }
        }
    }
    
    // MARK: - Hour Grid
    private var hourGrid: some View {
        VStack(spacing: 0) {
            ForEach(0..<24, id: \.self) { hour in
                HStack(alignment: .top, spacing: 0) {
                    Text(formatHour(hour))
                        .font(.caption)
                        .foregroundColor(themeService.currentTheme.textSecondary)
                        .frame(width: hourLabelWidth, alignment: .trailing)
                        .padding(.trailing, 8)
                        .offset(y: -6)
                    
                    VStack(spacing: 0) {
                        Rectangle()
                            .fill(themeService.currentTheme.textSecondary.opacity(0.2))
                            .frame(height: 1)
                        
                        if zoomLevel >= 1.0 {
                            Spacer()
                                .frame(height: hourHeight / 2 - 1)
                            
                            Rectangle()
                                .fill(themeService.currentTheme.textSecondary.opacity(0.1))
                                .frame(height: 1)
                            
                            Spacer()
                                .frame(height: hourHeight / 2 - 1)
                        } else {
                            Spacer()
                                .frame(height: hourHeight - 1)
                        }
                    }
                }
                .frame(height: hourHeight)
                .id(hour)
            }
        }
    }
    
    // MARK: - Event Blocks Layer
    @ViewBuilder
    private var eventBlocksLayer: some View {
        let items = allTimelineItems
        let layouts = TimelineLayoutHelper.calculateLayout(
            items: items,
            pixelsPerMinute: pixelsPerMinute,
            availableWidth: eventAreaWidth,
            horizontalPadding: 2
        )
        
        let layoutDict = Dictionary(uniqueKeysWithValues: layouts.map { ($0.id, $0) })
        
        ForEach(items) { item in
            if let layout = layoutDict[item.id] {
                let adjustedLayout = TimelineLayoutInfo(
                    id: layout.id,
                    x: layout.x + hourLabelWidth,
                    width: layout.width,
                    y: layout.y,
                    height: layout.height,
                    column: layout.column,
                    totalColumns: layout.totalColumns
                )
                
                InteractiveEventBlock(
                    title: item.timelineTitle,
                    subtitle: item.subtitle,
                    color: item.timelineColor,
                    icon: item.icon,
                    isDashed: item.isDashed,
                    layoutInfo: adjustedLayout,
                    pixelsPerMinute: pixelsPerMinute,
                    selectedDate: selectedDate,
                    isEditing: editingBinding(for: item.id),
                    onTimeChange: { newStart, newEnd in
                        handleTimeChange(for: item, newStart: newStart, newEnd: newEnd)
                    },
                    onTap: {
                        handleTap(for: item)
                    }
                )
            }
        }
    }
    
    // MARK: - Current Time Indicator
    private var currentTimeIndicator: some View {
        HStack(spacing: 0) {
            Circle()
                .fill(Color.red)
                .frame(width: 10, height: 10)
                .offset(x: hourLabelWidth - 5)
            
            Rectangle()
                .fill(Color.red)
                .frame(height: 2)
        }
        .offset(y: currentTimeOffset - 1)
    }
    
    // MARK: - Magnification Gesture
    private var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                let delta = value / lastMagnification
                lastMagnification = value
                let newZoom = max(0.5, min(3.0, zoomLevel * delta))
                zoomLevel = newZoom
            }
            .onEnded { _ in
                lastMagnification = 1.0
            }
    }
    
    // MARK: - Helpers
    
    /// Create a binding for whether a specific item is editing
    private func editingBinding(for itemId: UUID) -> Binding<Bool> {
        Binding(
            get: { editingItemId == itemId },
            set: { isEditing in
                if isEditing {
                    editingItemId = itemId
                } else if editingItemId == itemId {
                    editingItemId = nil
                }
            }
        )
    }
    
    private func exitEditMode() {
        editingItemId = nil
        HapticManager.shared.light()
    }
    
    private func formatHour(_ hour: Int) -> String {
        switch hour {
        case 0: return "12 AM"
        case 1...11: return "\(hour) AM"
        case 12: return "12 PM"
        default: return "\(hour - 12) PM"
        }
    }
    
    private func handleTimeChange(for item: TimelineItemWrapper, newStart: Date, newEnd: Date) {
        switch item.sourceType {
        case .event(let event):
            event.startTime = newStart
            event.endTime = newEnd
            try? modelContext.save()
            
        case .exam(let exam):
            exam.examDate = newStart
            let durationMinutes = Int(newEnd.timeIntervalSince(newStart) / 60)
            exam.duration = max(15, durationMinutes)
            try? modelContext.save()
            
        case .studySession(_), .breakSession(_):
            // Historical data - don't allow editing
            break
        }
    }
    
    private func handleTap(for item: TimelineItemWrapper) {
        switch item.sourceType {
        case .studySession(let session):
            let subject = subjects.first { $0.id == session.subjectId }
            selectedEvent = .session(session, subject)
        case .event(let event):
            selectedEvent = .event(event)
        case .exam(let exam):
            let subject = subjects.first { $0.id == exam.subjectId }
            selectedEvent = .exam(exam, subject)
        case .breakSession(let breakSession):
            selectedEvent = .breakSession(breakSession)
        }
        
        showingEventDetail = true
        HapticManager.shared.selection()
    }
}

// MARK: - Preview
#Preview {
    struct PreviewWrapper: View {
        @State private var zoom: CGFloat = 1.0
        @State private var editingItemId: UUID? = nil
        
        var body: some View {
            DayTimelineView(selectedDate: Date(), zoomLevel: $zoom, editingItemId: $editingItemId)
                .environmentObject(ThemeService.shared)
                .modelContainer(for: [
                    StudySession.self,
                    BreakSession.self,
                    Event.self,
                    Exam.self,
                    Subject.self
                ])
        }
    }
    
    return PreviewWrapper()
}
