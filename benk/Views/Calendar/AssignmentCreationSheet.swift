//
//  AssignmentCreationSheet.swift
//  benk
//
//  Created on 2025-12-15
//

import SwiftUI
import SwiftData

struct AssignmentCreationSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeService: ThemeService
    @Query private var subjects: [Subject]
    
    @State private var title: String = ""
    @State private var selectedSubject: Subject?
    @State private var dueDate: Date = Date().addingTimeInterval(7 * 24 * 3600) // 1 week from now
    @State private var estimatedEffort: Double = 2.0 // hours
    @State private var priority: Priority = .medium
    @State private var status: AssignmentStatus = .notStarted
    @State private var notes: String = ""
    
    var canSave: Bool {
        !title.isEmpty
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                ThemedBackground(theme: themeService.currentTheme)
                
                Form {
                    Section("Assignment Details") {
                        TextField("Title", text: $title)
                        
                        if subjects.isEmpty {
                            Text("No subjects available")
                                .foregroundColor(themeService.currentTheme.textSecondary)
                        } else {
                            Picker("Subject (optional)", selection: $selectedSubject) {
                                Text("None").tag(nil as Subject?)
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
                        }
                    }
                    
                    Section("Due Date") {
                        DatePicker("Due", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                    }
                    
                    Section("Effort & Priority") {
                        HStack {
                            Text("Estimated Effort")
                            Spacer()
                            Text("\(String(format: "%.1f", estimatedEffort))h")
                                .foregroundColor(themeService.currentTheme.textSecondary)
                        }
                        
                        Slider(value: $estimatedEffort, in: 0.5...20, step: 0.5)
                        
                        Picker("Priority", selection: $priority) {
                            ForEach(Priority.allCases, id: \.self) { p in
                                HStack {
                                    Circle()
                                        .fill(p.color)
                                        .frame(width: 12, height: 12)
                                    Text(p.displayName)
                                }
                                .tag(p)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    Section("Status") {
                        Picker("Status", selection: $status) {
                            ForEach(AssignmentStatus.allCases, id: \.self) { s in
                                HStack {
                                    Image(systemName: s.icon)
                                    Text(s.displayName)
                                }
                                .tag(s)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    Section("Notes") {
                        TextEditor(text: $notes)
                            .frame(minHeight: 80)
                            .placeholder(when: notes.isEmpty) {
                                Text("Additional details...")
                                    .foregroundColor(themeService.currentTheme.textSecondary.opacity(0.5))
                            }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("New Assignment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveAssignment()
                    }
                    .disabled(!canSave)
                }
            }
        }
    }
    
    private func saveAssignment() {
        let assignment = Assignment(
            subjectId: selectedSubject?.id,
            title: title,
            dueDate: dueDate,
            estimatedEffortHours: estimatedEffort,
            priority: priority,
            status: status,
            notes: notes
        )
        
        CalendarService.shared.createAssignment(assignment, context: modelContext)
        HapticManager.shared.success()
        dismiss()
    }
}

#Preview {
    AssignmentCreationSheet()
        .environmentObject(ThemeService.shared)
        .modelContainer(for: [Assignment.self, Subject.self])
}
