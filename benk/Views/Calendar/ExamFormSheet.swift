//
//  ExamFormSheet.swift
//  benk
//
//  Created on 2025-12-15
//

import SwiftUI
import SwiftData

struct ExamFormSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeService: ThemeService
    @Query private var subjects: [Subject]
    
    // Edit mode support
    let exam: Exam?
    let isEditMode: Bool
    
    // Form state
    @State private var selectedSubject: Subject?
    @State private var paperName: String
    @State private var examDate: Date
    @State private var examTime: Date
    @State private var hasDuration: Bool
    @State private var durationHours: Int
    @State private var durationMinutes: Int
    @State private var examDescription: String
    @State private var selectedAlerts: Set<AlertOption>
    @State private var showDeleteAlert = false
    
    init(exam: Exam? = nil) {
        self.exam = exam
        self.isEditMode = exam != nil
        
        // Initialize state based on exam or defaults
        if let exam = exam {
            _paperName = State(initialValue: exam.paperName)
            _examDate = State(initialValue: Calendar.current.startOfDay(for: exam.examDate))
            _examTime = State(initialValue: exam.examDate)
            _hasDuration = State(initialValue: exam.duration != nil)
            _durationHours = State(initialValue: (exam.duration ?? 90) / 60)
            _durationMinutes = State(initialValue: (exam.duration ?? 90) % 60)
            _examDescription = State(initialValue: exam.examDescription)
            
            // Convert alerts to AlertOptions
            var alertSet = Set<AlertOption>()
            for minutes in exam.alerts {
                if let option = AlertOption.from(minutes: minutes) {
                    alertSet.insert(option)
                }
            }
            _selectedAlerts = State(initialValue: alertSet)
        } else {
            _paperName = State(initialValue: "")
            _examDate = State(initialValue: Calendar.current.startOfDay(for: Date().addingTimeInterval(7 * 24 * 3600)))
            _examTime = State(initialValue: Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date())
            _hasDuration = State(initialValue: true)
            _durationHours = State(initialValue: 1)
            _durationMinutes = State(initialValue: 30)
            _examDescription = State(initialValue: "")
            _selectedAlerts = State(initialValue: [.oneDay, .oneHour])
        }
    }
    
    var canSave: Bool {
        selectedSubject != nil
    }
    
    var combinedDateTime: Date {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: examDate)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: examTime)
        
        var combined = DateComponents()
        combined.year = dateComponents.year
        combined.month = dateComponents.month
        combined.day = dateComponents.day
        combined.hour = timeComponents.hour
        combined.minute = timeComponents.minute
        
        return calendar.date(from: combined) ?? examDate
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                ThemedBackground(theme: themeService.currentTheme)
                
                Form {
                    // Paper Name & Subject Section
                    paperNameSection
                    
                    // Subject Section
                    subjectSection
                    
                    // Date & Time Section
                    dateTimeSection
                    
                    // Duration Section
                    durationSection
                    
                    // Description Section
                    descriptionSection
                    
                    // Alerts Section
                    alertsSection
                    
                    // Delete Button (Edit Mode Only)
                    if isEditMode {
                        deleteSection
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(isEditMode ? "Edit Exam" : "New Exam")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveExam()
                    }
                    .disabled(!canSave)
                }
            }
            .onAppear {
                // Set selected subject in edit mode
                if let exam = exam, let subjectId = exam.subjectId {
                    selectedSubject = subjects.first { $0.id == subjectId }
                }
            }
        }
        .alert("Delete Exam", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                deleteExam()
            }
        } message: {
            Text("Are you sure you want to delete this exam? This action cannot be undone.")
        }
    }
    
    // MARK: - Paper Name Section
    private var paperNameSection: some View {
        Section("Paper Name") {
            TextField("e.g., P1, Paper 2, Final", text: $paperName)
            
            // Preview of how it will look
            if let subject = selectedSubject, !paperName.isEmpty {
                HStack {
                    Text("Preview")
                        .foregroundColor(themeService.currentTheme.textSecondary)
                    Spacer()
                    HStack(spacing: 6) {
                        Text(paperName)
                            .fontWeight(.semibold)
                            .foregroundColor(themeService.currentTheme.text)
                        Text(subject.name)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(subject.color)
                            )
                    }
                }
            }
        }
    }
    
    // MARK: - Subject Section
    private var subjectSection: some View {
        Section("Subject") {
            if subjects.isEmpty {
                Text("No subjects available. Please create a subject first.")
                    .foregroundColor(themeService.currentTheme.textSecondary)
            } else {
                Picker("Subject", selection: $selectedSubject) {
                    Text("Select Subject").tag(nil as Subject?)
                    ForEach(subjects) { subject in
                        HStack {
                            Circle()
                                .fill(subject.color)
                                .frame(width: 12, height: 12)
                            Text(subject.name)
                        }
                        .tag(subject as Subject?)
                    }
                }
                
                // Subject Color Preview
                if let subject = selectedSubject {
                    HStack {
                        Text("Subject Color")
                            .foregroundColor(themeService.currentTheme.textSecondary)
                        Spacer()
                        Circle()
                            .fill(subject.color)
                            .frame(width: 30, height: 30)
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.3), lineWidth: 2)
                            )
                            .shadow(color: subject.color.opacity(0.4), radius: 4, x: 0, y: 2)
                    }
                }
            }
        }
    }
    
    // MARK: - Date & Time Section
    private var dateTimeSection: some View {
        Section("Date & Time") {
            DatePicker("Date", selection: $examDate, displayedComponents: .date)
            
            DatePicker("Time", selection: $examTime, displayedComponents: .hourAndMinute)
            
            // Combined date/time preview
            HStack {
                Text("Exam scheduled for")
                    .foregroundColor(themeService.currentTheme.textSecondary)
                Spacer()
                Text(combinedDateTime.formatted(date: .abbreviated, time: .shortened))
                    .foregroundColor(themeService.currentTheme.text)
                    .fontWeight(.medium)
            }
        }
    }
    
    // MARK: - Duration Section
    private var durationSection: some View {
        Section("Duration") {
            Toggle("Set Duration", isOn: $hasDuration.animation())
            
            if hasDuration {
                Picker("Hours", selection: $durationHours) {
                    ForEach(0..<5) { hour in
                        Text("\(hour)h").tag(hour)
                    }
                }
                
                Picker("Minutes", selection: $durationMinutes) {
                    ForEach([0, 15, 30, 45], id: \.self) { minute in
                        Text("\(minute)m").tag(minute)
                    }
                }
                
                if durationHours > 0 || durationMinutes > 0 {
                    HStack {
                        Text("Total Duration")
                            .foregroundColor(themeService.currentTheme.textSecondary)
                        Spacer()
                        Text(formattedTotalDuration)
                            .foregroundColor(themeService.currentTheme.text)
                            .fontWeight(.medium)
                    }
                }
            }
        }
    }
    
    private var formattedTotalDuration: String {
        if durationHours > 0 && durationMinutes > 0 {
            return "\(durationHours)h \(durationMinutes)m"
        } else if durationHours > 0 {
            return "\(durationHours)h"
        } else if durationMinutes > 0 {
            return "\(durationMinutes)m"
        } else {
            return "Not set"
        }
    }
    
    // MARK: - Description Section
    private var descriptionSection: some View {
        Section("Description") {
            TextEditor(text: $examDescription)
                .frame(minHeight: 80)
                .placeholder(when: examDescription.isEmpty) {
                    Text("e.g., Chapters 1-3, midterm exam")
                        .foregroundColor(themeService.currentTheme.textSecondary.opacity(0.5))
                }
        }
    }
    
    // MARK: - Alerts Section
    private var alertsSection: some View {
        Section("Alerts") {
            ForEach(AlertOption.allCases, id: \.self) { option in
                Toggle(option.displayName, isOn: Binding(
                    get: { selectedAlerts.contains(option) },
                    set: { isSelected in
                        if isSelected {
                            selectedAlerts.insert(option)
                        } else {
                            selectedAlerts.remove(option)
                        }
                    }
                ))
            }
        }
    }
    
    // MARK: - Delete Section
    private var deleteSection: some View {
        Section {
            Button(action: {
                showDeleteAlert = true
                HapticManager.shared.warning()
            }) {
                HStack {
                    Spacer()
                    Text("Delete Exam")
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                    Spacer()
                }
            }
        }
    }
    
    // MARK: - Save Exam
    private func saveExam() {
        guard let subject = selectedSubject else { return }
        
        let finalDateTime = combinedDateTime
        let finalDuration = hasDuration ? (durationHours * 60 + durationMinutes) : nil
        let alertMinutes = selectedAlerts.map { $0.minutes }.sorted(by: >)
        
        if isEditMode, let existingExam = exam {
            // Update existing exam
            existingExam.subjectId = subject.id
            existingExam.paperName = paperName
            existingExam.examDate = finalDateTime
            existingExam.duration = finalDuration
            existingExam.examDescription = examDescription
            existingExam.alerts = alertMinutes
            
            CalendarService.shared.updateExam(existingExam, context: modelContext)
        } else {
            // Create new exam
            let newExam = Exam(
                subjectId: subject.id,
                paperName: paperName,
                examDate: finalDateTime,
                duration: finalDuration,
                examDescription: examDescription,
                alerts: alertMinutes
            )
            
            CalendarService.shared.createExam(newExam, context: modelContext)
        }
        
        HapticManager.shared.success()
        dismiss()
    }
    
    // MARK: - Delete Exam
    private func deleteExam() {
        guard let exam = exam else { return }
        
        CalendarService.shared.deleteExam(exam, context: modelContext)
        HapticManager.shared.success()
        dismiss()
    }
}

// MARK: - Alert Options
enum AlertOption: Int, CaseIterable {
    case fifteenMinutes = 15
    case thirtyMinutes = 30
    case oneHour = 60
    case twoHours = 120
    case oneDay = 1440
    case twoDays = 2880
    case oneWeek = 10080
    
    var displayName: String {
        switch self {
        case .fifteenMinutes: return "15 minutes before"
        case .thirtyMinutes: return "30 minutes before"
        case .oneHour: return "1 hour before"
        case .twoHours: return "2 hours before"
        case .oneDay: return "1 day before"
        case .twoDays: return "2 days before"
        case .oneWeek: return "1 week before"
        }
    }
    
    var minutes: Int {
        return self.rawValue
    }
    
    static func from(minutes: Int) -> AlertOption? {
        return AlertOption(rawValue: minutes)
    }
}

#Preview("Create Mode") {
    ExamFormSheet()
        .environmentObject(ThemeService.shared)
        .modelContainer(for: [Exam.self, Subject.self])
}

#Preview("Edit Mode") {
    let mockExam = Exam(
        subjectId: UUID(),
        examDate: Date().addingTimeInterval(259200),
        duration: 90,
        examDescription: "Midterm exam covering chapters 1-5",
        alerts: [60, 1440]
    )
    
    return ExamFormSheet(exam: mockExam)
        .environmentObject(ThemeService.shared)
        .modelContainer(for: [Exam.self, Subject.self])
}
