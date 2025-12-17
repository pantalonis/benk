//
//  SettingsView.swift
//  benk
//
//  Created on 2025-12-11.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct ShareableFile: Identifiable {
    let id = UUID()
    let url: URL
}

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var themeService: ThemeService
    @EnvironmentObject var badgeService: BadgeService
    
    @Query private var userProfiles: [UserProfile]
    @Query private var sessions: [StudySession]
    @Query private var badges: [Badge]
    @Query private var tasks: [Task]
    @Query private var techniques: [Technique]
    @Query private var subjects: [Subject]
    
    @State private var notificationsEnabled = true
    @State private var soundEnabled = true
    @State private var showResetConfirmation = false
    @State private var showDataExport = false
    @State private var exportedData = ""
    
    @State private var calendarExportItem: ShareableFile?
    @State private var showCalendarImport = false
    @State private var showImportAlert = false
    @State private var importAlertMessage = ""
    
    var userProfile: UserProfile {
        userProfiles.first ?? UserProfile()
    }
    
    var body: some View {
        ZStack {
            ThemedBackground(theme: themeService.currentTheme)
            
            VStack(spacing: 0) {
                // Custom Header
                HStack {
                    // Back Button (Settings can be pushed or presented, check if we need back button. Assuming it's a tab or pushed, usually tabs don't have back, but if user asked to remove "back" button in Settings, it means it was pushed? Or maybe they mean the title?
                    // User said "default back < back button in ... settings". This implies it is being pushed from somewhere.
                    // If it's a root tab, it wouldn't have a back button.
                    // If it's accessed from "Profile" -> "Settings" then it needs a back button.
                    // Let's add a back button.
                    Button(action: { 
                        // If it's in a NavigationStack, we might need to dismiss or pop.
                        // But wait, if it's a tab, there is no back.
                        // However, user EXPLICITLY complained about "< back" button in settings.
                        // I will assume standard dismiss/pop behavior.
                        dismiss() // Assuming wrapping in a sheet or pushed view.
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.title2.weight(.semibold))
                            .foregroundColor(themeService.currentTheme.text)
                            .frame(width: 44, height: 44)
                            .background(themeService.currentTheme.surface.opacity(0.5))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text("Settings")
                        .font(.headline)
                        .foregroundColor(themeService.currentTheme.text)
                    
                    Spacer()
                    
                    // Placeholder
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal)
                .padding(.top, 8)

                Form {
                    profileSection
                    appearanceSection
                    preferencesSection
                    calendarBackupSection
                    debugSection
                    aboutSection
                    dataManagementSection
                }
                .scrollContentBackground(.hidden)
            }
            .alert("Reset Data?", isPresented: $showResetConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    DataController.shared.resetAppData(context: modelContext)
                    HapticManager.shared.success()
                }
            } message: {
                Text("This will permanently delete all your progress, tasks, and coins. This action cannot be undone.")
            }
            .alert("Import Result", isPresented: $showImportAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(importAlertMessage)
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            recalculateDailyGoal()
        }
        .sheet(item: $calendarExportItem) { item in
            calendarExportSheet(for: item.url)
        }
        .fileImporter(
            isPresented: $showCalendarImport,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            handleFileImport(result)
        }
    }
    
    // Add dismiss environment variable if not present
    @Environment(\.dismiss) private var dismiss
    
    private var profileSection: some View {
        Section("Profile & Goals") {
            TextField("Username", text: Binding(
                get: { userProfile.username },
                set: { userProfile.username = $0 }
            ))
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Monthly Goal (Hours)")
                    .font(.caption)
                    .foregroundColor(.gray)
                TextField("Hours", value: Binding(
                    get: { userProfile.monthlyStudyGoalHours },
                    set: { newValue in
                        userProfile.monthlyStudyGoalHours = newValue
                        recalculateDailyGoal()
                    }
                ), format: .number)
                .keyboardType(.decimalPad)
            }
            
            if userProfile.monthlyStudyGoalHours > 0 {
                HStack {
                    Text("Daily Goal Needed")
                    Spacer()
                    Text("\(userProfile.dailyGoalMinutes) min")
                        .fontWeight(.bold)
                        .foregroundColor(themeService.currentTheme.accent)
                }
                Text("Based on remaining days in the month")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
    }
    
    private var appearanceSection: some View {
        Section("Appearance") {
            ForEach(themeService.allThemes, id: \.id) { theme in
                Button(action: {
                    if themeService.isThemeOwned(theme.id, profile: userProfile) {
                        themeService.applyTheme(theme)
                        HapticManager.shared.selection()
                    }
                }) {
                    HStack {
                        Circle()
                            .fill(theme.accent)
                            .frame(width: 24, height: 24)
                        
                        Text(theme.name)
                            .foregroundColor(themeService.currentTheme.text)
                        
                        Spacer()
                        
                        if !themeService.isThemeOwned(theme.id, profile: userProfile) {
                            HStack {
                                Text("\(theme.price)")
                                Image(systemName: "lock.fill")
                            }
                            .font(.caption)
                            .foregroundColor(themeService.currentTheme.textSecondary)
                        } else if themeService.currentTheme.id == theme.id {
                            Image(systemName: "checkmark")
                                .foregroundColor(themeService.currentTheme.accent)
                        }
                    }
                }
            }
        }
    }
    
    private var preferencesSection: some View {
        Section("Preferences") {
            Toggle("Notifications", isOn: $notificationsEnabled)
            Toggle("Sound Effects", isOn: $soundEnabled)
            
            if userProfile.monthlyStudyGoalHours == 0 {
                Stepper("Daily Goal: \(userProfile.dailyGoalMinutes) min", value: Binding(
                    get: { userProfile.dailyGoalMinutes },
                    set: { newValue in
                        userProfile.dailyGoalMinutes = newValue
                        try? modelContext.save()
                    }
                ), in: 15...180, step: 15)
            } else {
                HStack {
                    Text("Daily Goal")
                    Spacer()
                    Text("\(userProfile.dailyGoalMinutes) min")
                        .foregroundColor(.gray)
                }
                .brightness(-0.2) // Indicate disabled
            }
        }
    }

    private var calendarBackupSection: some View {
        Section("Calendar Backup") {
            Button(action: {
                // 1. Generate JSON
                if let json = BackupService.shared.createCalendarBackup(context: modelContext) {
                    print("Generated JSON size: \(json.count) bytes")
                    
                    if json.isEmpty {
                        importAlertMessage = "Export failed: Generated data was empty."
                        showImportAlert = true
                        return
                    }
                    
                    // 2. Save to file immediately
                    if let url = saveToTempFile(data: json) {
                        print("Saved to file: \(url.path)")
                        // Verify file size
                        if let attr = try? FileManager.default.attributesOfItem(atPath: url.path),
                           let fileSize = attr[.size] as? UInt64 {
                            print("Verified file size on disk: \(fileSize) bytes")
                        }
                        
                        calendarExportItem = ShareableFile(url: url)
                        HapticManager.shared.success()
                    } else {
                        importAlertMessage = "Failed to save backup file locally."
                        showImportAlert = true
                    }
                } else {
                    importAlertMessage = "Failed to generate backup data."
                    showImportAlert = true
                }
            }) {
                Label("Export Events & Exams", systemImage: "square.and.arrow.up")
            }
            .foregroundColor(.blue)
            
            Button(action: {
                showCalendarImport = true
            }) {
                Label("Import Backup File", systemImage: "square.and.arrow.down")
            }
            .foregroundColor(.blue)
            
            Text("Back up your events and exams to a file. Restore them anytime if you reinstall the app.")
                .font(.caption)
                .foregroundColor(.gray)
        }
    }


    private var aboutSection: some View {
        Section("About") {
            NavigationLink(destination: GameSystemsInfoView()) {
                Label("How It Works", systemImage: "info.circle.fill")
            }
            
            HStack {
                Text("Version")
                Spacer()
                Text("1.0.0")
                    .foregroundColor(themeService.currentTheme.textSecondary)
            }
        }
    }
    
    private var debugSection: some View {
        Section("Debug") {
            Button("Add 10000 Coins 💰") {
                CurrencyManager.shared.addCoins(10000, source: "Debug Bonus")
                HapticManager.shared.success()
            }
            .foregroundColor(.yellow)
            
            Button("Add 200 XP") {
                _ = XPService.shared.awardXP(200, to: userProfile, context: modelContext)
                HapticManager.shared.success()
            }
            .foregroundColor(.blue)
            
            Button("Generate Fake Study Data") {
                DataController.shared.seedFakeStudyData(context: modelContext)
                HapticManager.shared.success()
            }
            .foregroundColor(.orange)
            
            Button("Test Badge Unlock Popup") {
                if let badge = badges.first(where: { !$0.isEarned }) {
                    badge.progress = badge.requirement
                    badge.isEarned = true
                    badge.earnedDate = Date()
                    try? modelContext.save()
                    
                    badgeService.newlyEarnedBadge = badge
                    badgeService.showBadgeEarnedPopup = true
                    HapticManager.shared.success()
                }
            }
            .foregroundColor(.purple)
            
            Button("Unlock All Badges (Test) - \(badges.count) badges") {
                unlockAllBadgesWithData()
            }
            .foregroundColor(.green)
            
            Button("Reinitialize All Badges (Reset Colors)") {
                badgeService.resetTracking()
                do {
                    try modelContext.delete(model: Badge.self)
                    try modelContext.save()
                } catch {
                    print("Failed to delete badges: \(error)")
                }
                DataController.shared.initializeDefaultBadges(context: modelContext)
                badgeService.checkAllBadgesOnLoad(context: modelContext, force: true)
                HapticManager.shared.success()
            }
            .foregroundColor(.orange)
            
            Button("Reset All Badges") {
                badgeService.resetTracking()
                for badge in badges {
                    badge.progress = 0
                    badge.isEarned = false
                    badge.earnedDate = nil
                }
                do {
                    try modelContext.save()
                    HapticManager.shared.success()
                } catch {
                    print("Failed to reset badges: \(error)")
                }
                badgeService.checkAllBadgesOnLoad(context: modelContext, force: true)
            }
            .foregroundColor(.red)
            
            Button("Export User Data (CSV)") {
                exportUserDataAsCSV()
                showDataExport = true
            }
            .foregroundColor(.blue)
            
            Button("Generate Calendar Mock Data") {
                DataController.shared.seedCalendarMockData(context: modelContext)
                HapticManager.shared.success()
            }
            .foregroundColor(.cyan)
        }
        .sheet(isPresented: $showDataExport) {
            dataExportSheet
        }
    }
    



    // MARK: - Calendar Export Sheet
    // MARK: - Calendar Export Sheet
    private func calendarExportSheet(for url: URL) -> some View {
        NavigationStack {
            VStack {
                Text("Your calendar backup is ready.")
                    .padding()
                
                ShareLink(item: url, preview: SharePreview("benk Calendar Backup", image: Image(systemName: "calendar"))) {
                    Label("Save Backup File", systemImage: "square.and.arrow.up")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                
                Spacer()
            }
            .navigationTitle("Export Calendar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { calendarExportItem = nil }
                }
            }
        }
        .presentationDetents([.medium])
    }
    
    private func saveToTempFile(data: String) -> URL? {
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "benk_Backup_\(Date().formatted(date: .numeric, time: .omitted).replacingOccurrences(of: "/", with: "-")).json"
        let fileUrl = tempDir.appendingPathComponent(fileName)
        
        do {
            try data.write(to: fileUrl, atomically: true, encoding: .utf8)
            return fileUrl
        } catch {
            print("Error saving temp file: \(error)")
            return nil
        }
    }
    
    private func handleFileImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            
            // Start accessing security scoped resource
            guard url.startAccessingSecurityScopedResource() else {
                importAlertMessage = "Permission denied to access the file."
                showImportAlert = true
                return
            }
            
            defer { url.stopAccessingSecurityScopedResource() }
            
            do {
                let data = try String(contentsOf: url, encoding: .utf8)
                print("Importing data size: \(data.count) bytes")
                
                let result = BackupService.shared.restoreCalendarBackup(jsonString: data, context: modelContext)
                
                switch result {
                case .success(let message):
                    importAlertMessage = message
                    HapticManager.shared.success()
                case .failure(let error):
                    // Add debug info about what was read
                    let preview = String(data.prefix(100)).replacingOccurrences(of: "\n", with: " ")
                    importAlertMessage = "Import failed: \(error.localizedDescription)\n\nFile size: \(data.count) bytes\nPreview: \(preview)"
                    HapticManager.shared.error()
                }
            } catch {
                importAlertMessage = "Failed to read file: \(error.localizedDescription)"
                HapticManager.shared.error()
            }
            showImportAlert = true
            
        case .failure(let error):
            importAlertMessage = "Import failed: \(error.localizedDescription)"
            showImportAlert = true
            HapticManager.shared.error()
        }
    }
    
    // MARK: - Data Export Sheet
    private var dataExportSheet: some View {
        NavigationView {
            ScrollView {
                Text(exportedData)
                    .font(.system(.caption, design: .monospaced))
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .navigationTitle("User Data Export")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { showDataExport = false }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    ShareLink(item: exportedData) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
        }
    }
    
    // MARK: - Export User Data as CSV
    private func exportUserDataAsCSV() {
        var csv = "=== USER PROFILE ===\n"
        csv += "Field,Value\n"
        csv += "Username,\(userProfile.username)\n"
        csv += "Level,\(userProfile.level)\n"
        csv += "Total XP,\(userProfile.xp)\n"
        csv += "Current Streak,\(userProfile.currentStreak)\n"
        csv += "Longest Streak,\(userProfile.longestStreak)\n"
        csv += "Daily Goal (min),\(userProfile.dailyGoalMinutes)\n"
        csv += "Coins,\(CurrencyManager.shared.coins)\n"
        csv += "Last Study Date,\(userProfile.lastStudyDate?.formatted() ?? "Never")\n"
        
        csv += "\n=== STUDY SESSIONS (\(sessions.count) total) ===\n"
        csv += "Date,Duration (min),XP Earned,Subject ID,Technique ID,Completed\n"
        for session in sessions.prefix(50) {
            csv += "\(session.timestamp.formatted()),"
            csv += "\(session.duration / 60),"
            csv += "\(session.xpEarned),"
            csv += "\(session.subjectId?.uuidString ?? "None"),"
            csv += "\(session.techniqueId?.uuidString ?? "None"),"
            csv += "\(session.isCompleted)\n"
        }
        if sessions.count > 50 {
            csv += "... and \(sessions.count - 50) more sessions\n"
        }
        
        csv += "\n=== TASKS (\(tasks.count) total) ===\n"
        csv += "Title,Completed,Created At,Subject ID\n"
        for task in tasks.prefix(50) {
            csv += "\(task.title),"
            csv += "\(task.isCompleted),"
            csv += "\(task.createdAt.formatted()),"
            csv += "\(task.subjectId?.uuidString ?? "None")\n"
        }
        if tasks.count > 50 {
            csv += "... and \(tasks.count - 50) more tasks\n"
        }
        
        csv += "\n=== SUBJECTS (\(subjects.count) total) ===\n"
        csv += "Name,Color\n"
        for subject in subjects {
            csv += "\(subject.name),\(subject.colorHex)\n"
        }
        
        csv += "\n=== TECHNIQUES USED ===\n"
        let usedTechniqueIds = Set(sessions.compactMap { $0.techniqueId })
        csv += "Total unique techniques used: \(usedTechniqueIds.count)\n"
        for techniqueId in usedTechniqueIds {
            if let technique = techniques.first(where: { $0.id == techniqueId }) {
                csv += "- \(technique.name) (\(technique.category))\n"
            }
        }
        
        csv += "\n=== BADGES (\(badges.count) total) ===\n"
        csv += "Name,Category,Progress,Requirement,Earned,Earned Date\n"
        for badge in badges.sorted(by: { $0.name < $1.name }) {
            csv += "\(badge.name),"
            csv += "\(badge.category),"
            csv += "\(badge.progress),"
            csv += "\(badge.requirement),"
            csv += "\(badge.isEarned),"
            csv += "\(badge.earnedDate?.formatted() ?? "N/A")\n"
        }
        
        csv += "\n=== COMPUTED STATS ===\n"
        let completedSessions = sessions.filter { $0.isCompleted }
        let totalMinutes = completedSessions.reduce(0) { $0 + ($1.duration / 60) }
        let completedTasksCount = tasks.filter { $0.isCompleted }.count
        csv += "Total study time (min): \(totalMinutes)\n"
        csv += "Completed tasks: \(completedTasksCount)\n"
        csv += "Completed sessions: \(completedSessions.count)\n"
        
        exportedData = csv
    }
    
    // MARK: - Unlock All Badges with Required Data
    private func unlockAllBadgesWithData() {
        // 1. Set user profile data to meet all requirements
        userProfile.currentStreak = 1000
        userProfile.longestStreak = 1000
        
        // 2. Create fake sessions to meet time/technique requirements
        let calendar = Calendar.current
        let now = Date()
        
        // Create sessions with various techniques to unlock technique badges
        let allTechniqueIds = techniques.map { $0.id }
        
        // First, create 3+ sessions TODAY with different techniques for "Method Actor" badge
        for (index, techniqueId) in allTechniqueIds.prefix(5).enumerated() {
            var todayComponents = calendar.dateComponents([.year, .month, .day], from: now)
            todayComponents.hour = 9 + index // Different hours today
            if let todayDate = calendar.date(from: todayComponents) {
                let todaySession = StudySession(
                    duration: 1800, // 30 min each
                    xpEarned: 50,
                    timestamp: todayDate,
                    subjectId: subjects.first?.id,
                    techniqueId: techniqueId,
                    isCompleted: true
                )
                modelContext.insert(todaySession)
            }
        }
        
        // Then create sessions on different days for overall technique discovery badges
        for (index, techniqueId) in allTechniqueIds.prefix(100).enumerated() {
            let session = StudySession(
                duration: 3600, // 1 hour each
                xpEarned: 100,
                timestamp: calendar.date(byAdding: .day, value: -(index + 1), to: now) ?? now,
                subjectId: subjects.first?.id,
                techniqueId: techniqueId,
                isCompleted: true
            )
            modelContext.insert(session)
        }
        
        // Create after-midnight session for Gremlin badge
        var midnightComponents = calendar.dateComponents([.year, .month, .day], from: now)
        midnightComponents.hour = 2
        if let midnightDate = calendar.date(from: midnightComponents) {
            let gremlinSession = StudySession(
                duration: 1800,
                xpEarned: 50,
                timestamp: midnightDate,
                isCompleted: true
            )
            modelContext.insert(gremlinSession)
        }
        
        // Create early bird session
        midnightComponents.hour = 5
        if let earlyDate = calendar.date(from: midnightComponents) {
            let earlySession = StudySession(
                duration: 1800,
                xpEarned: 50,
                timestamp: earlyDate,
                isCompleted: true
            )
            modelContext.insert(earlySession)
        }
        
        // Create weekend sessions
        let saturday = calendar.nextDate(after: now, matching: DateComponents(weekday: 7), matchingPolicy: .nextTime) ?? now
        let sunday = calendar.nextDate(after: now, matching: DateComponents(weekday: 1), matchingPolicy: .nextTime) ?? now
        
        let satSession = StudySession(duration: 3600, xpEarned: 100, timestamp: saturday, isCompleted: true)
        let sunSession = StudySession(duration: 3600, xpEarned: 100, timestamp: sunday, isCompleted: true)
        modelContext.insert(satSession)
        modelContext.insert(sunSession)
        
        // Create marathon session (4+ hours)
        let marathonSession = StudySession(
            duration: 4 * 60 * 60, // 4 hours
            xpEarned: 400,
            timestamp: now,
            isCompleted: true
        )
        modelContext.insert(marathonSession)
        
        // Create late night sessions for Night Owl
        for i in 0..<10 {
            var lateComponents = calendar.dateComponents([.year, .month, .day], from: now)
            lateComponents.hour = 23
            lateComponents.day = (lateComponents.day ?? 1) - i
            if let lateDate = calendar.date(from: lateComponents) {
                let lateSession = StudySession(
                    duration: 1800,
                    xpEarned: 50,
                    timestamp: lateDate,
                    isCompleted: true
                )
                modelContext.insert(lateSession)
            }
        }
        
        // Create Christmas session
        var christmasComponents = DateComponents()
        christmasComponents.year = calendar.component(.year, from: now)
        christmasComponents.month = 12
        christmasComponents.day = 25
        christmasComponents.hour = 12
        if let christmasDate = calendar.date(from: christmasComponents) {
            let christmasSession = StudySession(
                duration: 7 * 60 * 60, // 7 hours
                xpEarned: 700,
                timestamp: christmasDate,
                isCompleted: true
            )
            modelContext.insert(christmasSession)
        }
        
        // Create subjects for Subject Hopper badge and update subject hours
        for (index, subject) in subjects.enumerated() {
            var todayComponents = calendar.dateComponents([.year, .month, .day], from: now)
            todayComponents.hour = 8 + (index % 12)
            if let todayDate = calendar.date(from: todayComponents) {
                // Create session with this subject
                let subjectSession = StudySession(
                    duration: 3600 * (index + 1), // 1-N hours per subject
                    xpEarned: 100,
                    timestamp: todayDate,
                    subjectId: subject.id,
                    isCompleted: true
                )
                modelContext.insert(subjectSession)
                
                // Update subject's totalSeconds
                subject.totalSeconds += 3600 * (index + 1)
                subject.lastStudied = todayDate
            }
        }
        
        // 3. Create completed tasks for task badges
        for i in 0..<500 {
            let task = Task(
                title: "Test Task \(i + 1)",
                isCompleted: true,
                completedAt: now
            )
            modelContext.insert(task)
        }
        
        // 4. Save all the data
        try? modelContext.save()
        
        // 5. Now delete and recreate badges, then unlock them
        do {
            try modelContext.delete(model: Badge.self)
            try modelContext.save()
        } catch {
            print("Failed to delete badges: \(error)")
        }
        
        DataController.shared.initializeDefaultBadges(context: modelContext)
        
        // 6. Fetch and unlock all badges
        let descriptor = FetchDescriptor<Badge>()
        if let allBadges = try? modelContext.fetch(descriptor) {
            let unlockDate = Date()
            for badge in allBadges {
                badge.progress = badge.requirement
                badge.isEarned = true
                badge.earnedDate = unlockDate
            }
            do {
                try modelContext.save()
                HapticManager.shared.success()
                print("Unlocked \(allBadges.count) badges with full data successfully")
            } catch {
                print("Failed to save badges: \(error)")
            }
        }
    }
    
    private var dataManagementSection: some View {
        Section("Data Management") {
            Button {
                QuestService.shared.resetClaimedStatus()
                HapticManager.shared.success()
            } label: {
                HStack {
                    Image(systemName: "arrow.counterclockwise")
                        .foregroundColor(themeService.currentTheme.accent)
                    Text("Reset Quest Claims")
                        .foregroundColor(themeService.currentTheme.text)
                }
            }
            
            Button(role: .destructive) {
                showResetConfirmation = true
            } label: {
                Text("Reset All Data")
                    .foregroundColor(.red)
            }
        }
    }
    
    // MARK: - Logic
    
    private func recalculateDailyGoal() {
        guard userProfile.monthlyStudyGoalHours > 0 else { return }
        
        let calendar = Calendar.current
        let now = Date()
        
        // 1. Calculate Monthly Progress (Hours)
        let components = calendar.dateComponents([.year, .month], from: now)
        guard let monthStart = calendar.date(from: components) else { return }
        
        // Filter sessions for current month
        let monthSessions = sessions.filter { $0.timestamp >= monthStart && $0.isCompleted }
        let currentSeconds = monthSessions.reduce(0) { $0 + $1.duration }
        let currentHours = Double(currentSeconds) / 3600.0
        
        // 2. Goal Calculation
        // Formula: (Monthly Goal - Progress) / Days Remaining
        let remainingGoalHours = max(0, userProfile.monthlyStudyGoalHours - currentHours)
        
        let range = calendar.range(of: .day, in: .month, for: now)!
        let totalDays = range.count
        let currentDay = calendar.component(.day, from: now)
        let daysLeft = max(1, totalDays - currentDay + 1) // +1 to include today
        
        let dailyHours = remainingGoalHours / Double(daysLeft)
        let dailyMinutes = Int(dailyHours * 60)
        
        // Update UserProfile
        // Enforce a minimum realistic goal? Or allow 0 if finished?
        // If remaining is 0, goal is 0.
        // If remaining is huge, goal is huge.
        userProfile.dailyGoalMinutes = dailyMinutes
        
        // print("Recalculated: Goal \(userProfile.monthlyStudyGoalHours), Done \(currentHours), Left \(daysLeft) days -> \(dailyMinutes) min/day")
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .modelContainer(for: [UserProfile.self, StudySession.self, BreakSession.self, Task.self])
            .environmentObject(ThemeService.shared)
    }
}
