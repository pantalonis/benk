//
//  AllExamsScreen.swift
//  benk
//
//  Created on 2025-12-15
//

import SwiftUI
import SwiftData

struct AllExamsScreen: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var themeService: ThemeService
    @Query private var subjects: [Subject]
    
    @State private var sortBy: ExamSortOption = .soonest
    @State private var filterBy: ExamFilterOption = .upcoming
    @State private var showCreateSheet = false
    
    var filteredAndSortedExams: [Exam] {
        CalendarService.shared.getAllExams(sortBy: sortBy, filterBy: filterBy, context: modelContext)
    }
    
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            ThemedBackground(theme: themeService.currentTheme)
            
            ZStack(alignment: .top) {
                
                // Content Layer (Bottom)
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        if filteredAndSortedExams.isEmpty {
                            emptyState
                        } else {
                            examsList
                        }
                    }
                    .padding()
                    .padding(.top, 150) // Adjust for Header + Controls height
                    .padding(.bottom, 80) // Space for FAB
                }
                
                // Fixed Header Layer (Top)
                VStack(spacing: 0) {
                    // Custom Header
                    header
                    
                    // Sorting and Filtering Controls
                    controlsSection
                }
                .background(Color.clear) // Transparent background
            }
            
            // Floating Add Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        showCreateSheet = true
                        HapticManager.shared.selection()
                    }) {
                        ZStack {
                            Circle()
                                .fill(themeService.currentTheme.accent)
                                .frame(width: 56, height: 56) // Slightly smaller for better proportion
                                .shadow(color: themeService.currentTheme.accent.opacity(0.4), radius: 10, x: 0, y: 5)
                            
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.trailing, 24)
                    .padding(.bottom, 24) // Adjusted spacing
                }
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showCreateSheet) {
            ExamFormSheet()
        }
    }
    
    // MARK: - Header
    private var header: some View {
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
            
            Text("Exams")
                .font(.title.weight(.bold))
                .foregroundColor(themeService.currentTheme.text)
            
            Spacer()
            
            // Placeholder for symmetry
            Circle()
                .fill(Color.clear)
                .frame(width: 44, height: 44)
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    // MARK: - Controls Section
    private var controlsSection: some View {
        VStack(spacing: 12) {
            // Filter Pills
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(ExamFilterOption.allCases, id: \.self) { filter in
                        FilterPill(
                            title: filter.displayName,
                            isSelected: filterBy == filter,
                            action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    filterBy = filter
                                }
                                HapticManager.shared.selection()
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }
            
            // Sorting Pills (Replacing Segmented Control)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    Text("Sort by:")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(themeService.currentTheme.textSecondary)
                        .padding(.leading, 16)
                    
                    ForEach(ExamSortOption.allCases, id: \.self) { option in
                        GlassSortPill(
                            title: option.displayName,
                            isSelected: sortBy == option,
                            action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    sortBy = option
                                }
                                HapticManager.shared.selection()
                            }
                        )
                    }
                }
                .padding(.trailing, 16)
            }
        }
        .padding(.vertical, 12)
    }
    
    // MARK: - Empty State
    private var emptyState: some View {
        EmptyExamState(
            icon: filterBy == .past ? "checkmark.circle" : "doc.text",
            title: emptyStateTitle,
            subtitle: emptyStateSubtitle
        )
    }
    
    private var emptyStateTitle: String {
        switch filterBy {
        case .all: return "No Exams"
        case .upcoming: return "No Upcoming Exams"
        case .thisWeek: return "No Exams This Week"
        case .past: return "No Past Exams"
        }
    }
    
    private var emptyStateSubtitle: String {
        switch filterBy {
        case .all: return "Create your first exam"
        case .upcoming: return "You're all caught up!"
        case .thisWeek: return "No exams scheduled this week"
        case .past: return "No completed exams yet"
        }
    }
    
    // MARK: - Exams List
    private var examsList: some View {
        LazyVStack(spacing: 12) {
            ForEach(Array(filteredAndSortedExams.enumerated()), id: \.element.id) { index, exam in
                NavigationLink(destination: ExamDetailView(exam: exam)) {
                    ExamCard(exam: exam, subjects: subjects)
                        .animatedAppearance(delay: Double(index) * 0.05)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

// MARK: - Filter Pill Component
struct FilterPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    @EnvironmentObject var themeService: ThemeService
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(isSelected ? .white : themeService.currentTheme.text)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? themeService.currentTheme.accent : themeService.currentTheme.textSecondary.opacity(0.2))
                )
        }
    }
}

// MARK: - Exam Card Component
struct ExamCard: View {
    let exam: Exam
    let subjects: [Subject]
    @EnvironmentObject var themeService: ThemeService
    
    var subject: Subject? {
        guard let subjectId = exam.subjectId else { return nil }
        return subjects.first { $0.id == subjectId }
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
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
        GlassCard(padding: 16) {
            HStack(spacing: 12) {
                // Subject Color Strip
                SubjectColorStrip(subject: subject, width: 5)
                
                VStack(alignment: .leading, spacing: 10) {
                    // Header with Paper Name + Subject Tag and Countdown
                    HStack {
                        if !exam.paperName.isEmpty {
                            HStack(spacing: 6) {
                                Text(exam.paperName)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(themeService.currentTheme.text)
                                
                                if let subject = subject {
                                    Text(subject.name)
                                        .font(.caption2)
                                        .fontWeight(.medium)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .background(
                                            Capsule()
                                                .fill(subject.color)
                                        )
                                }
                            }
                        } else {
                            SubjectColorTag(subject: subject, size: .medium)
                        }
                        
                        Spacer()
                        
                        CountdownBadge(exam: exam, size: .small)
                    }
                    
                    // Date and Time
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Image(systemName: "calendar")
                                .font(.caption)
                                .foregroundColor(themeService.currentTheme.textSecondary)
                            
                            Text(formattedDate)
                                .font(.subheadline)
                                .foregroundColor(themeService.currentTheme.text)
                            
                            Text("•")
                                .foregroundColor(themeService.currentTheme.textSecondary)
                            
                            Text(formattedTime)
                                .font(.subheadline)
                                .foregroundColor(themeService.currentTheme.text)
                        }
                        
                        if let durationText = formattedDuration {
                            HStack(spacing: 6) {
                                Image(systemName: "hourglass")
                                    .font(.caption)
                                    .foregroundColor(themeService.currentTheme.textSecondary)
                                
                                Text(durationText)
                                    .font(.caption)
                                    .foregroundColor(themeService.currentTheme.textSecondary)
                            }
                        }
                    }
                    
                    // Description Preview (if available)
                    if !exam.examDescription.isEmpty {
                        Text(exam.examDescription)
                            .font(.caption)
                            .foregroundColor(themeService.currentTheme.textSecondary)
                            .lineLimit(2)
                            .padding(.top, 2)
                    }
                }
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(themeService.currentTheme.textSecondary.opacity(0.5))
            }
        }
    }
}

#Preview {
    NavigationStack {
        AllExamsScreen()
            .environmentObject(ThemeService.shared)
            .modelContainer(for: [Exam.self, Subject.self])
    }
}
