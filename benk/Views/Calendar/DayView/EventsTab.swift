//
//  EventsTab.swift
//  benk
//
//  Created on 2025-12-15
//

import SwiftUI
import SwiftData

struct EventsTab: View {
    let selectedDate: Date
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var themeService: ThemeService
    
    @State private var showingEventCreation = false
    @State private var showingExamCreation = false
    @State private var showingAssignmentCreation = false
    
    var events: [Event] {
        CalendarService.shared.getEvents(for: selectedDate, context: modelContext)
    }
    
    var exams: [Exam] {
        CalendarService.shared.getExams(for: selectedDate, context: modelContext)
    }
    
    var assignments: [Assignment] {
        CalendarService.shared.getAssignments(for: selectedDate, context: modelContext)
    }
    
    var hasAnyItems: Bool {
        !events.isEmpty || !exams.isEmpty || !assignments.isEmpty
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Add button with menu
            Menu {
                Button(action: {
                    showingEventCreation = true
                }) {
                    Label("Event", systemImage: "calendar")
                }
                
                Button(action: {
                    showingExamCreation = true
                }) {
                    Label("Exam", systemImage: "doc.text")
                }
                
                Button(action: {
                    showingAssignmentCreation = true
                }) {
                    Label("Assignment", systemImage: "pencil")
                }
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                    Text("Add Item")
                        .fontWeight(.medium)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(themeService.currentTheme.primary)
                .cornerRadius(12)
            }
            
            if hasAnyItems {
                itemsList
            } else {
                emptyState
            }
        }
        .sheet(isPresented: $showingEventCreation) {
            EventCreationSheet()
        }
        .sheet(isPresented: $showingExamCreation) {
            ExamFormSheet()
        }
        .sheet(isPresented: $showingAssignmentCreation) {
            AssignmentCreationSheet()
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "calendar")
                .font(.system(size: 48))
                .foregroundColor(themeService.currentTheme.textSecondary.opacity(0.5))
            
            Text("No events today")
                .font(.headline)
                .foregroundColor(themeService.currentTheme.text)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
    
    private var itemsList: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Exams
            if !exams.isEmpty {
                Text("Exams")
                    .font(.headline)
                    .foregroundColor(themeService.currentTheme.text)
                    .padding(.leading, 4)
                
                ForEach(exams) { exam in
                    DayExamCard(exam: exam)
                }
            }
            
            // Assignments
            if !assignments.isEmpty {
                Text("Assignments")
                    .font(.headline)
                    .foregroundColor(themeService.currentTheme.text)
                    .padding(.leading, 4)
                    .padding(.top, exams.isEmpty ? 0 : 12)
                
                ForEach(assignments) { assignment in
                    AssignmentCard(assignment: assignment)
                }
            }
            
            // Events
            if !events.isEmpty {
                Text("Events")
                    .font(.headline)
                    .foregroundColor(themeService.currentTheme.text)
                    .padding(.leading, 4)
                    .padding(.top, (exams.isEmpty && assignments.isEmpty) ? 0 : 12)
                
                ForEach(events) { event in
                    EventCard(event: event)
                }
            }
        }
    }
}

// MARK: - Event Card
struct EventCard: View {
    let event: Event
    @EnvironmentObject var themeService: ThemeService
    
    var body: some View {
        HStack(spacing: 12) {
            Rectangle()
                .fill(event.color)
                .frame(width: 4)
                .cornerRadius(2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(themeService.currentTheme.text)
                
                Text(formatTimeRange(event.startTime, event.endTime))
                    .font(.caption)
                    .foregroundColor(themeService.currentTheme.textSecondary)
            }
            
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(themeService.currentTheme.textSecondary.opacity(0.05))
        )
    }
    
    private func formatTimeRange(_ start: Date, _ end: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
    }
}

// MARK: - Day Exam Card
struct DayExamCard: View {
    let exam: Exam
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var themeService: ThemeService
    @Query private var subjects: [Subject]
    
    var subject: Subject? {
        guard let subjectId = exam.subjectId else { return nil }
        return subjects.first { $0.id == subjectId }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Rectangle()
                .fill(subject?.color ?? themeService.currentTheme.primary)
                .frame(width: 4)
                .cornerRadius(2)
            
            VStack(alignment: .leading, spacing: 4) {
                // Paper name with subject tag, or just subject name
                if !exam.paperName.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "doc.text.fill")
                            .font(.caption)
                            .foregroundColor(subject?.color ?? themeService.currentTheme.primary)
                        
                        Text(exam.paperName)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(themeService.currentTheme.text)
                        
                        if let subject = subject {
                            Text(subject.name)
                                .font(.system(size: 10))
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(subject.color)
                                )
                        }
                    }
                } else {
                    HStack(spacing: 8) {
                        Image(systemName: "doc.text.fill")
                            .font(.caption)
                            .foregroundColor(subject?.color ?? themeService.currentTheme.primary)
                        
                        Text(subject?.name ?? "Exam")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(themeService.currentTheme.text)
                    }
                }
                
                Text(formatTime(exam.examDate))
                    .font(.caption)
                    .foregroundColor(themeService.currentTheme.textSecondary)
            }
            
            Spacer()
            
            // Countdown badge
            Text(exam.countdownText)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(exam.urgency.color)
                )
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill((subject?.color ?? themeService.currentTheme.primary).opacity(0.1))
        )
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}

// MARK: - Assignment Card
struct AssignmentCard: View {
    let assignment: Assignment
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var themeService: ThemeService
    @Query private var subjects: [Subject]
    
    var subject: Subject? {
        guard let subjectId = assignment.subjectId else { return nil }
        return subjects.first { $0.id == subjectId }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Rectangle()
                .fill(subject?.color ?? themeService.currentTheme.accent)
                .frame(width: 4)
                .cornerRadius(2)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Image(systemName: "pencil")
                        .font(.caption)
                        .foregroundColor(subject?.color ?? themeService.currentTheme.accent)
                    
                    Text(assignment.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(themeService.currentTheme.text)
                }
                
                HStack(spacing: 8) {
                    Text(subject?.name ?? "Assignment")
                        .font(.caption)
                        .foregroundColor(themeService.currentTheme.textSecondary)
                    
                    // Priority badge
                    Text(assignment.priority.displayName)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(assignment.priority.color)
                        )
                }
            }
            
            Spacer()
            
            // Status icon
            Image(systemName: assignment.status.icon)
                .foregroundColor(assignment.status == .completed ? .green : themeService.currentTheme.textSecondary)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill((subject?.color ?? themeService.currentTheme.accent).opacity(0.1))
        )
    }
}

#Preview {
    EventsTab(selectedDate: Date())
        .environmentObject(ThemeService.shared)
        .modelContainer(for: [Event.self, Exam.self, Assignment.self, Subject.self])
}
