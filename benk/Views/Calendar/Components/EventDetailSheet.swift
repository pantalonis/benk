//
//  EventDetailSheet.swift
//  benk
//
//  Created on 2025-12-15
//  Updated on 2025-12-16 to match ExamDetailView design
//
//  Unified detail sheet for all timeline events:
//  - Events & Exams: can edit and delete
//  - StudySessions & BreakSessions: can only delete (historical data)
//

import SwiftUI
import SwiftData

struct EventDetailSheet: View {
    let event: TimelineEvent
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var themeService: ThemeService
    @Query private var subjects: [Subject]
    
    @State private var showEditSheet = false
    @State private var showDeleteAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                ThemedBackground(theme: themeService.currentTheme)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Header Card
                        headerCard
                        
                        // Details Card
                        detailsCard
                        
                        // Notes Card (if applicable)
                        if hasNotes {
                            notesCard
                        }
                        
                        // Action Buttons
                        actionButtons
                        
                        Spacer(minLength: 40)
                    }
                    .padding()
                }
            }
            .navigationTitle(eventTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(themeService.currentTheme.accent)
                }
            }
            .sheet(isPresented: $showEditSheet) {
                editSheet
            }
            .alert(deleteAlertTitle, isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    deleteItem()
                }
            } message: {
                Text("Are you sure you want to delete this \(eventTypeName.lowercased())? This action cannot be undone.")
            }
        }
    }
    
    // MARK: - Event Properties
    
    private var eventTitle: String {
        switch event {
        case .session: return "Study Session"
        case .event: return "Event Details"
        case .exam: return "Exam Details"
        case .breakSession: return "Break"
        }
    }
    
    private var eventTypeName: String {
        switch event {
        case .session: return "Session"
        case .event: return "Event"
        case .exam: return "Exam"
        case .breakSession: return "Break"
        }
    }
    
    private var canEdit: Bool {
        switch event {
        case .event, .exam: return true
        case .session, .breakSession: return false // Historical data
        }
    }
    
    private var hasNotes: Bool {
        switch event {
        case .event(let event): return !event.notes.isEmpty
        case .exam(let exam, _): return !exam.examDescription.isEmpty
        default: return false
        }
    }
    
    private var deleteAlertTitle: String {
        "Delete \(eventTypeName)"
    }
    
    private var eventColor: Color {
        switch event {
        case .session(_, let subject): return subject?.color ?? .blue
        case .event(let event): return event.color
        case .exam(_, let subject): return subject?.color ?? .red
        case .breakSession: return .gray
        }
    }
    
    // MARK: - Header Card
    private var headerCard: some View {
        GlassCard(padding: 20) {
            VStack(spacing: 16) {
                switch event {
                case .session(let session, let subject):
                    sessionHeader(session: session, subject: subject)
                case .event(let event):
                    eventHeader(event: event)
                case .exam(let exam, let subject):
                    examHeader(exam: exam, subject: subject)
                case .breakSession(let breakSession):
                    breakHeader(breakSession: breakSession)
                }
            }
        }
        .animatedAppearance(delay: 0.1)
    }
    
    @ViewBuilder
    private func sessionHeader(session: StudySession, subject: Subject?) -> some View {
        HStack {
            // Subject tag or icon
            HStack(spacing: 8) {
                Image(systemName: "book.fill")
                    .foregroundColor(subject?.color ?? .blue)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(subject?.name ?? "Study Session")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(themeService.currentTheme.text)
                    
                    Text("Completed Session")
                        .font(.caption)
                        .foregroundColor(themeService.currentTheme.textSecondary)
                }
            }
            
            Spacer()
            
            // XP Badge
            HStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                Text("\(session.xpEarned) XP")
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(Color.orange.opacity(0.2))
            )
        }
    }
    
    @ViewBuilder
    private func eventHeader(event: Event) -> some View {
        HStack {
            HStack(spacing: 8) {
                Circle()
                    .fill(event.color)
                    .frame(width: 16, height: 16)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(event.title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(themeService.currentTheme.text)
                    
                    if !event.location.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "location.fill")
                                .font(.caption)
                            Text(event.location)
                                .font(.caption)
                        }
                        .foregroundColor(themeService.currentTheme.textSecondary)
                    }
                }
            }
            
            Spacer()
        }
    }
    
    @ViewBuilder
    private func examHeader(exam: Exam, subject: Subject?) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                // Paper name and subject
                HStack(spacing: 8) {
                    Text(exam.paperName.isEmpty ? "Exam" : exam.paperName)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(themeService.currentTheme.text)
                    
                    if let subject = subject {
                        Text(subject.name)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                Capsule()
                                    .fill(subject.color)
                            )
                    }
                }
                
                // Countdown
                Text(exam.countdownText)
                    .font(.caption)
                    .foregroundColor(exam.urgency.color)
            }
            
            Spacer()
            
            // Urgency Badge
            if exam.urgency == .today || exam.urgency == .urgent {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(exam.urgency.color)
                    .font(.title2)
            }
        }
    }
    
    @ViewBuilder
    private func breakHeader(breakSession: BreakSession) -> some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "pause.circle.fill")
                    .foregroundColor(.gray)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Break")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(themeService.currentTheme.text)
                    
                    Text(breakSession.tag)
                        .font(.caption)
                        .foregroundColor(themeService.currentTheme.textSecondary)
                }
            }
            
            Spacer()
        }
    }
    
    // MARK: - Details Card
    private var detailsCard: some View {
        GlassCard(padding: 20) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Details")
                    .font(.headline)
                    .foregroundColor(themeService.currentTheme.text)
                
                Divider()
                
                switch event {
                case .session(let session, _):
                    sessionDetails(session: session)
                case .event(let event):
                    eventDetails(event: event)
                case .exam(let exam, _):
                    examDetails(exam: exam)
                case .breakSession(let breakSession):
                    breakDetails(breakSession: breakSession)
                }
            }
        }
        .animatedAppearance(delay: 0.2)
    }
    
    @ViewBuilder
    private func sessionDetails(session: StudySession) -> some View {
        InfoRow(icon: "clock.fill", title: "Duration", value: formatDuration(seconds: session.duration))
        InfoRow(icon: "calendar", title: "Date", value: formatDate(session.timestamp))
        InfoRow(icon: "clock", title: "Started At", value: formatTime(session.timestamp))
        if let completedAt = session.completedAt {
            InfoRow(icon: "checkmark.circle", title: "Completed At", value: formatTime(completedAt))
        }
    }
    
    @ViewBuilder
    private func eventDetails(event: Event) -> some View {
        InfoRow(icon: "calendar", title: "Date", value: formatDate(event.startTime))
        InfoRow(icon: "clock", title: "Time", value: "\(formatTime(event.startTime)) - \(formatTime(event.endTime))")
        InfoRow(icon: "hourglass", title: "Duration", value: formatDuration(from: event.startTime, to: event.endTime))
        
        if event.isAllDay {
            InfoRow(icon: "sun.max.fill", title: "All Day", value: "Yes")
        }
    }
    
    @ViewBuilder
    private func examDetails(exam: Exam) -> some View {
        InfoRow(icon: "calendar", title: "Date", value: formatDate(exam.examDate))
        InfoRow(icon: "clock", title: "Time", value: formatTime(exam.examDate))
        
        if let duration = exam.duration {
            let hours = duration / 60
            let minutes = duration % 60
            let durationText = hours > 0 && minutes > 0 ? "\(hours)h \(minutes)m" :
                               hours > 0 ? "\(hours)h" : "\(minutes)m"
            InfoRow(icon: "hourglass", title: "Duration", value: durationText)
        }
    }
    
    @ViewBuilder
    private func breakDetails(breakSession: BreakSession) -> some View {
        InfoRow(icon: "clock.fill", title: "Duration", value: formatDuration(seconds: breakSession.duration))
        InfoRow(icon: "calendar", title: "Date", value: formatDate(breakSession.timestamp))
        InfoRow(icon: "clock", title: "Time", value: formatTime(breakSession.timestamp))
    }
    
    // MARK: - Notes Card
    private var notesCard: some View {
        GlassCard(padding: 20) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "doc.text")
                        .foregroundColor(themeService.currentTheme.accent)
                        .font(.title3)
                    
                    Text("Notes")
                        .font(.headline)
                        .foregroundColor(themeService.currentTheme.text)
                }
                
                Divider()
                
                Text(notesText)
                    .font(.subheadline)
                    .foregroundColor(themeService.currentTheme.text)
                    .lineSpacing(4)
            }
        }
        .animatedAppearance(delay: 0.3)
    }
    
    private var notesText: String {
        switch event {
        case .event(let event): return event.notes
        case .exam(let exam, _): return exam.examDescription
        default: return ""
        }
    }
    
    // MARK: - Action Buttons
    private var actionButtons: some View {
        VStack(spacing: 12) {
            // Edit Button (only for Events and Exams)
            if canEdit {
                Button(action: {
                    showEditSheet = true
                    HapticManager.shared.selection()
                }) {
                    HStack {
                        Image(systemName: "pencil")
                            .font(.headline)
                        Text("Edit \(eventTypeName)")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(themeService.currentTheme.accent)
                            .shadow(color: themeService.currentTheme.accent.opacity(0.3), radius: 8, x: 0, y: 4)
                    )
                    .foregroundColor(.white)
                }
            }
            
            // Delete Button (for all types)
            Button(action: {
                showDeleteAlert = true
                HapticManager.shared.warning()
            }) {
                HStack {
                    Image(systemName: "trash")
                        .font(.headline)
                    Text("Delete \(eventTypeName)")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.red.opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.red, lineWidth: 1.5)
                        )
                )
                .foregroundColor(.red)
            }
        }
        .animatedAppearance(delay: 0.4)
    }
    
    // MARK: - Edit Sheet
    @ViewBuilder
    private var editSheet: some View {
        switch event {
        case .event(let event):
            EventEditSheet(event: event)
        case .exam(let exam, _):
            ExamFormSheet(exam: exam)
        default:
            EmptyView()
        }
    }
    
    // MARK: - Delete Action
    private func deleteItem() {
        switch event {
        case .session(let session, _):
            modelContext.delete(session)
            try? modelContext.save()
        case .event(let event):
            CalendarService.shared.deleteEvent(event, context: modelContext)
        case .exam(let exam, _):
            CalendarService.shared.deleteExam(exam, context: modelContext)
        case .breakSession(let breakSession):
            modelContext.delete(breakSession)
            try? modelContext.save()
        }
        
        HapticManager.shared.success()
        dismiss()
    }
    
    // MARK: - Helpers
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formatDuration(from start: Date, to end: Date) -> String {
        let duration = Int(end.timeIntervalSince(start))
        return formatDuration(seconds: duration)
    }
    
    private func formatDuration(seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        
        if hours > 0 && minutes > 0 {
            return "\(hours)h \(minutes)m"
        } else if hours > 0 {
            return "\(hours)h"
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - Info Row Component
private struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    @EnvironmentObject var themeService: ThemeService
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(themeService.currentTheme.accent)
                .frame(width: 24)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(themeService.currentTheme.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(themeService.currentTheme.text)
        }
    }
}

// MARK: - Event Edit Sheet (Wrapper for existing EventCreationSheet)
struct EventEditSheet: View {
    let event: Event
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var themeService: ThemeService
    
    @State private var title: String
    @State private var location: String
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var isAllDay: Bool
    @State private var notes: String
    @State private var selectedColor: Color
    
    let colorOptions: [Color] = [.blue, .red, .green, .orange, .purple, .pink, .cyan, .mint, .indigo, .yellow]
    
    init(event: Event) {
        self.event = event
        _title = State(initialValue: event.title)
        _location = State(initialValue: event.location)
        _startDate = State(initialValue: event.startTime)
        _endDate = State(initialValue: event.endTime)
        _isAllDay = State(initialValue: event.isAllDay)
        _notes = State(initialValue: event.notes)
        _selectedColor = State(initialValue: event.color)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Event Details") {
                    TextField("Title", text: $title)
                    TextField("Location", text: $location)
                }
                
                Section("Time") {
                    Toggle("All Day", isOn: $isAllDay)
                    
                    DatePicker("Start", selection: $startDate, displayedComponents: isAllDay ? [.date] : [.date, .hourAndMinute])
                    
                    if !isAllDay {
                        DatePicker("End", selection: $endDate, displayedComponents: [.date, .hourAndMinute])
                    }
                }
                
                Section("Color") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(colorOptions, id: \.self) { color in
                                Button(action: {
                                    selectedColor = color
                                    HapticManager.shared.selection()
                                }) {
                                    Circle()
                                        .fill(color)
                                        .frame(width: 36, height: 36)
                                        .overlay(
                                            Circle()
                                                .stroke(selectedColor == color ? Color.white : Color.clear, lineWidth: 2)
                                        )
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("Edit Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveEvent()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
    
    private func saveEvent() {
        event.title = title
        event.location = location
        event.startTime = startDate
        event.endTime = isAllDay ? Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: startDate) ?? startDate : endDate
        event.isAllDay = isAllDay
        event.notes = notes
        event.colorHex = selectedColor.toHex() ?? "#007AFF"
        
        try? modelContext.save()
        HapticManager.shared.success()
        dismiss()
    }
}

// MARK: - Preview
#Preview {
    let mockEvent = Event(title: "Team Meeting", location: "Conference Room A", startTime: Date(), endTime: Date().addingTimeInterval(3600))
    
    return EventDetailSheet(event: .event(mockEvent))
        .environmentObject(ThemeService.shared)
        .modelContainer(for: [Event.self, Exam.self, StudySession.self, BreakSession.self, Subject.self])
}
