//
//  BackupService.swift
//  benk
//
//  Created on 2025-12-16
//

import Foundation
import SwiftData
import SwiftUI

// MARK: - Dedicated Backup Structures

// MARK: - Dedicated Backup Structures

struct CalendarBackupData: Codable {
    let version: Int
    let exportDate: Date
    let events: [EventDTO]
    let exams: [ExamDTO]
    let subjects: [SubjectDTO] // Preserve subject associations
    let assignments: [AssignmentDTO] // Added assignments
}

// ... existing code ...

// MARK: - DTOs (Add AssignmentDTO)

struct AssignmentDTO: Codable {
    let id: UUID
    let subjectId: UUID?
    let title: String
    let dueDate: Date
    let estimatedEffortHours: Double
    let priorityRaw: String
    let statusRaw: String
    let notes: String
    
    init(from assignment: Assignment) {
        self.id = assignment.id
        self.subjectId = assignment.subjectId
        self.title = assignment.title
        self.dueDate = assignment.dueDate
        self.estimatedEffortHours = assignment.estimatedEffortHours
        self.priorityRaw = assignment.priority.rawValue
        self.statusRaw = assignment.status.rawValue
        self.notes = assignment.notes
    }
}

// ... existing DTOs ...



struct AnalyticsBackupData: Codable {
    let version: Int
    let exportDate: Date
    let userProfile: UserProfileDTO
    let tasks: [TaskDTO]
    let studySessions: [StudySessionDTO]
    let breakSessions: [BreakSessionDTO]
    let subjects: [SubjectDTO]
    let techniques: [TechniqueDTO]
    let badges: [BadgeDTO]
}

// MARK: - DTOs

struct UserProfileDTO: Codable {
    let username: String
    let xp: Int
    let level: Int
    let coins: Int
    let currentStreak: Int
    let longestStreak: Int
    let lastStudyDate: Date?
    let monthlyStudyGoalHours: Double
    let dailyGoalMinutes: Int
    let ownedThemeIds: [String]
    let currentThemeId: String
}

struct TaskDTO: Codable {
    let id: UUID
    let title: String
    let isCompleted: Bool
    let xpReward: Int
    let createdAt: Date
    let completedAt: Date?
    let subjectId: UUID?
}

struct StudySessionDTO: Codable {
    let id: UUID
    let duration: Int
    let xpEarned: Int
    let timestamp: Date
    let completedAt: Date?
    let subjectId: UUID?
    let techniqueId: UUID?
    let isCompleted: Bool
}

struct BreakSessionDTO: Codable {
    let id: UUID
    let duration: Int
    let timestamp: Date
    let tag: String
}

struct SubjectDTO: Codable {
    let id: UUID
    let name: String
    let colorHex: String
    let iconName: String
    let totalSeconds: Int
    let lastStudied: Date?
}

struct TechniqueDTO: Codable {
    let id: UUID
    let name: String
    let description: String
    let iconName: String
    let category: String
    let xpMultiplier: Double
    let subcategory: String?
    let effectivenessRating: Int
}

struct BadgeDTO: Codable {
    let id: UUID
    let name: String
    let titleName: String
    let badgeDescription: String
    let lore: String
    let iconName: String
    let categoryRaw: String
    let requirement: Int
    let progress: Int
    let isEarned: Bool
    let earnedDate: Date?
    let colorHex: String
    let sortOrder: Int
}

struct EventDTO: Codable {
    let id: UUID
    let title: String
    let location: String
    let startTime: Date
    let endTime: Date
    let isAllDay: Bool
    let repeatOptionRaw: String
    let alertsRaw: String
    let notes: String
    let colorHex: String
    let url: String
    let isMultiDay: Bool
    
    init(from event: Event) {
        self.id = event.id
        self.title = event.title
        self.location = event.location
        self.startTime = event.startTime
        self.endTime = event.endTime
        self.isAllDay = event.isAllDay
        self.repeatOptionRaw = event.repeatOption.rawValue
        self.alertsRaw = event.alertsRaw
        self.notes = event.notes
        self.colorHex = event.colorHex
        self.url = event.url
        self.isMultiDay = event.isMultiDay
    }
}

struct ExamDTO: Codable {
    let id: UUID
    let subjectId: UUID?
    let paperName: String
    let examDate: Date
    let duration: Int?
    let examDescription: String
    let alertsRaw: String
    
    init(from exam: Exam) {
        self.id = exam.id
        self.subjectId = exam.subjectId
        self.paperName = exam.paperName
        self.examDate = exam.examDate
        self.duration = exam.duration
        self.examDescription = exam.examDescription
        self.alertsRaw = exam.alertsRaw
    }
}


// MARK: - Backup Service

@MainActor
class BackupService: ObservableObject {
    static let shared = BackupService()
    
    private init() {}
    
    // MARK: - Calendar Backup (Events & Exams)
    
    // MARK: - Calendar Backup (Events & Exams)
    
    func createCalendarBackup(context: ModelContext) -> String? {
        do {
            let events = try context.fetch(FetchDescriptor<Event>())
            let eventDTOs = events.map { EventDTO(from: $0) }
            
            let exams = try context.fetch(FetchDescriptor<Exam>())
            let examDTOs = exams.map { ExamDTO(from: $0) }
            
            let assignments = try context.fetch(FetchDescriptor<Assignment>())
            let assignmentDTOs = assignments.map { AssignmentDTO(from: $0) }
            
            // Fetch subjects to ensure relationships are preserved
            let subjects = try context.fetch(FetchDescriptor<Subject>())
            let subjectDTOs = subjects.map { subject in
                SubjectDTO(
                    id: subject.id,
                    name: subject.name,
                    colorHex: subject.colorHex,
                    iconName: subject.iconName,
                    totalSeconds: subject.totalSeconds,
                    lastStudied: subject.lastStudied
                )
            }

            let backup = CalendarBackupData(
                version: 1,
                exportDate: Date(),
                events: eventDTOs,
                exams: examDTOs,
                subjects: subjectDTOs,
                assignments: assignmentDTOs
            )
            
            return try encode(backup)
        } catch {
            print("Failed to create calendar backup: \(error)")
            return nil
        }
    }
    
    func restoreCalendarBackup(jsonString: String, context: ModelContext) -> Result<String, Error> {
        guard let data = jsonString.data(using: .utf8) else {
            return .failure(NSError(domain: "BackupService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid data format"]))
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let backup = try decoder.decode(CalendarBackupData.self, from: data)
            
            // 1. Restore Subjects FIRST so relationships works
            for dto in backup.subjects {
                let id = dto.id
                var subjectToUpdate: Subject
                
                let descriptor = FetchDescriptor<Subject>(predicate: #Predicate<Subject> { $0.id == id })
                if let existing = (try? context.fetch(descriptor))?.first {
                    subjectToUpdate = existing
                } else {
                    subjectToUpdate = Subject(
                        id: dto.id,
                        name: dto.name,
                        colorHex: dto.colorHex,
                        iconName: dto.iconName
                    )
                    context.insert(subjectToUpdate)
                }
                
                // Update fields
                subjectToUpdate.name = dto.name
                subjectToUpdate.colorHex = dto.colorHex
                subjectToUpdate.iconName = dto.iconName
                subjectToUpdate.totalSeconds = dto.totalSeconds
                subjectToUpdate.lastStudied = dto.lastStudied
            }
            
            // 2. Restore Events (Merge/Update)
            for dto in backup.events {
                // Check if exists
                let id = dto.id
                var eventToUpdate: Event
                
                let descriptor = FetchDescriptor<Event>(predicate: #Predicate<Event> { $0.id == id })
                if let existing = (try? context.fetch(descriptor))?.first {
                    eventToUpdate = existing
                } else {
                    eventToUpdate = Event(
                        id: dto.id,
                        title: dto.title,
                        location: dto.location,
                        startTime: dto.startTime,
                        endTime: dto.endTime,
                        isAllDay: dto.isAllDay,
                        repeatOption: RepeatOption(rawValue: dto.repeatOptionRaw) ?? .none,
                        alerts: [],
                        notes: dto.notes,
                        colorHex: dto.colorHex,
                        url: dto.url,
                        isMultiDay: dto.isMultiDay
                    )
                    context.insert(eventToUpdate)
                }
                
                // Update fields
                eventToUpdate.title = dto.title
                eventToUpdate.location = dto.location
                eventToUpdate.startTime = dto.startTime
                eventToUpdate.endTime = dto.endTime
                eventToUpdate.isAllDay = dto.isAllDay
                eventToUpdate.repeatOption = RepeatOption(rawValue: dto.repeatOptionRaw) ?? .none
                eventToUpdate.alertsRaw = dto.alertsRaw
                eventToUpdate.notes = dto.notes
                eventToUpdate.colorHex = dto.colorHex
                eventToUpdate.url = dto.url
                eventToUpdate.isMultiDay = dto.isMultiDay
            }
            
            // 3. Restore Exams (Merge/Update)
            for dto in backup.exams {
                let id = dto.id
                var examToUpdate: Exam
                
                let descriptor = FetchDescriptor<Exam>(predicate: #Predicate<Exam> { $0.id == id })
                if let existing = (try? context.fetch(descriptor))?.first {
                    examToUpdate = existing
                } else {
                    examToUpdate = Exam(
                        id: dto.id,
                        subjectId: dto.subjectId,
                        paperName: dto.paperName,
                        examDate: dto.examDate,
                        duration: dto.duration,
                        examDescription: dto.examDescription,
                        alerts: []
                    )
                    context.insert(examToUpdate)
                }
                
                examToUpdate.subjectId = dto.subjectId
                examToUpdate.paperName = dto.paperName
                examToUpdate.examDate = dto.examDate
                examToUpdate.duration = dto.duration
                examToUpdate.examDescription = dto.examDescription
                examToUpdate.alertsRaw = dto.alertsRaw
            }
            
            // 4. Restore Assignments (Merge/Update)
            // Handle if backup has no assignments (backwards compatibility or optional)
            let assignments = backup.assignments
            for dto in assignments {
                let id = dto.id
                var assignmentToUpdate: Assignment
                
                let descriptor = FetchDescriptor<Assignment>(predicate: #Predicate<Assignment> { $0.id == id })
                if let existing = (try? context.fetch(descriptor))?.first {
                    assignmentToUpdate = existing
                } else {
                    assignmentToUpdate = Assignment(
                        id: dto.id,
                        subjectId: dto.subjectId,
                        title: dto.title,
                        dueDate: dto.dueDate,
                        estimatedEffortHours: dto.estimatedEffortHours,
                        priority: Priority(rawValue: dto.priorityRaw) ?? .medium,
                        status: AssignmentStatus(rawValue: dto.statusRaw) ?? .notStarted,
                        notes: dto.notes
                    )
                    context.insert(assignmentToUpdate)
                }
                
                assignmentToUpdate.subjectId = dto.subjectId
                assignmentToUpdate.title = dto.title
                assignmentToUpdate.dueDate = dto.dueDate
                assignmentToUpdate.estimatedEffortHours = dto.estimatedEffortHours
                assignmentToUpdate.priority = Priority(rawValue: dto.priorityRaw) ?? .medium
                assignmentToUpdate.status = AssignmentStatus(rawValue: dto.statusRaw) ?? .notStarted
                assignmentToUpdate.notes = dto.notes
            }
            
            try context.save()
            return .success("Calendar restored:\n• \(backup.events.count) events\n• \(backup.exams.count) exams\n• \(backup.assignments.count) assignments\n• \(backup.subjects.count) subjects")
            
        } catch let error as DecodingError {
            var errorMessage = "Decoding error: "
            switch error {
            case .typeMismatch(let type, let context):
                errorMessage += "Type mismatch for type \(type) at path \(context.codingPath). \(context.debugDescription)"
            case .valueNotFound(let type, let context):
                errorMessage += "Value not found for type \(type) at path \(context.codingPath). \(context.debugDescription)"
            case .keyNotFound(let key, let context):
                errorMessage += "Key '\(key.stringValue)' not found at path \(context.codingPath). \(context.debugDescription)"
            case .dataCorrupted(let context):
                errorMessage += "Data corrupted at path \(context.codingPath). \(context.debugDescription)"
            @unknown default:
                errorMessage += error.localizedDescription
            }
            return .failure(NSError(domain: "BackupService", code: 1, userInfo: [NSLocalizedDescriptionKey: errorMessage]))
        } catch {
            return .failure(error)
        }
    }
    
    // MARK: - Analytics Backup (Stats, Sessions, Profile)
    
    func createAnalyticsBackup(context: ModelContext) -> String? {
        do {
            // Profile
            let profileDescriptor = FetchDescriptor<UserProfile>()
            let profile = (try context.fetch(profileDescriptor)).first ?? UserProfile()
            
            let userProfileDTO = UserProfileDTO(
                username: profile.username,
                xp: profile.xp,
                level: profile.level,
                coins: CurrencyManager.shared.coins, // Use single source of truth
                currentStreak: profile.currentStreak,
                longestStreak: profile.longestStreak,
                lastStudyDate: profile.lastStudyDate,
                monthlyStudyGoalHours: profile.monthlyStudyGoalHours,
                dailyGoalMinutes: profile.dailyGoalMinutes,
                ownedThemeIds: profile.ownedThemeIds,
                currentThemeId: profile.currentThemeId
            )
            
            // Tasks
            let tasks = try context.fetch(FetchDescriptor<Task>())
            let taskDTOs = tasks.map { task in
                TaskDTO(
                    id: task.id,
                    title: task.title,
                    isCompleted: task.isCompleted,
                    xpReward: task.xpReward,
                    createdAt: task.createdAt,
                    completedAt: task.completedAt,
                    subjectId: task.subjectId
                )
            }
            
            // Sessions
            let sessions = try context.fetch(FetchDescriptor<StudySession>())
            let sessionDTOs = sessions.map { session in
                StudySessionDTO(
                    id: session.id,
                    duration: session.duration,
                    xpEarned: session.xpEarned,
                    timestamp: session.timestamp,
                    completedAt: session.completedAt,
                    subjectId: session.subjectId,
                    techniqueId: session.techniqueId,
                    isCompleted: session.isCompleted
                )
            }
            
            // Breaks
            let breaks = try context.fetch(FetchDescriptor<BreakSession>())
            let breakDTOs = breaks.map { breakSession in
                BreakSessionDTO(
                    id: breakSession.id,
                    duration: breakSession.duration,
                    timestamp: breakSession.timestamp,
                    tag: breakSession.tag
                )
            }
            
            // Subjects
            let subjects = try context.fetch(FetchDescriptor<Subject>())
            let subjectDTOs = subjects.map { subject in
                SubjectDTO(
                    id: subject.id,
                    name: subject.name,
                    colorHex: subject.colorHex,
                    iconName: subject.iconName,
                    totalSeconds: subject.totalSeconds,
                    lastStudied: subject.lastStudied
                )
            }
            
            // Techniques
            let techniques = try context.fetch(FetchDescriptor<Technique>())
            let techniqueDTOs = techniques.map { tech in
                TechniqueDTO(
                    id: tech.id,
                    name: tech.name,
                    description: tech.techniqueDescription,
                    iconName: tech.iconName,
                    category: tech.category,
                    xpMultiplier: tech.xpMultiplier,
                    subcategory: tech.subcategory,
                    effectivenessRating: tech.effectivenessRating
                )
            }
            
            // Badges
            let badges = try context.fetch(FetchDescriptor<Badge>())
            let badgeDTOs = badges.map { badge in
                BadgeDTO(
                    id: badge.id,
                    name: badge.name,
                    titleName: badge.titleName,
                    badgeDescription: badge.badgeDescription,
                    lore: badge.lore,
                    iconName: badge.iconName,
                    categoryRaw: badge.category,
                    requirement: badge.requirement,
                    progress: badge.progress,
                    isEarned: badge.isEarned,
                    earnedDate: badge.earnedDate,
                    colorHex: badge.colorHex,
                    sortOrder: badge.sortOrder
                )
            }
            
            let backup = AnalyticsBackupData(
                version: 1,
                exportDate: Date(),
                userProfile: userProfileDTO,
                tasks: taskDTOs,
                studySessions: sessionDTOs,
                breakSessions: breakDTOs,
                subjects: subjectDTOs,
                techniques: techniqueDTOs,
                badges: badgeDTOs
            )
            
            return try encode(backup)
            
        } catch {
            print("Failed to create analytics backup: \(error)")
            return nil
        }
    }
    
    func restoreAnalyticsBackup(jsonString: String, context: ModelContext) -> Result<String, Error> {
        guard let data = jsonString.data(using: .utf8) else {
            return .failure(NSError(domain: "BackupService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid data format"]))
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let backup = try decoder.decode(AnalyticsBackupData.self, from: data)
            
            // For analytics/full restore involving profile, we wipe the related data first to avoid duplications/conflicts
            // But we do NOT wipe Calendar data (Events/Exams) here, as requested by separation.
            
            // 1. Wipe Analytics Data
            try context.delete(model: Task.self)
            try context.delete(model: StudySession.self)
            try context.delete(model: BreakSession.self)
            try context.delete(model: Subject.self)
            try context.delete(model: Technique.self)
            try context.delete(model: Badge.self)
            
            // 2. Restore Profile
            let profileDescriptor = FetchDescriptor<UserProfile>()
            if let profile = (try? context.fetch(profileDescriptor))?.first {
                updateProfile(profile, with: backup.userProfile)
            } else {
                // Should exist, but handle safety
                let profile = UserProfile()
                context.insert(profile)
                updateProfile(profile, with: backup.userProfile)
            }
            
            // 3. Restore Related Data
            
            // Subjects
            for dto in backup.subjects {
                let subject = Subject(
                    id: dto.id,
                    name: dto.name,
                    colorHex: dto.colorHex,
                    iconName: dto.iconName
                )
                subject.totalSeconds = dto.totalSeconds
                subject.lastStudied = dto.lastStudied
                context.insert(subject)
            }
            
            // Techniques
            for dto in backup.techniques {
                let tech = Technique(
                    id: dto.id,
                    name: dto.name,
                    techniqueDescription: dto.description,
                    iconName: dto.iconName,
                    xpMultiplier: dto.xpMultiplier,
                    category: dto.category,
                    subcategory: dto.subcategory,
                    effectivenessRating: dto.effectivenessRating
                )
                context.insert(tech)
            }
            
            // Tasks
            for dto in backup.tasks {
                let task = Task(
                    id: dto.id,
                    title: dto.title,
                    isCompleted: dto.isCompleted,
                    xpReward: dto.xpReward,
                    createdAt: dto.createdAt,
                    completedAt: dto.completedAt,
                    subjectId: dto.subjectId
                )
                context.insert(task)
            }
            
            // Sessions
            for dto in backup.studySessions {
                let session = StudySession(
                    id: dto.id,
                    duration: dto.duration,
                    xpEarned: dto.xpEarned,
                    timestamp: dto.timestamp,
                    completedAt: dto.completedAt,
                    subjectId: dto.subjectId,
                    techniqueId: dto.techniqueId,
                    isCompleted: dto.isCompleted
                )
                context.insert(session)
            }
            
            // Break Sessions
            for dto in backup.breakSessions {
                let session = BreakSession(
                    id: dto.id,
                    duration: dto.duration,
                    timestamp: dto.timestamp,
                    tag: dto.tag
                )
                context.insert(session)
            }
            
            // Badges
            for dto in backup.badges {
                let badge = Badge(
                    id: dto.id,
                    name: dto.name,
                    titleName: dto.titleName,
                    badgeDescription: dto.badgeDescription,
                    lore: dto.lore,
                    iconName: dto.iconName,
                    category: BadgeCategory(rawValue: dto.categoryRaw) ?? .special,
                    requirement: dto.requirement,
                    sortOrder: dto.sortOrder,
                    colorHex: dto.colorHex
                )
                badge.progress = dto.progress
                badge.isEarned = dto.isEarned
                badge.earnedDate = dto.earnedDate
                context.insert(badge)
            }
            
            try context.save()
            return .success("Analytics restored:\n• \(backup.studySessions.count) sessions\n• \(backup.breakSessions.count) breaks\n• \(backup.tasks.count) tasks")
            
        } catch let error as DecodingError {
             var errorMessage = "Decoding error: "
             switch error {
             case .typeMismatch(let type, let context):
                 errorMessage += "Type mismatch for type \(type) at path \(context.codingPath). \(context.debugDescription)"
             case .valueNotFound(let type, let context):
                 errorMessage += "Value not found for type \(type) at path \(context.codingPath). \(context.debugDescription)"
             case .keyNotFound(let key, let context):
                 errorMessage += "Key '\(key.stringValue)' not found at path \(context.codingPath). \(context.debugDescription)"
             case .dataCorrupted(let context):
                 errorMessage += "Data corrupted at path \(context.codingPath). \(context.debugDescription)"
             @unknown default:
                 errorMessage += error.localizedDescription
             }
             return .failure(NSError(domain: "BackupService", code: 1, userInfo: [NSLocalizedDescriptionKey: errorMessage]))
        } catch {
            return .failure(error)
        }
    }
    
    // MARK: - Helpers
    
    private func encode<T: Encodable>(_ value: T) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        
        let data = try encoder.encode(value)
        return String(data: data, encoding: .utf8) ?? ""
    }
    
    private func updateProfile(_ profile: UserProfile, with dto: UserProfileDTO) {
        profile.username = dto.username
        profile.xp = dto.xp
        profile.level = dto.level
        // profile.coins is legacy, update the Source of Truth
        CurrencyManager.shared.coins = dto.coins
        profile.currentStreak = dto.currentStreak
        profile.longestStreak = dto.longestStreak
        profile.lastStudyDate = dto.lastStudyDate
        profile.monthlyStudyGoalHours = dto.monthlyStudyGoalHours
        profile.dailyGoalMinutes = dto.dailyGoalMinutes
        profile.ownedThemeIds = dto.ownedThemeIds
        profile.currentThemeId = dto.currentThemeId
    }
}
