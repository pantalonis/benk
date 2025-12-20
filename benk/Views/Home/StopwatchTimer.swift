//
//  StopwatchTimer.swift
//  benk
//
//  Created on 2025-12-12
//

import SwiftUI
import SwiftData

struct StopwatchTimer: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var themeService: ThemeService
    @EnvironmentObject var timerService: TimerService
    @EnvironmentObject var badgeService: BadgeService
    
    @Query private var userProfiles: [UserProfile]
    @Query private var subjects: [Subject]
    @Query private var tasks: [Task]
    
    @AppStorage("selectedSubjectId") private var selectedSubjectId: String = ""
    @State private var showSubjectPicker = false
    @State private var showTechniquePicker = false
    @State private var showingBreakTagSelection = false
    @State private var pendingSession: (duration: Int, xp: Int)? = nil
    
    // Helper for break time string
    var breakTimeString: String {
        let minutes = timerService.breakDuration / 60
        let seconds = timerService.breakDuration % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var userProfile: UserProfile {
        userProfiles.first ?? UserProfile()
    }
    
    var selectedSubject: Subject? {
        subjects.first { $0.id.uuidString == selectedSubjectId }
    }
    
    var body: some View {
        GlassCard {
            VStack(spacing: 16) {
                // Header
                HStack {
                    Image(systemName: "stopwatch.fill")
                        .foregroundColor(themeService.currentTheme.accent)
                        .font(.title3)
                    
                    Text("Study Timer")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(themeService.currentTheme.text)
                    
                    Spacer()
                }
                
                // Timer Display
                VStack(spacing: 4) {
                    if timerService.isPaused && timerService.isBreakActive {
                        Text("ON BREAK")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(themeService.currentTheme.accent)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(themeService.currentTheme.accent.opacity(0.2))
                            .clipShape(Capsule())
                    }
                    
                    Text(timerService.isPaused && timerService.isBreakActive ? breakTimeString : timerService.stopwatchTimeString)
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    themeService.currentTheme.primary,
                                    themeService.currentTheme.accent
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
                .padding(.vertical, 8)
                
                // Subject Selection
                if !timerService.isRunning {
                    Button(action: {
                        showSubjectPicker = true
                        HapticManager.shared.selection()
                    }) {
                        HStack {
                            Image(systemName: selectedSubject?.iconName ?? "book.fill")
                                .foregroundColor(themeService.currentTheme.accent)
                            
                            Text(selectedSubject?.name ?? "Select Subject")
                                .foregroundColor(themeService.currentTheme.text)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.down")
                                .foregroundColor(themeService.currentTheme.textSecondary)
                                .font(.caption)
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(themeService.currentTheme.surface.opacity(0.3))
                        )
                    }
                } else {
                    // Show selected subject while running
                    HStack {
                        Image(systemName: selectedSubject?.iconName ?? "book.fill")
                            .foregroundColor(themeService.currentTheme.accent)
                        
                        Text(selectedSubject?.name ?? "No Subject")
                            .foregroundColor(themeService.currentTheme.text)
                        
                        Spacer()
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(themeService.currentTheme.surface.opacity(0.3))
                    )
                }
                
                // Control Buttons
                HStack(spacing: 12) {
                    if !timerService.isRunning {
                        // Start Button
                        Button(action: {
                            startStopwatch()
                        }) {
                            HStack {
                                Image(systemName: "play.fill")
                                Text("Start")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                themeService.currentTheme.primary,
                                                themeService.currentTheme.accent
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            )
                            .shadow(color: themeService.currentTheme.glow.opacity(0.4), radius: 10, x: 0, y: 5)
                        }
                    } else {
                        // Pause/Resume Button
                        Button(action: {
                            if timerService.isPaused {
                                // Resuming from break - show tag selection
                                showingBreakTagSelection = true
                            } else {
                                // Pausing - log current study session first
                                logCurrentStudySession()
                                timerService.pause()
                                startBreakTimer()
                            }
                            HapticManager.shared.medium()
                        }) {
                            HStack {
                                Image(systemName: timerService.isPaused ? "play.fill" : "pause.fill")
                                Text(timerService.isPaused ? "Resume" : "Pause")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(themeService.currentTheme.primary)
                            )
                        }
                        
                        // Stop Button
                        Button(action: {
                            prepareToCompleteSession()
                        }) {
                            HStack {
                                Image(systemName: "stop.fill")
                                Text("Stop")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(themeService.currentTheme.accent)
                            )
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showSubjectPicker) {
            SubjectPickerSheet(selectedSubjectId: $selectedSubjectId)
        }
        .sheet(isPresented: $showTechniquePicker) {
            TechniquePickerSheet { technique in
                savePendingSession(technique: technique)
            }
            .interactiveDismissDisabled(true)
        }
        .sheet(isPresented: $showingBreakTagSelection) {
            BreakTagPickerSheet(breakDuration: timerService.breakDuration) { tag in
                let duration = timerService.stopBreak()
                if duration > 0 {
                    saveBreak(tag: tag, duration: duration)
                    try? modelContext.save()
                }
                timerService.resume()
                showingBreakTagSelection = false
            }
        }
    }
    
    // MARK: - Session Logging
    private func logCurrentStudySession() {
        // Use segment time (time since last resume), not total elapsed time
        let duration = timerService.segmentElapsedTime
        
        // Only log if there's meaningful study time
        guard duration > 0, let subject = selectedSubject else { return }
        
        // Calculate XP (base rate, will apply technique multiplier at final stop)
        let xp = XPService.shared.calculateXP(seconds: duration, technique: nil)
        
        // Create study session with current elapsed time
        let session = StudySession(
            duration: duration,
            xpEarned: xp,
            completedAt: Date(),
            subjectId: subject.id,
            techniqueId: nil, // Will be set at final stop
            isCompleted: true
        )
        
        // Calculate session start time (duration seconds ago)
        if let sessionStartTime = Calendar.current.date(byAdding: .second, value: -duration, to: Date()) {
            session.timestamp = sessionStartTime
        }
        
        modelContext.insert(session)
        
        // Save immediately so it appears on calendar
        try? modelContext.save()
        
        // Award XP incrementally
        _ = XPService.shared.awardXP(xp, to: userProfile, context: modelContext)
        
        // Update subject
        subject.totalSeconds += duration
        subject.lastStudied = Date()
        
        // Save again
        try? modelContext.save()
        
        // NOTE: Don't reset elapsed time - keep displaying cumulative time
        // Each pause logs a segment, but timer continues showing total time
    }
    
    // MARK: - Break Timer
    private func startBreakTimer() {
        timerService.startBreak()
    }
    
    private func stopBreakTimerAndLog() {
        let duration = timerService.stopBreak()
        
        // Automatically log every break to calendar (even very short ones)
        if duration > 0 {
            // Create and save break session
            let breakSession = BreakSession(
                duration: duration,
                tag: "Break" // Default tag
            )
            
            // Set timestamp to when break started (duration seconds ago)
            if let breakStartTime = Calendar.current.date(byAdding: .second, value: -duration, to: Date()) {
                breakSession.timestamp = breakStartTime
            }
            
            modelContext.insert(breakSession)
            
            // Track break for quest progress
            QuestStats.shared.recordBreakTaken()
            QuestService.shared.updateAllProgress()
            
            // Save immediately so it appears on calendar
            try? modelContext.save()
        }
        
        timerService.resume()
    }
    
    private func saveBreak(tag: String, duration: Int) {
        let breakSession = BreakSession(
            duration: duration,
            tag: tag
        )
        
        // Calculate break start time (duration seconds ago)
        if let breakStartTime = Calendar.current.date(byAdding: .second, value: -duration, to: Date()) {
            breakSession.timestamp = breakStartTime
        }
        
        modelContext.insert(breakSession)
        
        // Track break for quest progress
        QuestStats.shared.recordBreakTaken()
        QuestService.shared.updateAllProgress()
    }
    
    private func startStopwatch() {
        if selectedSubject == nil {
            // Auto-select first subject if none selected
            if let firstSubject = subjects.first {
                selectedSubjectId = firstSubject.id.uuidString
            }
            return
        }
        
        timerService.startStopwatch()
        HapticManager.shared.success()
    }
    
    private func prepareToCompleteSession() {
        let duration = timerService.elapsedTime
        
        // Only save if duration > 0
        guard duration > 0 else {
            timerService.stop()
            return
        }
        
        let xp = XPService.shared.calculateXP(
            seconds: duration,
            technique: nil // Base XP, will multiply by technique later
        )
        
        // Store pending session data
        pendingSession = (duration: duration, xp: xp)
        
        // Stop the timer
        timerService.stop()
        
        // Show technique picker
        showTechniquePicker = true
        
        HapticManager.shared.medium()
    }
    
    private func savePendingSession(technique: Technique?) {
        guard let pending = pendingSession else { return }
        
        // Calculate final XP with technique multiplier
        let finalXP = technique != nil 
            ? Int(Double(pending.xp) * (technique!.xpMultiplier))
            : pending.xp
        
        let session = StudySession(
            duration: pending.duration,
            xpEarned: finalXP,
            completedAt: Date(),
            subjectId: selectedSubject?.id,
            techniqueId: technique?.id,
            isCompleted: true
        )
        
        // Calculate session start time (duration seconds ago)
        if let sessionStartTime = Calendar.current.date(byAdding: .second, value: -pending.duration, to: Date()) {
            session.timestamp = sessionStartTime
        }
        
        modelContext.insert(session)
        
        // Award XP
        _ = XPService.shared.awardXP(finalXP, to: userProfile, context: modelContext)
        
        // Update streak
        StreakService.shared.updateStreak(for: userProfile, context: modelContext)
        
        // Update subject
        if let subject = selectedSubject {
            subject.totalSeconds += pending.duration
            subject.lastStudied = Date()
        }
        
        // Save context before badge checking
        try? modelContext.save()
        
        // Track study session for quests
        QuestStats.shared.recordStudySession(durationSeconds: pending.duration, subjectId: selectedSubject?.id)
        QuestService.shared.updateAllProgress()
        
        // Check badges after session completion
        checkBadgesAfterSession(sessionDuration: pending.duration, sessionTime: Date(), technique: technique)
        
        // Clear pending session
        pendingSession = nil
        
        HapticManager.shared.success()
    }
    
    // MARK: - Badge Checking
    private func checkBadgesAfterSession(sessionDuration: Int, sessionTime: Date, technique: Technique?) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let dailyGoalMinutes = userProfile.dailyGoalMinutes
        
        // Fetch sessions directly from database
        let sessionDescriptor = FetchDescriptor<StudySession>(predicate: #Predicate { $0.isCompleted })
        let dbSessions = (try? modelContext.fetch(sessionDescriptor)) ?? []
        
        // Build complete session list including current session
        var allSessions: [(duration: Int, techniqueId: UUID?, subjectId: UUID?, timestamp: Date)] = dbSessions.map {
            (duration: $0.duration, techniqueId: $0.techniqueId, subjectId: $0.subjectId, timestamp: $0.timestamp)
        }
        allSessions.append((duration: sessionDuration, techniqueId: technique?.id, subjectId: selectedSubject?.id, timestamp: sessionTime))
        
        // Calculate total study time in minutes
        let totalMinutes = allSessions.reduce(0) { $0 + ($1.duration / 60) }
        
        // Calculate completed tasks
        let completedTasksCount = tasks.filter { $0.isCompleted }.count
        
        // Calculate unique techniques used (all time)
        let uniqueTechniquesCount = Set(allSessions.compactMap { $0.techniqueId }).count
        
        // Calculate techniques used TODAY (including current session)
        let todaySessions = allSessions.filter { calendar.isDate($0.timestamp, inSameDayAs: today) }
        let techniquesUsedToday = Set(todaySessions.compactMap { $0.techniqueId }).count
        
        // Calculate subjects studied TODAY
        let subjectsStudiedToday = Set(todaySessions.compactMap { $0.subjectId }).count
        
        // Calculate days where daily goal was met
        var daysGoalMet = 0
        var todayGoalMet = false
        let sessionsByDay = Dictionary(grouping: allSessions) { session in
            calendar.startOfDay(for: session.timestamp)
        }
        for (day, daySessions) in sessionsByDay {
            let dayMinutes = daySessions.reduce(0) { $0 + ($1.duration / 60) }
            if dayMinutes >= dailyGoalMinutes {
                daysGoalMet += 1
                if calendar.isDateInToday(day) {
                    todayGoalMet = true
                }
            }
        }
        
        // Call BadgeService to check all badges
        badgeService.checkAllBadgesAfterSession(
            context: modelContext,
            userProfile: userProfile,
            sessionDuration: sessionDuration,
            sessionTime: sessionTime,
            totalStudyMinutes: totalMinutes,
            completedTasksCount: completedTasksCount,
            uniqueTechniquesUsed: uniqueTechniquesCount,
            techniquesUsedToday: techniquesUsedToday,
            subjectsStudiedToday: subjectsStudiedToday,
            daysGoalMet: daysGoalMet
        )
        
        // Direct badge awards for specific achievements
        if todayGoalMet {
            badgeService.awardBadgeByName("One Hit Wonder", context: modelContext)
        }
        if techniquesUsedToday >= 3 {
            badgeService.awardBadgeByName("Method Actor", context: modelContext)
        }
        
        // Force check any badges that might have progress >= requirement but aren't earned
        badgeService.forceCheckAllBadges(context: modelContext)
    }
}

// MARK: - Break Tag Selection Sheet
struct BreakTagSelectionSheet: View {
    let onSelect: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeService: ThemeService
    
    let breakTags = ["Break", "Lunch", "Coffee", "Exercise", "Rest", "Personal"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                Text("What type of break?")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(themeService.currentTheme.text)
                    .padding()
                
                // Tag Grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(breakTags, id: \.self) { tag in
                        Button(action: {
                            HapticManager.shared.selection()
                            onSelect(tag)
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: iconForTag(tag))
                                    .font(.system(size: 18))
                                
                                Text(tag)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                
                                Spacer()
                            }
                            .foregroundColor(themeService.currentTheme.text)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(themeService.currentTheme.surface)
                            )
                        }
                    }
                }
                .padding()
                
                Spacer()
            }
            .background(themeService.currentTheme.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        // Just skip tagging and resume
                        onSelect("Break")
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func iconForTag(_ tag: String) -> String {
        switch tag {
        case "Lunch": return "fork.knife"
        case "Coffee": return "cup.and.saucer.fill"
        case "Exercise": return "figure.run"
        case "Rest": return "bed.double.fill"
        case "Personal": return "person.fill"
        default: return "pause.circle.fill"
        }
    }
}


#Preview {
    StopwatchTimer()
        .padding()
        .modelContainer(for: [UserProfile.self, Subject.self, Task.self, StudySession.self])
        .environmentObject(ThemeService.shared)
        .environmentObject(TimerService.shared)
        .environmentObject(BadgeService.shared)
        .background(Color.black)
}
