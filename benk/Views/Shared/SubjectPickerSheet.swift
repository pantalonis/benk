//
//  SubjectPickerSheet.swift
//  benk
//
//  Created on 2025-12-12
//

import SwiftUI
import SwiftData

struct SubjectPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var themeService: ThemeService
    
    @Query private var subjects: [Subject]
    
    @Binding var selectedSubjectId: String
    @State private var isEditMode = false
    @State private var showSubjectEditor = false
    @State private var subjectToEdit: Subject?
    
    var body: some View {
        ZStack {
            themeService.currentTheme.background
                .ignoresSafeArea()
            
            ZStack(alignment: .top) {
                // Background Layer (Content)
                ScrollView {
                    VStack(spacing: 12) {
                        // Subject Cards
                        ForEach(subjects) { subject in
                            SubjectCard(
                                subject: subject,
                                isEditMode: isEditMode,
                                onSelect: {
                                    selectedSubjectId = subject.id.uuidString
                                    dismiss()
                                    HapticManager.shared.selection()
                                },
                                onEdit: {
                                    subjectToEdit = subject
                                    showSubjectEditor = true
                                },
                                onDelete: {
                                    deleteSubject(subject)
                                }
                            )
                        }
                        
                        // Add Subject Button (only in edit mode)
                        if isEditMode {
                            Button(action: {
                                subjectToEdit = nil
                                showSubjectEditor = true
                            }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title2)
                                    Text("Add Subject")
                                        .font(.headline)
                                }
                                .foregroundColor(themeService.currentTheme.accent)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(
                                            themeService.currentTheme.accent.opacity(0.5),
                                            style: StrokeStyle(lineWidth: 2, dash: [8, 4])
                                        )
                                )
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                    .padding(.top, 80) // Space for transparent header
                }
                
                // Header Layer (Top)
                HStack {
                    Button(action: {
                        withAnimation(.spring(response: 0.3)) {
                            isEditMode.toggle()
                        }
                        HapticManager.shared.selection()
                    }) {
                        Text(isEditMode ? "Done" : "Edit")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(themeService.currentTheme.accent)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        Capsule()
                                            .stroke(themeService.currentTheme.accent.opacity(0.3), lineWidth: 1)
                                    )
                            )
                    }
                    
                    Spacer()
                    
                    Text("Select Subject")
                        .font(.headline)
                        .foregroundColor(themeService.currentTheme.text)
                    
                    Spacer()
                    
                    Button(action: { dismiss() }) {
                        Text("Cancel")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(themeService.currentTheme.text)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        Capsule()
                                            .stroke(themeService.currentTheme.text.opacity(0.1), lineWidth: 1)
                                    )
                            )
                    }
                }
                .padding()
                .background(Color.clear) // Transparent background
            }
        }
        .sheet(isPresented: $showSubjectEditor) {
            SubjectEditorSheet(subject: subjectToEdit)
        }
    }
    
    private func deleteSubject(_ subject: Subject) {
        withAnimation {
            modelContext.delete(subject)
            HapticManager.shared.medium()
        }
    }
}

struct SubjectCard: View {
    let subject: Subject
    let isEditMode: Bool
    let onSelect: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    @EnvironmentObject var themeService: ThemeService
    
    var timeString: String {
        subject.totalSeconds.timeFormatted
    }
    
    var body: some View {
        Button(action: {
            if isEditMode {
                onEdit()
            } else {
                onSelect()
            }
        }) {
            HStack(spacing: 16) {
                // Icon with color background
                ZStack {
                    Circle()
                        .fill(subject.color.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: subject.iconName)
                        .font(.title2)
                        .foregroundColor(subject.color)
                }
                
                // Subject info
                VStack(alignment: .leading, spacing: 4) {
                    Text(subject.name)
                        .font(.headline)
                        .foregroundColor(themeService.currentTheme.text)
                    
                    Text(timeString)
                        .font(.subheadline)
                        .foregroundColor(themeService.currentTheme.textSecondary)
                }
                
                Spacer()
                
                // Edit mode indicator or delete button
                if isEditMode {
                    Button(action: onDelete) {
                        Image(systemName: "trash.fill")
                            .foregroundColor(.red)
                            .font(.title3)
                    }
                    .buttonStyle(PlainButtonStyle())
                } else {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(themeService.currentTheme.textSecondary)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                subject.color.opacity(0.3),
                                lineWidth: 1
                            )
                    )
            )
            .shadow(color: subject.color.opacity(0.2), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal)
    }
}

#Preview {
    @Previewable @State var selectedSubjectId: String = ""
    
    SubjectPickerSheet(selectedSubjectId: $selectedSubjectId)
        .modelContainer(for: Subject.self)
        .environmentObject(ThemeService.shared)
}
