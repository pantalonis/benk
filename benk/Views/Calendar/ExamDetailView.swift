//
//  ExamDetailView.swift
//  benk
//
//  Created on 2025-12-15
//

import SwiftUI
import SwiftData

struct ExamDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeService: ThemeService
    @Query private var subjects: [Subject]
    
    let exam: Exam
    
    @State private var showEditSheet = false
    @State private var showDeleteAlert = false
    
    var subject: Subject? {
        guard let subjectId = exam.subjectId else { return nil }
        return subjects.first { $0.id == subjectId }
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: exam.examDate)
    }
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: exam.examDate)
    }
    
    var formattedDuration: String? {
        guard let duration = exam.duration else { return nil }
        let hours = duration / 60
        let minutes = duration % 60
        
        if hours > 0 && minutes > 0 {
            return "\(hours)h \(minutes)m"
        } else if hours > 0 {
            return "\(hours)h"
        } else {
            return "\(minutes)m"
        }
    }
    
    var body: some View {
        ZStack {
            ThemedBackground(theme: themeService.currentTheme)
            
            VStack(spacing: 0) {
                // MARK: - Custom Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.left")
                            .font(.title2.weight(.semibold))
                            .foregroundColor(themeService.currentTheme.text)
                            .frame(width: 44, height: 44)
                            .background(themeService.currentTheme.surface.opacity(0.5))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text("Exam Details")
                        .font(.headline)
                        .foregroundColor(themeService.currentTheme.text)
                    
                    Spacer()
                    
                    // Placeholder for symmetry
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Header Card with Subject and Countdown
                        headerCard
                        
                        // Date & Time Card
                        dateTimeCard
                        
                        // Description Card (if available)
                        if !exam.examDescription.isEmpty {
                            descriptionCard
                        }
                        
                        // Alerts Card
                        alertsCard
                        
                        // Action Buttons
                        actionButtons
                        
                        Spacer(minLength: 40)
                    }
                    .padding()
                }
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showEditSheet) {
            ExamFormSheet(exam: exam)
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
    
    // MARK: - Header Card
    private var headerCard: some View {
        GlassCard(padding: 20) {
            VStack(spacing: 16) {
                // Subject Tag
                HStack {
                    SubjectColorTag(subject: subject, size: .large)
                    Spacer()
                    CountdownBadge(exam: exam, size: .large)
                }
                
                // Urgency Indicator
                if exam.urgency == .today || exam.urgency == .urgent {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(exam.urgency.color)
                        
                        Text(exam.urgency == .today ? "Exam is today!" : "Exam is soon!")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(exam.urgency.color)
                        
                        Spacer()
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(exam.urgency.color.opacity(0.15))
                    )
                }
            }
        }
        .animatedAppearance(delay: 0.1)
    }
    
    // MARK: - Date & Time Card
    private var dateTimeCard: some View {
        GlassCard(padding: 20) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Date & Time")
                    .font(.headline)
                    .foregroundColor(themeService.currentTheme.text)
                
                Divider()
                
                ExamInfoRow(
                    icon: "calendar",
                    title: "Date",
                    value: formattedDate
                )
                
                ExamInfoRow(
                    icon: "clock",
                    title: "Time",
                    value: formattedTime
                )
                
                if let durationText = formattedDuration {
                    ExamInfoRow(
                        icon: "hourglass",
                        title: "Duration",
                        value: durationText
                    )
                }
            }
        }
        .animatedAppearance(delay: 0.2)
    }
    
    // MARK: - Description Card
    private var descriptionCard: some View {
        GlassCard(padding: 20) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "doc.text")
                        .foregroundColor(themeService.currentTheme.accent)
                        .font(.title3)
                    
                    Text("Description")
                        .font(.headline)
                        .foregroundColor(themeService.currentTheme.text)
                }
                
                Divider()
                
                Text(exam.examDescription)
                    .font(.subheadline)
                    .foregroundColor(themeService.currentTheme.text)
                    .lineSpacing(4)
            }
        }
        .animatedAppearance(delay: 0.3)
    }
    
    // MARK: - Alerts Card
    private var alertsCard: some View {
        GlassCard(padding: 20) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "bell.fill")
                        .foregroundColor(themeService.currentTheme.accent)
                        .font(.title3)
                    
                    Text("Alerts")
                        .font(.headline)
                        .foregroundColor(themeService.currentTheme.text)
                }
                
                Divider()
                
                AlertsListView(alerts: exam.alerts)
            }
        }
        .animatedAppearance(delay: 0.4)
    }
    
    // MARK: - Action Buttons
    private var actionButtons: some View {
        VStack(spacing: 12) {
            // Edit Button
            Button(action: {
                showEditSheet = true
                HapticManager.shared.selection()
            }) {
                HStack {
                    Image(systemName: "pencil")
                        .font(.headline)
                    Text("Edit Exam")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(themeService.currentTheme.accent)
                        .shadow(color: themeService.currentTheme.accent.opacity(0.3), radius: 8, x: 0, y: 4)
                )
                .foregroundColor(.white)
            }
            
            // Delete Button
            Button(action: {
                showDeleteAlert = true
                HapticManager.shared.warning()
            }) {
                HStack {
                    Image(systemName: "trash")
                        .font(.headline)
                    Text("Delete Exam")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.red.opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.red, lineWidth: 1.5)
                        )
                )
                .foregroundColor(.red)
            }
        }
        .animatedAppearance(delay: 0.5)
    }
    
    // MARK: - Delete Exam
    private func deleteExam() {
        CalendarService.shared.deleteExam(exam, context: modelContext)
        HapticManager.shared.success()
        dismiss()
    }
}

#Preview {
    let mockExam = Exam(
        subjectId: UUID(),
        examDate: Date().addingTimeInterval(259200), // 3 days from now
        duration: 90,
        examDescription: "Chapters 1-5, focusing on key concepts and formulas",
        alerts: [60, 1440]
    )
    
    return NavigationStack {
        ExamDetailView(exam: mockExam)
            .environmentObject(ThemeService.shared)
            .modelContainer(for: [Exam.self, Subject.self])
    }
}
