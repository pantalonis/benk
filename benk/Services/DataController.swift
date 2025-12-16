//
//  DataController.swift
//  benk
//
//  Created on 2025-12-11
//

import Foundation
import SwiftData

@MainActor
class DataController {
    static let shared = DataController()
    
    private init() {}
    
    /// Initialize default subjects
    func initializeDefaultSubjects(context: ModelContext) {
        let defaultSubjects = [
            ("Mathematics", "#FF6B6B", "function"),
            ("Science", "#4ECDC4", "flask"),
            ("History", "#FFE66D", "book"),
            ("Language", "#A8E6CF", "character.book.closed"),
            ("Computer Science", "#95E1D3", "desktopcomputer"),
            ("Art", "#F38181", "paintbrush"),
            ("Music", "#AA96DA", "music.note"),
            ("Physical Education", "#FCBAD3", "figure.run")
        ]
        
        for (name, color, icon) in defaultSubjects {
            let subject = Subject(name: name, colorHex: color, iconName: icon)
            context.insert(subject)
        }
        
        try? context.save()
    }
    
    /// Initialize default study techniques
    /// Note: This is now handled by StudyTechniqueDatabase.seedTechniques()
    /// which provides 137 techniques across 12 categories
    @available(*, deprecated, message: "Use StudyTechniqueDatabase.seedTechniques() instead")
    func initializeDefaultTechniques(context: ModelContext) {
        // Deprecated - techniques are now seeded automatically via StudyTechniqueDatabase
        StudyTechniqueDatabase.seedTechniques(context: context)
    }
    
    /// Initialize default badges
    func initializeDefaultBadges(context: ModelContext) {
        // First, check if badges already exist to avoid duplicates
        let descriptor = FetchDescriptor<Badge>()
        let existingBadges = (try? context.fetch(descriptor)) ?? []
        if !existingBadges.isEmpty {
            return
        }
        
        // MARK: - Streak Badges (warm flame progression: ember → blaze → inferno)
        // Format: (name, titleName, description, icon, lore, requirement, sortOrder, colorHex)
        let streakBadges: [(String, String, String, String, String, Int, Int, String)] = [
            ("Rookie", "Rookie", "3 day streak", "flame.fill",
             "Every great scholar started somewhere. You've taken your first steps on the path of consistency. The ancient masters would say: 'A journey of a thousand miles begins with a single step.' You've taken three.",
             3, 1, "#CD7F32"),  // Bronze
            ("Getting Serious", "Dedicated", "10 day streak", "flame.fill",
             "The flames of dedication burn brighter. Those who reach ten days have proven their resolve. In the halls of benk, you are no longer a novice—you are becoming a true seeker of knowledge.",
             10, 2, "#E85D04"),  // Burnt Orange
            ("Locked In", "Locked In", "50 day streak", "flame.fill",
             "Fifty days of unbroken study! The ancient Order of the Focused Mind would welcome you as an initiate. Your dedication has forged an unbreakable chain of progress.",
             50, 3, "#DC2F02"),  // Crimson
            ("Triple Threat", "Centurion", "100 day streak", "flame.fill",
             "A century of consecutive learning! Legends speak of scholars who reached this milestone and gained the ability to learn twice as fast. Whether true or not, your discipline is legendary.",
             100, 4, "#C0C0C0"),  // Silver
            ("No Days Off", "Eternal", "365 day streak", "flame.fill",
             "One full year without missing a day. The Grand Masters of the Eternal Library bow in respect. You have achieved what few dare to dream—perfect dedication for an entire revolution around the sun.",
             365, 5, "#D4AF37"),  // Classic Gold
            ("Immortal", "Immortal", "1000 day streak", "flame.fill",
             "A THOUSAND DAYS! Your name is inscribed in the mythical Scroll of Infinite Dedication. The gods of knowledge themselves pause their eternal debates to acknowledge your achievement. You are no longer merely a student—you are a legend.",
             1000, 6, "#B9F2FF"),  // Diamond/Platinum
        ]
        
        // MARK: - Daily Goal Badges (target progression: bronze → silver → gold)
        let dailyGoalBadges: [(String, String, String, String, String, Int, Int, String)] = [
            ("One Hit Wonder", "Marksman", "Hit daily goal once", "target",
             "You aimed, you fired, you hit! The first bullseye is always special. The target remains waiting for your return.",
             1, 1, "#CD7F32"),  // Bronze
            ("Loyalty III", "Loyal", "Hit goal for 7 days", "scope",
             "Seven days of hitting your mark! The target has begun to recognize you. Some say it secretly hopes you'll miss, just to feel challenged again.",
             7, 2, "#71797E"),  // Steel Gray
            ("Bullseye", "Bullseye", "Hit goal for 30 days", "dot.scope",
             "Thirty perfect shots. The target has given up all hope of escaping your precision. In the archery halls of knowledge, your accuracy is spoken of in whispers.",
             30, 3, "#C0C0C0"),  // Silver
            ("Sharpshooter", "Sharpshooter", "Hit goal for 100 days", "scope",
             "One hundred days of perfect aim! The Grand Tournament of Goals crowns you champion. No target is safe from your relentless pursuit of excellence.",
             100, 4, "#D4AF37"),  // Classic Gold
        ]
        
        // MARK: - Technique Badges (knowledge theme: earth tones to royal)
        let techniqueBadges: [(String, String, String, String, String, Int, Int, String)] = [
            ("Method Actor", "Versatile", "Use 3 techniques in one day", "theatermasks.fill",
             "Three different approaches in a single day! You've discovered that variety is the spice of learning. The Academy of Adaptive Studies applauds your flexibility.",
             3, 1, "#8B4513"),  // Saddle Brown
            ("Technique Explorer", "Explorer", "Discover 10 techniques", "safari.fill",
             "Ten different methods explored! You're mapping the vast landscape of learning strategies. Each technique is a new tool in your ever-expanding arsenal.",
             10, 2, "#2E8B57"),  // Sea Green
            ("Strategy Collector", "Strategist", "Discover 25 techniques", "square.stack.3d.up.fill",
             "Twenty-five techniques mastered! Your collection rivals the great methodologists of history. The Library of Infinite Methods grants you a reading pass.",
             25, 3, "#4169E1"),  // Royal Blue
            ("Grand Methodologist", "Sage", "Discover 50 techniques", "brain.head.profile",
             "FIFTY TECHNIQUES! You've become a walking encyclopedia of study methods. Students seek your wisdom, teachers ask for your advice. You are the Grand Methodologist.",
             50, 4, "#6B3FA0"),  // Royal Purple
            ("Technique Titan", "Titan", "Discover 100 techniques", "crown.fill",
             "One hundred techniques in your repertoire! The Council of Learning Methods unanimously elects you as their eternal chairperson. No challenge can defeat such versatility.",
             100, 5, "#D4AF37"),  // Classic Gold
        ]
        
        // MARK: - Time Spent Badges (time theme: dawn to dusk progression)
        let timeSpentBadges: [(String, String, String, String, String, Int, Int, String)] = [
            ("First Hour", "Initiate", "Study for 1 hour total", "clock",
             "Your first hour of dedicated study! Time well spent is knowledge well earned. The clock nods approvingly at your commitment.",
             60, 1, "#6495ED"),  // Cornflower Blue
            ("Ten Hours In", "Scholar", "Study for 10 hours total", "clock.fill",
             "Ten hours invested in your future! The Hourglass of Wisdom begins to tip in your favor. Each grain of sand represents a moment of growth.",
             600, 2, "#4682B4"),  // Steel Blue
            ("Day Scholar", "Daywalker", "Study for 24 hours total", "sun.max.fill",
             "A full day's worth of learning! If time is money, you've made a wise investment. The Sundial of Knowledge marks this achievement with pride.",
             1440, 3, "#DAA520"),  // Goldenrod
            ("Week Warrior", "Warrior", "Study for 168 hours total", "calendar",
             "One hundred sixty-eight hours—a whole week of pure study time! The Calendar of Champions adds your name to its hallowed pages.",
             10080, 4, "#C0C0C0"),  // Silver
            ("Time Lord", "Time Lord", "Study for 500 hours total", "hourglass",
             "FIVE HUNDRED HOURS! You've bent time itself to your will. The ancient chronologists whisper that those who reach this milestone gain fleeting glimpses of academic enlightenment.",
             30000, 5, "#D4AF37"),  // Classic Gold
        ]
        
        // MARK: - Task Completion Badges (productivity: green → professional metals)
        let taskBadges: [(String, String, String, String, String, Int, Int, String)] = [
            ("Task Starter", "Tasker", "Complete 10 tasks", "checkmark.circle",
             "Ten tasks conquered! Every checkmark is a small victory. Your to-do list trembles at your efficiency.",
             10, 1, "#228B22"),  // Forest Green
            ("Task Champion", "Champion", "Complete 50 tasks", "checkmark.circle.fill",
             "Fifty tasks vanquished! Your productivity has become the stuff of legend. Other tasks warn their children about you.",
             50, 2, "#2F4F4F"),  // Dark Slate Gray
            ("Task Terminator", "Terminator", "Complete 100 tasks", "checkmark.seal.fill",
             "ONE HUNDRED TASKS ELIMINATED! The Task Board of Fame immortalizes your relentless productivity. Procrastination weeps in a corner.",
             100, 3, "#C0C0C0"),  // Silver
            ("Task Legend", "Legend", "Complete 500 tasks", "star.circle.fill",
             "Five hundred tasks! You've become an unstoppable force of completion. Productivity gurus study your methods. You ARE the method.",
             500, 4, "#D4AF37"),  // Classic Gold
        ]
        
        // MARK: - Special/Fun Badges (thematic colors matching each badge's meaning)
        let specialBadges: [(String, String, String, String, String, Int, Int, String)] = [
            ("Gremlin", "Gremlin", "Log after midnight", "moon.stars.fill",
             "You've studied past the witching hour! The Night Owls Guild welcomes you with tired but approving eyes. Just remember: with great late-night power comes great morning drowsiness.",
             1, 1, "#191970"),  // Midnight Blue
            ("Early Bird", "Early Bird", "Log before 6 AM", "sunrise.fill",
             "Studying before the sun rises! While others dream, you learn. The Dawn Scholars Society tips their coffee cups to you.",
             1, 2, "#FF8C00"),  // Dark Orange (sunrise)
            ("Weekend Warrior", "Grinder", "Study on both Sat and Sun", "calendar.badge.clock",
             "No weekend breaks for you! While others rest, you press on. The Eternal Grind acknowledges your sacrifice.",
             2, 3, "#8B0000"),  // Dark Red
            ("Marathon Runner", "Marathon", "Study 4+ hours in one session", "figure.run",
             "Four hours of continuous focus! Your concentration is legendary. Lesser minds would have surrendered, but you emerged victorious from the mental marathon.",
             1, 4, "#2E8B57"),  // Sea Green
            ("Perfect Week", "Perfectionist", "Complete all goals for 7 days", "star.fill",
             "Seven days of perfection! Not a single goal missed, not a single day wasted. The Hall of Flawless Achievement opens its doors to you.",
             7, 5, "#D4AF37"),  // Classic Gold
            ("Night Owl", "Night Owl", "Complete 10 sessions after 10 PM", "moon.zzz.fill",
             "Ten late-night study sessions! You've mastered the art of nocturnal learning. The moon itself becomes your study lamp.",
             10, 6, "#483D8B"),  // Dark Slate Blue
            ("Subject Hopper", "Renaissance", "Study 5 subjects in one day", "arrow.triangle.swap",
             "Five subjects in a single day! Your versatility knows no bounds. The Renaissance Scholars would count you among their ranks.",
             5, 7, "#008B8B"),  // Dark Cyan
            ("Comeback Kid", "Phoenix", "Resume after 7+ day break", "arrow.counterclockwise",
             "You fell, but you rose again! Seven days of darkness, then a return to the light. The Phoenix of Learning is reborn in you.",
             1, 8, "#B22222"),  // Firebrick (phoenix)
            ("Holiday Hero", "Santa", "Study 6.7 hours on Christmas", "gift.fill",
             "On the day of celebration, you chose dedication! While others unwrapped presents, you unwrapped knowledge. Santa has added you to the Nice List... permanently.",
             402, 9, "#DC143C"),  // Crimson Red
        ]
        
        // Create all badges
        for (name, titleName, desc, icon, lore, req, order, color) in streakBadges {
            let badge = Badge(name: name, titleName: titleName, badgeDescription: desc, lore: lore, iconName: icon, category: .streak, requirement: req, sortOrder: order, colorHex: color)
            context.insert(badge)
        }
        
        for (name, titleName, desc, icon, lore, req, order, color) in dailyGoalBadges {
            let badge = Badge(name: name, titleName: titleName, badgeDescription: desc, lore: lore, iconName: icon, category: .dailyGoal, requirement: req, sortOrder: order, colorHex: color)
            context.insert(badge)
        }
        
        for (name, titleName, desc, icon, lore, req, order, color) in techniqueBadges {
            let badge = Badge(name: name, titleName: titleName, badgeDescription: desc, lore: lore, iconName: icon, category: .technique, requirement: req, sortOrder: order, colorHex: color)
            context.insert(badge)
        }
        
        for (name, titleName, desc, icon, lore, req, order, color) in timeSpentBadges {
            let badge = Badge(name: name, titleName: titleName, badgeDescription: desc, lore: lore, iconName: icon, category: .timeSpent, requirement: req, sortOrder: order, colorHex: color)
            context.insert(badge)
        }
        
        for (name, titleName, desc, icon, lore, req, order, color) in taskBadges {
            let badge = Badge(name: name, titleName: titleName, badgeDescription: desc, lore: lore, iconName: icon, category: .taskCompletion, requirement: req, sortOrder: order, colorHex: color)
            context.insert(badge)
        }
        
        for (name, titleName, desc, icon, lore, req, order, color) in specialBadges {
            let badge = Badge(name: name, titleName: titleName, badgeDescription: desc, lore: lore, iconName: icon, category: .special, requirement: req, sortOrder: order, colorHex: color)
            context.insert(badge)
        }
        
        try? context.save()
    }
    
    /// Reset all app data
    func resetAppData(context: ModelContext) {
        // Reset UserProfile
        let descriptor = FetchDescriptor<UserProfile>()
        if let profiles = try? context.fetch(descriptor), let profile = profiles.first {
            profile.xp = 0
            profile.level = 1
            CurrencyManager.shared.coins = 0 // Reset coins to 0 (no starter amount)
            profile.currentStreak = 0
            profile.longestStreak = 0
            profile.lastStudyDate = nil
            profile.ownedThemeIds = ["light", "dark"]
            profile.currentThemeId = "dark"
        }
        
        // Delete all Tasks
        try? context.delete(model: Task.self)
        
        // Delete all Sessions
        try? context.delete(model: StudySession.self)
        
        // Delete all Break Sessions
        try? context.delete(model: BreakSession.self)

        // Delete all Calendar Items
        try? context.delete(model: Event.self)
        try? context.delete(model: Exam.self)
        try? context.delete(model: Assignment.self)
        
        // Delete all Custom Rewards
        try? context.delete(model: CustomReward.self)
        
        // Reset Subjects (Delete and Re-init)
        try? context.delete(model: Subject.self)
        
        // Reset Badges - delete and recreate
        try? context.delete(model: Badge.self)
        
        // Reset Quests by deleting them (they will be regenerated)
        try? context.delete(model: Quest.self)
        
        try? context.save()
        
        // Reset Inventory (items and window backgrounds)
        InventoryManager.shared.ownedItems = []
        InventoryManager.shared.ownedWindowBackgrounds = []
        
        // Reset Room (placed objects, theme, window)
        RoomManager.shared.placedObjects = []
        RoomManager.shared.currentRoomTheme = nil
        RoomManager.shared.currentWindowBackground = nil
        RoomManager.shared.windowPosition = CGPoint(x: 0.5, y: 0.25)
        
        // Clear SaveManager saved game data
        SaveManager.shared.resetGameData()
        
        // Regenerate defaults
        initializeDefaultSubjects(context: context)
        initializeDefaultBadges(context: context)
        
        // Reset quest stats and refresh quests
        QuestStats.shared.resetAllStats()
        QuestService.shared.checkRefresh()
    }
    
    /// Seed sample study sessions for testing charts and calendar
    func seedFakeStudyData(context: ModelContext) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Ensure a profile exists
        let profileDescriptor = FetchDescriptor<UserProfile>()
        let profile: UserProfile
        if let existing = try? context.fetch(profileDescriptor), let first = existing.first {
            profile = first
        } else {
            let newProfile = UserProfile()
            context.insert(newProfile)
            profile = newProfile
        }
        
        // Get available subjects
        let subjectDescriptor = FetchDescriptor<Subject>()
        let subjects = (try? context.fetch(subjectDescriptor)) ?? []
        
        // Create some repeatable sample sessions over the past week (including today)
        let sampleMinutes = [35, 50, 75, 90, 45, 60, 120]
        let sampleHours = [9, 13, 18, 15, 20]
        
        for dayOffset in 0..<7 {
            guard let dayStart = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
            
            // 2-3 sessions per day
            let sessionsCount = dayOffset % 2 == 0 ? 3 : 2
            
            for sessionIndex in 0..<sessionsCount {
                let minutes = sampleMinutes[(dayOffset + sessionIndex) % sampleMinutes.count]
                let seconds = minutes * 60
                let hour = sampleHours[sessionIndex % sampleHours.count]
                
                let start = calendar.date(bySettingHour: hour, minute: 15, second: 0, of: dayStart) ?? dayStart
                let end = calendar.date(byAdding: .second, value: seconds, to: start) ?? start
                
                let xp = XPService.shared.calculateXP(seconds: seconds, technique: nil)
                
                // Assign to a subject (rotate through available subjects)
                let subjectId = subjects.isEmpty ? nil : subjects[(dayOffset + sessionIndex) % subjects.count].id
                
                let session = StudySession(
                    duration: seconds,
                    xpEarned: xp,
                    timestamp: start,
                    completedAt: end,
                    subjectId: subjectId,
                    isCompleted: true
                )
                
                context.insert(session)
                _ = XPService.shared.awardXP(xp, to: profile, context: context)
            }
        }
        
        profile.lastStudyDate = today
        profile.currentStreak = max(profile.currentStreak, 7)
        profile.longestStreak = max(profile.longestStreak, profile.currentStreak)
        
        try? context.save()
    }
    
    /// Seed calendar mock data (events, exams, assignments)
    func seedCalendarMockData(context: ModelContext) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Get available subjects
        let subjectDescriptor = FetchDescriptor<Subject>()
        let subjects = (try? context.fetch(subjectDescriptor)) ?? []
        
        guard !subjects.isEmpty else {
            print("No subjects available. Please add subjects first.")
            return
        }
        
        // Create sample events
        let eventTitles = ["Team Study Session", "Library Visit", "Online Lecture", "Lab Work", "Group Project Meeting"]
        let locations = ["Library", "Room 204", "Online - Zoom", "Science Lab", "Student Center"]
        
        for dayOffset in 1...15 {
            guard let eventDate = calendar.date(byAdding: .day, value: dayOffset, to: today) else { continue }
            
            if dayOffset % 3 == 0 {
                let titleIndex = dayOffset % eventTitles.count
                let event = Event(
                    title: eventTitles[titleIndex],
                    location: locations[titleIndex],
                    startTime: calendar.date(bySettingHour: 14, minute: 0, second: 0, of: eventDate) ?? eventDate,
                    endTime: calendar.date(bySettingHour: 16, minute: 0, second: 0, of: eventDate) ?? eventDate,
                    notes: "Mock event for testing",
                    colorHex: ["#FF6B6B", "#4ECDC4", "#95E1D3", "#FFE66D"][dayOffset % 4]
                )
                context.insert(event)
            }
        }
        
        // Create multi-day event (study plan)
        if let startDate = calendar.date(byAdding: .day, value: 7, to: today),
           let endDate = calendar.date(byAdding: .day, value: 10, to: today) {
            let multiDayEvent = Event(
                title: "Final Exam Study Week",
                location: "Various",
                startTime: calendar.date(bySettingHour: 9, minute: 0, second: 0, of: startDate) ?? startDate,
                endTime: calendar.date(bySettingHour: 17, minute: 0, second: 0, of: endDate) ?? endDate,
                isAllDay: true,
                notes: "Intensive study period for finals",
                colorHex: "#FF6B6B",
                isMultiDay: true
            )
            context.insert(multiDayEvent)
        }
        
        // Create sample exams
        let examDays = [3, 7, 12, 18, 25]
        for (index, dayOffset) in examDays.enumerated() {
            guard let examDate = calendar.date(byAdding: .day, value: dayOffset, to: today) else { continue }
            let subject = subjects[index % subjects.count]
            
            let exam = Exam(
                subjectId: subject.id,
                examDate: calendar.date(bySettingHour: 10, minute: 0, second: 0, of: examDate) ?? examDate,
                duration: [60, 90, 120, 90, 60][index % 5],
                examDescription: "Chapter \(index + 1)-\(index + 3) coverage",
                alerts: [1440, 60] // 1 day and 1 hour before
            )
            context.insert(exam)
        }
        
        // Create sample assignments
        let assignmentTitles = [
            "Research Paper Draft",
            "Lab Report",
            "Problem Set 5",
            "Reading Analysis",
            "Group Presentation",
            "Essay Final Draft",
            "Programming Project",
            "Case Study Analysis"
        ]
        let priorities: [Priority] = [.high, .medium, .low, .high, .medium, .high, .medium, .low]
        let statuses: [AssignmentStatus] = [.notStarted, .inProgress, .notStarted, .inProgress, .notStarted, .inProgress, .notStarted, .notStarted]
        
        for (index, title) in assignmentTitles.enumerated() {
            let dayOffset = index * 4 + 2
            guard let dueDate = calendar.date(byAdding: .day, value: dayOffset, to: today) else { continue }
            let subject = subjects[index % subjects.count]
            
            let assignment = Assignment(
                subjectId: subject.id,
                title: title,
                dueDate: calendar.date(bySettingHour: 23, minute: 59, second: 0, of: dueDate) ?? dueDate,
                estimatedEffortHours: Double([2, 3, 4, 5, 3, 6, 8, 4][index]),
                priority: priorities[index],
                status: statuses[index],
                notes: "Mock assignment for testing calendar features"
            )
            context.insert(assignment)
        }
        
        try? context.save()
        print("Calendar mock data generated successfully!")
    }
}
