//
//  CalendarService.swift
//  benk
//
//  Created on 2025-12-15
//

import Foundation
import SwiftData

@MainActor
class CalendarService {
    static let shared = CalendarService()
    
    private init() {}
    
    // MARK: - Event Operations
    
    func createEvent(_ event: Event, context: ModelContext) {
        context.insert(event)
        try? context.save()
    }
    
    func updateEvent(_ event: Event, context: ModelContext) {
        try? context.save()
    }
    
    func deleteEvent(_ event: Event, context: ModelContext) {
        context.delete(event)
        try? context.save()
    }
    
    func getEvents(for date: Date, context: ModelContext) -> [Event] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return [] }
        
        let descriptor = FetchDescriptor<Event>(
            predicate: #Predicate { event in
                event.startTime >= startOfDay && event.startTime < endOfDay
            },
            sortBy: [SortDescriptor(\.startTime)]
        )
        
        return (try? context.fetch(descriptor)) ?? []
    }
    
    func getEvents(from startDate: Date, to endDate: Date, context: ModelContext) -> [Event] {
        let descriptor = FetchDescriptor<Event>(
            predicate: #Predicate { event in
                event.startTime >= startDate && event.startTime <= endDate
            },
            sortBy: [SortDescriptor(\.startTime)]
        )
        
        return (try? context.fetch(descriptor)) ?? []
    }
    
    // MARK: - Exam Operations
    
    func createExam(_ exam: Exam, context: ModelContext) {
        context.insert(exam)
        try? context.save()
    }
    
    func updateExam(_ exam: Exam, context: ModelContext) {
        try? context.save()
    }
    
    func deleteExam(_ exam: Exam, context: ModelContext) {
        context.delete(exam)
        try? context.save()
    }
    
    func getExams(for date: Date, context: ModelContext) -> [Exam] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return [] }
        
        let descriptor = FetchDescriptor<Exam>(
            predicate: #Predicate { exam in
                exam.examDate >= startOfDay && exam.examDate < endOfDay
            },
            sortBy: [SortDescriptor(\.examDate)]
        )
        
        return (try? context.fetch(descriptor)) ?? []
    }
    
    func getUpcomingExams(limit: Int? = nil, context: ModelContext) -> [Exam] {
        let now = Date()
        
        let descriptor = FetchDescriptor<Exam>(
            predicate: #Predicate { exam in
                exam.examDate >= now
            },
            sortBy: [SortDescriptor(\.examDate)]
        )
        
        let exams = (try? context.fetch(descriptor)) ?? []
        if let limit = limit {
            return Array(exams.prefix(limit))
        }
        return exams
    }
    
    func getPastExams(context: ModelContext) -> [Exam] {
        let now = Date()
        
        let descriptor = FetchDescriptor<Exam>(
            predicate: #Predicate { exam in
                exam.examDate < now
            },
            sortBy: [SortDescriptor(\.examDate, order: .reverse)]
        )
        
        return (try? context.fetch(descriptor)) ?? []
    }
    
    func getExamsThisWeek(context: ModelContext) -> [Exam] {
        let calendar = Calendar.current
        let now = Date()
        guard let weekEnd = calendar.date(byAdding: .day, value: 7, to: now) else { return [] }
        
        let descriptor = FetchDescriptor<Exam>(
            predicate: #Predicate { exam in
                exam.examDate >= now && exam.examDate <= weekEnd
            },
            sortBy: [SortDescriptor(\.examDate)]
        )
        
        return (try? context.fetch(descriptor)) ?? []
    }
    
    func getAllExams(sortBy: ExamSortOption, filterBy: ExamFilterOption, context: ModelContext) -> [Exam] {
        // First, fetch all exams based on filter
        var exams: [Exam]
        
        switch filterBy {
        case .all:
            let descriptor = FetchDescriptor<Exam>(
                sortBy: [SortDescriptor(\.examDate)]
            )
            exams = (try? context.fetch(descriptor)) ?? []
            
        case .upcoming:
            exams = getUpcomingExams(context: context)
            
        case .thisWeek:
            exams = getExamsThisWeek(context: context)
            
        case .past:
            exams = getPastExams(context: context)
        }
        
        // Then apply sorting
        switch sortBy {
        case .soonest:
            exams.sort { $0.examDate < $1.examDate }
            
        case .subject:
            // Sort by subject name (nil subjects go to end)
            exams.sort { exam1, exam2 in
                guard let subjectId1 = exam1.subjectId else { return false }
                guard let subjectId2 = exam2.subjectId else { return true }
                
                // This is a simple comparison - in practice, you'd fetch subject names
                return subjectId1.uuidString < subjectId2.uuidString
            }
        }
        
        return exams
    }
    
    func getExams(from startDate: Date, to endDate: Date, context: ModelContext) -> [Exam] {
        let descriptor = FetchDescriptor<Exam>(
            predicate: #Predicate { exam in
                exam.examDate >= startDate && exam.examDate <= endDate
            },
            sortBy: [SortDescriptor(\.examDate)]
        )
        
        return (try? context.fetch(descriptor)) ?? []
    }
    
    // MARK: - Assignment Operations
    
    func createAssignment(_ assignment: Assignment, context: ModelContext) {
        context.insert(assignment)
        try? context.save()
    }
    
    func updateAssignment(_ assignment: Assignment, context: ModelContext) {
        try? context.save()
    }
    
    func deleteAssignment(_ assignment: Assignment, context: ModelContext) {
        context.delete(assignment)
        try? context.save()
    }
    
    func getAssignments(for date: Date, context: ModelContext) -> [Assignment] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return [] }
        
        let descriptor = FetchDescriptor<Assignment>(
            predicate: #Predicate { assignment in
                assignment.dueDate >= startOfDay && assignment.dueDate < endOfDay
            },
            sortBy: [SortDescriptor(\.dueDate)]
        )
        
        return (try? context.fetch(descriptor)) ?? []
    }
    
    func getUpcomingAssignments(limit: Int? = nil, context: ModelContext) -> [Assignment] {
        let now = Date()
        
        // Fetch all assignments with due date >= now
        let descriptor = FetchDescriptor<Assignment>(
            predicate: #Predicate { assignment in
                assignment.dueDate >= now
            },
            sortBy: [SortDescriptor(\.dueDate)]
        )
        
        let allAssignments = (try? context.fetch(descriptor)) ?? []
        
        // Filter out completed assignments and sort by urgency
        let filteredAssignments = allAssignments
            .filter { $0.status != .completed }
            .sorted { $0.urgency > $1.urgency }
        
        if let limit = limit {
            return Array(filteredAssignments.prefix(limit))
        }
        return filteredAssignments
    }
    
    func getAssignments(from startDate: Date, to endDate: Date, context: ModelContext) -> [Assignment] {
        let descriptor = FetchDescriptor<Assignment>(
            predicate: #Predicate { assignment in
                assignment.dueDate >= startDate && assignment.dueDate <= endDate
            },
            sortBy: [SortDescriptor(\.dueDate)]
        )
        
        return (try? context.fetch(descriptor)) ?? []
    }
    
    // MARK: - Study Session Queries (for progress rings)
    
    func getStudyMinutes(for date: Date, context: ModelContext) -> Int {
        let calendar = Calendar.current
        let dayStart = calendar.startOfDay(for: date)
        guard let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) else { return 0 }
        
        let descriptor = FetchDescriptor<StudySession>(
            predicate: #Predicate { session in
                session.isCompleted && session.timestamp >= dayStart && session.timestamp < dayEnd
            }
        )
        
        let sessions = (try? context.fetch(descriptor)) ?? []
        return sessions.reduce(0) { $0 + ($1.duration / 60) }
    }
    
    func getStudyMinutesBySubject(for date: Date, context: ModelContext) -> [UUID: Int] {
        let calendar = Calendar.current
        let dayStart = calendar.startOfDay(for: date)
        guard let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) else { return [:] }
        
        let descriptor = FetchDescriptor<StudySession>(
            predicate: #Predicate { session in
                session.isCompleted && session.timestamp >= dayStart && session.timestamp < dayEnd
            }
        )
        
        let sessions = (try? context.fetch(descriptor)) ?? []
        var subjectMinutes: [UUID: Int] = [:]
        
        for session in sessions {
            if let subjectId = session.subjectId {
                subjectMinutes[subjectId, default: 0] += session.duration / 60
            }
        }
        
        return subjectMinutes
    }
    
    // MARK: - Heat Map Calculations
    
    func calculateHeatMapIntensity(for date: Date, mode: HeatMapMode, dailyGoalMinutes: Int, context: ModelContext) -> Double {
        switch mode {
        case .productivity:
            return calculateProductivityIntensity(for: date, dailyGoalMinutes: dailyGoalMinutes, context: context)
        case .examLoad:
            return calculateExamLoadIntensity(for: date, context: context)
        case .assignmentLoad:
            return calculateAssignmentLoadIntensity(for: date, context: context)
        }
    }
    
    private func calculateProductivityIntensity(for date: Date, dailyGoalMinutes: Int, context: ModelContext) -> Double {
        let minutes = getStudyMinutes(for: date, context: context)
        let ratio = Double(minutes) / Double(max(1, dailyGoalMinutes))
        return min(1.0, ratio) // Cap at 1.0
    }
    
    private func calculateExamLoadIntensity(for date: Date, context: ModelContext) -> Double {
        let exams = getExams(for: date, context: context)
        // Scale: 0 exams = 0, 1 exam = 0.5, 2+ exams = 1.0
        let intensity = min(1.0, Double(exams.count) * 0.5)
        return intensity
    }
    
    private func calculateAssignmentLoadIntensity(for date: Date, context: ModelContext) -> Double {
        let assignments = getAssignments(for: date, context: context)
        // Scale based on priority and count
        let weightedLoad = assignments.reduce(0.0) { total, assignment in
            total + Double(assignment.priority.weight) / 10.0
        }
        return min(1.0, weightedLoad / 3.0) // Normalize to 0-1
    }
    
    // MARK: - Search
    
    func searchCalendar(query: String, filters: [CalendarFilter], context: ModelContext) -> [CalendarSearchResult] {
        var results: [CalendarSearchResult] = []
        let lowercasedQuery = query.lowercased()
        
        // Search events
        if filters.isEmpty || filters.contains(.events) {
            let eventDescriptor = FetchDescriptor<Event>()
            let events = (try? context.fetch(eventDescriptor)) ?? []
            let matchedEvents = events.filter { event in
                event.title.lowercased().contains(lowercasedQuery) ||
                event.location.lowercased().contains(lowercasedQuery) ||
                event.notes.lowercased().contains(lowercasedQuery)
            }
            results.append(contentsOf: matchedEvents.map { .event($0) })
        }
        
        // Search exams
        if filters.isEmpty || filters.contains(.exams) {
            let examDescriptor = FetchDescriptor<Exam>()
            let exams = (try? context.fetch(examDescriptor)) ?? []
            let matchedExams = exams.filter { exam in
                exam.examDescription.lowercased().contains(lowercasedQuery)
            }
            results.append(contentsOf: matchedExams.map { .exam($0) })
        }
        
        // Search assignments
        if filters.isEmpty || filters.contains(.assignments) {
            let assignmentDescriptor = FetchDescriptor<Assignment>()
            let assignments = (try? context.fetch(assignmentDescriptor)) ?? []
            let matchedAssignments = assignments.filter { assignment in
                assignment.title.lowercased().contains(lowercasedQuery) ||
                assignment.notes.lowercased().contains(lowercasedQuery)
            }
            results.append(contentsOf: matchedAssignments.map { .assignment($0) })
        }
        
        return results
    }
}

// MARK: - Heat Map Mode
enum HeatMapMode: String, CaseIterable {
    case productivity = "Productivity"
    case examLoad = "Exam Load"
    case assignmentLoad = "Assignment Load"
    
    var displayName: String {
        self.rawValue
    }
}

// MARK: - Calendar Filter
enum CalendarFilter: String, CaseIterable {
    case events = "Events"
    case exams = "Exams"
    case assignments = "Assignments"
    case studySessions = "Study Sessions"
    
    var displayName: String {
        self.rawValue
    }
}

// MARK: - Calendar Search Result
enum CalendarSearchResult: Identifiable {
    case event(Event)
    case exam(Exam)
    case assignment(Assignment)
    
    var id: UUID {
        switch self {
        case .event(let event):
            return event.id
        case .exam(let exam):
            return exam.id
        case .assignment(let assignment):
            return assignment.id
        }
    }
    
    var date: Date {
        switch self {
        case .event(let event):
            return event.startTime
        case .exam(let exam):
            return exam.examDate
        case .assignment(let assignment):
            return assignment.dueDate
        }
    }
    
    var title: String {
        switch self {
        case .event(let event):
            return event.title
        case .exam(_):
            return "Exam"
        case .assignment(let assignment):
            return assignment.title
        }
    }
}

// MARK: - Exam Sort Options
enum ExamSortOption: String, CaseIterable {
    case soonest = "Soonest"
    case subject = "Subject"
    
    var displayName: String {
        self.rawValue
    }
}

// MARK: - Exam Filter Options
enum ExamFilterOption: String, CaseIterable {
    case all = "All"
    case upcoming = "Upcoming"
    case thisWeek = "This Week"
    case past = "Past"
    
    var displayName: String {
        self.rawValue
    }
}
