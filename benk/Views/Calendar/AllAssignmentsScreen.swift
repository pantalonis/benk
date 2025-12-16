//
//  AllAssignmentsScreen.swift
//  benk
//
//  Created on 2025-12-15
//

import SwiftUI
import SwiftData

struct AllAssignmentsScreen: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var themeService: ThemeService
    @Query private var subjects: [Subject]
    
    @State private var filterStatus: AssignmentStatus? = nil
    
    var allAssignments: [Assignment] {
        CalendarService.shared.getUpcomingAssignments(context: modelContext)
    }
    
    var filteredAssignments: [Assignment] {
        if let status = filterStatus {
            return allAssignments.filter { $0.status == status }
        }
        return allAssignments
    }
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            ThemedBackground(theme: themeService.currentTheme)
            
            VStack(spacing: 0) {
                // Custom Header
                header
                
                // Filter Segmented Control Replacement
                filterSection
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        if filteredAssignments.isEmpty {
                            emptyState
                        } else {
                            assignmentsList
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
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
            
            Text("All Assignments")
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
    
    // MARK: - Filter Section (Glass Pills)
    private var filterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                Text("Show:")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(themeService.currentTheme.textSecondary)
                    .padding(.leading, 16)
                
                // "All" Option
                GlassSortPill(
                    title: "All",
                    isSelected: filterStatus == nil,
                    action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            filterStatus = nil
                        }
                        HapticManager.shared.selection()
                    }
                )
                
                // Status Options
                ForEach(AssignmentStatus.allCases, id: \.self) { status in
                    GlassSortPill(
                        title: status.displayName,
                        isSelected: filterStatus == status,
                        action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                filterStatus = status
                            }
                            HapticManager.shared.selection()
                        }
                    )
                }
            }
            .padding(.vertical, 12)
            .padding(.trailing, 16)
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "pencil")
                .font(.system(size: 64))
                .foregroundColor(themeService.currentTheme.textSecondary.opacity(0.5))
                .padding(.top, 60)
            
            Text(filterStatus == nil ? "No Assignments" : "No \(filterStatus!.displayName) Assignments")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(themeService.currentTheme.text)
            
            Text("You're all caught up!")
                .font(.subheadline)
                .foregroundColor(themeService.currentTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var assignmentsList: some View {
        VStack(spacing: 12) {
            ForEach(filteredAssignments) { assignment in
                AssignmentDetailCard(assignment: assignment, subjects: subjects)
            }
        }
    }
}

struct AssignmentDetailCard: View {
    let assignment: Assignment
    let subjects: [Subject]
    @EnvironmentObject var themeService: ThemeService
    
    var subject: Subject? {
        guard let subjectId = assignment.subjectId else { return nil }
        return subjects.first { $0.id == subjectId }
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter.string(from: assignment.dueDate)
    }
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: assignment.dueDate)
    }
    
    var body: some View {
        GlassCard(padding: 16) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    // Subject and title
                    HStack(spacing: 10) {
                        Circle()
                            .fill(subject?.color ?? themeService.currentTheme.accent)
                            .frame(width: 12, height: 12)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(assignment.title)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(themeService.currentTheme.text)
                            
                            Text(subject?.name ?? "Assignment")
                                .font(.caption)
                                .foregroundColor(themeService.currentTheme.textSecondary)
                        }
                    }
                    
                    Spacer()
                    
                    // Priority badge
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(assignment.priority.displayName)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(assignment.priority.color)
                            )
                        
                        Text(assignment.countdownText)
                            .font(.caption2)
                            .foregroundColor(assignment.urgencyColor)
                    }
                }
                
                Divider()
                
                // Details
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "calendar")
                            .foregroundColor(themeService.currentTheme.textSecondary)
                            .font(.caption)
                        
                        Text("Due: \(formattedDate)")
                            .font(.subheadline)
                            .foregroundColor(themeService.currentTheme.text)
                    }
                    
                    HStack(spacing: 8) {
                        Image(systemName: "hourglass")
                            .foregroundColor(themeService.currentTheme.textSecondary)
                            .font(.caption)
                        
                        Text("Estimated: \(String(format: "%.1f", assignment.estimatedEffortHours))h")
                            .font(.subheadline)
                            .foregroundColor(themeService.currentTheme.text)
                    }
                    
                    HStack(spacing: 8) {
                        Image(systemName: assignment.status.icon)
                            .foregroundColor(assignment.status == .completed ? .green : themeService.currentTheme.textSecondary)
                            .font(.caption)
                        
                        Text("Status: \(assignment.status.displayName)")
                            .font(.subheadline)
                            .foregroundColor(themeService.currentTheme.text)
                    }
                }
                
                // Notes (if available)
                if !assignment.notes.isEmpty {
                    Text(assignment.notes)
                        .font(.caption)
                        .foregroundColor(themeService.currentTheme.textSecondary)
                        .padding(.top, 4)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        AllAssignmentsScreen()
            .environmentObject(ThemeService.shared)
            .modelContainer(for: [Assignment.self, Subject.self])
    }
}
