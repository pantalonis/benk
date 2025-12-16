//
//  StudyAnalyticsView.swift
//  benk
//
//  Created on 2025-12-15
//

import SwiftUI
import SwiftData
import Charts

struct StudyAnalyticsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeService: ThemeService
    
    @Environment(\.modelContext) private var modelContext
    
    @Query(filter: #Predicate<StudySession> { $0.isCompleted }, sort: \StudySession.timestamp, order: .reverse)
    private var completedSessions: [StudySession]
    @Query private var subjects: [Subject]
    @Query private var techniques: [Technique]
    @Query private var breakSessions: [BreakSession]
    
    @State private var selectedSubject: Subject? = nil
    @State private var selectedTechnique: Technique? = nil

    @State private var showExportSheet = false
    @State private var exportedAnalytics = ""
    
    // Cached filter values
    @State private var cachedUsedSubjectIDs: Set<UUID> = []
    @State private var cachedUsedTechniqueIDs: Set<UUID> = []
    @State private var lastSessionCount: Int = 0
    
    // Filtered subjects/techniques that have been used
    var usedSubjects: [Subject] {
        subjects.filter { cachedUsedSubjectIDs.contains($0.id) }
            .sorted { $0.name < $1.name }
    }
    
    var usedTechniques: [Technique] {
        techniques.filter { cachedUsedTechniqueIDs.contains($0.id) }
            .sorted { $0.name < $1.name }
    }
    
    // Filtered sessions based on selected filters
    var filteredSessions: [StudySession] {
        var result = Array(completedSessions)
        
        if let sub = selectedSubject {
            result = result.filter { $0.subjectId == sub.id }
        }
        
        if let tech = selectedTechnique {
            result = result.filter { $0.techniqueId == tech.id }
        }
        
        return result
    }
    
    var totalSeconds: Int {
        filteredSessions.reduce(0) { $0 + $1.duration }
    }
    
    var totalSessions: Int {
        filteredSessions.count
    }
    
    var totalBreakSeconds: Int {
        breakSessions.reduce(0) { $0 + $1.duration }
    }
    
    private func recalculateCachedIDs() {
        cachedUsedSubjectIDs = Set(completedSessions.compactMap { $0.subjectId })
        cachedUsedTechniqueIDs = Set(completedSessions.compactMap { $0.techniqueId })
    }
    
    var body: some View {
        ZStack {
            ThemedBackground(theme: themeService.currentTheme)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Custom Header
                    HStack {
                        Button(action: {
                            dismiss()
                            HapticManager.shared.selection()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(themeService.currentTheme.accent)
                                .frame(width: 40, height: 40)
                                .background(
                                    Circle()
                                        .fill(themeService.currentTheme.accent.opacity(0.15))
                                )
                        }
                        
                        Spacer()
                        
                        Text("Study Analytics")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(themeService.currentTheme.text)
                        
                        Spacer()
                        
                        Button(action: {
                            if let json = BackupService.shared.createAnalyticsBackup(context: modelContext) {
                                exportedAnalytics = json
                                showExportSheet = true
                            }
                        }) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(themeService.currentTheme.accent)
                                .frame(width: 40, height: 40)
                                .background(
                                    Circle()
                                        .fill(themeService.currentTheme.accent.opacity(0.15))
                                )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // Filters
                    HStack(spacing: 12) {
                        // Subject Filter
                        Menu {
                            Button("All Subjects", action: { selectedSubject = nil })
                            ForEach(usedSubjects) { subject in
                                Button(action: { selectedSubject = subject }) {
                                    Label(subject.name, systemImage: subject.iconName)
                                }
                            }
                        } label: {
                            HStack {
                                Image(systemName: "book.fill")
                                    .font(.caption)
                                Text(selectedSubject?.name ?? "All Subjects")
                                    .font(.subheadline)
                                    .lineLimit(1)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.ultraThinMaterial)
                            )
                            .foregroundColor(selectedSubject == nil ? themeService.currentTheme.textSecondary : themeService.currentTheme.accent)
                        }
                        
                        // Technique Filter
                        Menu {
                            Button("All Techniques", action: { selectedTechnique = nil })
                            ForEach(usedTechniques) { tech in
                                Button(action: { selectedTechnique = tech }) {
                                    Label(tech.name, systemImage: "timer")
                                }
                            }
                        } label: {
                            HStack {
                                Image(systemName: "timer")
                                    .font(.caption)
                                Text(selectedTechnique?.name ?? "All Techniques")
                                    .font(.subheadline)
                                    .lineLimit(1)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.ultraThinMaterial)
                            )
                            .foregroundColor(selectedTechnique == nil ? themeService.currentTheme.textSecondary : themeService.currentTheme.accent)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Stats Overview
                    HStack(spacing: 16) {
                        StatCard(
                            title: "Study Time",
                            value: nil,
                            valueString: totalSeconds.timeFormatted,
                            icon: "clock.fill",
                            color: .blue
                        )
                        
                        StatCard(
                            title: "Sessions",
                            value: Double(totalSessions),
                            valueString: nil,
                            icon: "list.bullet",
                            color: .green
                        )
                         
                        StatCard(
                           title: "Break Time",
                           value: nil,
                           valueString: totalBreakSeconds.timeFormatted,
                           icon: "cup.and.saucer.fill",
                           color: .orange
                        )
                    }
                    .padding(.horizontal)
                    
                    // Study Progress Chart
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Study Progress")
                            .font(.headline)
                            .foregroundColor(themeService.currentTheme.text)
                            .padding(.horizontal)
                        
                        StudyProgressChart(sessions: filteredSessions)
                            .padding(.horizontal)
                            .frame(height: 250)
                    }
                    
                    // Session breakdown by subject
                    if !usedSubjects.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Time by Subject")
                                .font(.headline)
                                .foregroundColor(themeService.currentTheme.text)
                                .padding(.horizontal)
                            
                            ForEach(usedSubjects) { subject in
                                let subjectSeconds = completedSessions
                                    .filter { $0.subjectId == subject.id }
                                    .reduce(0) { $0 + $1.duration }
                                
                                HStack {
                                    Circle()
                                        .fill(subject.color)
                                        .frame(width: 12, height: 12)
                                    
                                    Text(subject.name)
                                        .font(.subheadline)
                                        .foregroundColor(themeService.currentTheme.text)
                                    
                                    Spacer()
                                    
                                    Text(subjectSeconds.timeFormatted)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(themeService.currentTheme.accent)
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(.ultraThinMaterial)
                                )
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    Spacer(minLength: 100)
                }
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            recalculateCachedIDs()
            lastSessionCount = completedSessions.count
        }
        .onChange(of: completedSessions.count) { oldCount, newCount in
            if newCount != lastSessionCount {
                lastSessionCount = newCount
                recalculateCachedIDs()
            }
        }
        .sheet(isPresented: $showExportSheet) {
            ShareSheet(activityItems: [saveToTempFile(text: exportedAnalytics)])
        }
    }
    
    private func saveToTempFile(text: String) -> URL {
        let fileName = "benk_Analytics_\(Date().formatted(date: .numeric, time: .omitted)).json"
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent(fileName)
        
        do {
            try text.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            print("Failed to save temp file: \(error)")
            return tempDir // Fallback
        }
    }
}

// Share Sheet wrapper
struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    NavigationStack {
        StudyAnalyticsView()
            .modelContainer(for: [StudySession.self, BreakSession.self, Subject.self, Technique.self])
            .environmentObject(ThemeService.shared)
    }
}

