//
//  ExamReminderWidget.swift
//  benk
//
//  Created on 2025-12-15
//

import SwiftUI
import SwiftData

struct ExamReminderWidget: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var themeService: ThemeService
    @Query private var subjects: [Subject]
    
    let isVisible: Bool
    @State private var animateEntry = false
    
    var upcomingExams: [Exam] {
        CalendarService.shared.getUpcomingExams(limit: 2, context: modelContext)
    }
    
    var body: some View {
        NavigationLink(destination: AllExamsScreen()) {
            GlassCard(padding: 8) {
                VStack(alignment: .leading, spacing: 6) {
                    // Header
                    headerView
                    
                    if upcomingExams.isEmpty {
                        // Empty state
                        emptyStateView
                    } else {
                        // Exam list
                        examListView
                    }
                    
                    Spacer(minLength: 0)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            if isVisible {
                animateEntry = false
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
                    animateEntry = true
                }
            } else {
                animateEntry = false
            }
        }
        .onChange(of: isVisible) { _, visible in
            if visible {
                animateEntry = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
                        animateEntry = true
                    }
                }
            } else {
                animateEntry = false
            }
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack(spacing: 6) {
            Image(systemName: "doc.text.fill")
                .foregroundColor(themeService.currentTheme.accent)
                .font(.callout)
            
            Text("Upcoming Exams")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(themeService.currentTheme.text)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption2)
                .foregroundColor(themeService.currentTheme.textSecondary)
        }
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        HStack {
            Spacer()
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(themeService.currentTheme.textSecondary.opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(themeService.currentTheme.textSecondary.opacity(0.5))
                }
                .scaleEffect(animateEntry ? 1.0 : 0.8)
                .opacity(animateEntry ? 1.0 : 0.0)
                
                Text("No upcoming exams")
                    .font(.subheadline)
                    .foregroundColor(themeService.currentTheme.textSecondary)
                    .opacity(animateEntry ? 1.0 : 0.0)
            }
            .padding(.vertical, 20)
            Spacer()
        }
    }
    
    // MARK: - Exam List View
    private var examListView: some View {
        VStack(spacing: 8) {
            ForEach(Array(upcomingExams.enumerated()), id: \.element.id) { index, exam in
                ExamWidgetRow(exam: exam, subjects: subjects)
                    .opacity(animateEntry ? 1.0 : 0.0)
                    .offset(y: animateEntry ? 0 : 10)
                    .animation(
                        .spring(response: 0.6, dampingFraction: 0.7)
                        .delay(Double(index) * 0.1),
                        value: animateEntry
                    )
            }
        }
    }

}

// MARK: - Exam Widget Row
struct ExamWidgetRow: View {
    let exam: Exam
    let subjects: [Subject]
    @EnvironmentObject var themeService: ThemeService
    
    var subject: Subject? {
        guard let subjectId = exam.subjectId else { return nil }
        return subjects.first { $0.id == subjectId }
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        return formatter.string(from: exam.examDate)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Subject color strip with enhanced styling
            SubjectColorStrip(subject: subject, width: 4)
            
            VStack(alignment: .leading, spacing: 3) {
                // Paper name with subject tag, or just subject name
                if !exam.paperName.isEmpty {
                    HStack(spacing: 6) {
                        Text(exam.paperName)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(themeService.currentTheme.text)
                            .lineLimit(1)
                        
                        if let subject = subject {
                            Text(subject.name)
                                .font(.system(size: 9))
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(subject.color)
                                )
                        }
                    }
                } else {
                    // Fallback: just show subject name with icon
                    HStack(spacing: 4) {
                        if let subject = subject {
                            Circle()
                                .fill(subject.color)
                                .frame(width: 6, height: 6)
                        }
                        
                        Text(subject?.name ?? "Exam")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(themeService.currentTheme.text)
                            .lineLimit(1)
                    }
                }
                
                // Date with icon
                HStack(spacing: 3) {
                    Image(systemName: "calendar")
                        .font(.caption2)
                        .foregroundColor(themeService.currentTheme.textSecondary)
                    
                    Text(formattedDate)
                        .font(.caption2)
                        .foregroundColor(themeService.currentTheme.textSecondary)
                }
            }
            
            Spacer()
            
            // Countdown badge with enhanced styling
            CountdownBadge(exam: exam, size: .small)
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [
                            (subject?.color ?? themeService.currentTheme.primary).opacity(0.1),
                            (subject?.color ?? themeService.currentTheme.primary).opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            (subject?.color ?? themeService.currentTheme.primary).opacity(0.2),
                            lineWidth: 1
                        )
                )
        )
    }
}

#Preview("With Exams") {
    let container = try! ModelContainer(for: Exam.self, Subject.self)
    let context = container.mainContext
    
    // Create mock subjects
    let mathSubject = Subject(name: "Mathematics", colorHex: "#FF6B6B", iconName: "function")
    let scienceSubject = Subject(name: "Science", colorHex: "#4ECDC4", iconName: "flask")
    let _ = context.insert(mathSubject)
    let _ = context.insert(scienceSubject)
    
    // Create mock exams
    let exam1 = Exam(
        subjectId: mathSubject.id,
        examDate: Date().addingTimeInterval(86400), // Tomorrow
        duration: 90,
        examDescription: "Midterm",
        alerts: [60, 1440]
    )
    let exam2 = Exam(
        subjectId: scienceSubject.id,
        examDate: Date().addingTimeInterval(259200), // 3 days
        duration: 120,
        examDescription: "Final",
        alerts: [60, 1440]
    )
    let _ = context.insert(exam1)
    let _ = context.insert(exam2)
    
    ExamReminderWidget(isVisible: true)
        .environmentObject(ThemeService.shared)
        .modelContainer(container)
        .padding()
        .background(Color.black)
}

#Preview("Empty State") {
    ExamReminderWidget(isVisible: true)
        .environmentObject(ThemeService.shared)
        .modelContainer(for: [Exam.self, Subject.self])
        .padding()
        .background(Color.black)
}
