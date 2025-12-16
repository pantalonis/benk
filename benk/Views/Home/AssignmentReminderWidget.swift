//
//  AssignmentReminderWidget.swift
//  benk
//
//  Created on 2025-12-15
//

import SwiftUI
import SwiftData

struct AssignmentReminderWidget: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var themeService: ThemeService
    @Query private var subjects: [Subject]
    
    let isVisible: Bool
    @State private var animateEntry = false
    
    var upcomingAssignments: [Assignment] {
        CalendarService.shared.getUpcomingAssignments(limit: 2, context: modelContext)
    }
    
    var body: some View {
        NavigationLink(destination: AllAssignmentsScreen()) {
            GlassCard(padding: 8) {
                VStack(alignment: .leading, spacing: 6) {
                    // Header
                    HStack(spacing: 6) {
                        Image(systemName: "pencil")
                            .foregroundColor(themeService.currentTheme.accent)
                            .font(.callout)
                        
                        Text("Upcoming Assignments")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(themeService.currentTheme.text)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption2)
                            .foregroundColor(themeService.currentTheme.textSecondary)
                    }
                    
                    if upcomingAssignments.isEmpty {
                        // Empty state
                        HStack {
                            Spacer()
                            VStack(spacing: 8) {
                                Image(systemName: "checkmark.circle")
                                    .font(.largeTitle)
                                    .foregroundColor(themeService.currentTheme.textSecondary.opacity(0.5))
                                
                                Text("No pending assignments")
                                    .font(.subheadline)
                                    .foregroundColor(themeService.currentTheme.textSecondary)
                            }
                            .padding(.vertical, 16)
                            Spacer()
                        }
                        .opacity(animateEntry ? 1.0 : 0.0)
                        .scaleEffect(animateEntry ? 1.0 : 0.8)
                    } else {
                        // Assignment list
                        VStack(spacing: 8) {
                            ForEach(Array(upcomingAssignments.enumerated()), id: \.element.id) { index, assignment in
                                AssignmentRow(assignment: assignment, subjects: subjects)
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

}

struct AssignmentRow: View {
    let assignment: Assignment
    let subjects: [Subject]
    @EnvironmentObject var themeService: ThemeService
    
    var subject: Subject? {
        guard let subjectId = assignment.subjectId else { return nil }
        return subjects.first { $0.id == subjectId }
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: assignment.dueDate)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Subject color indicator
            RoundedRectangle(cornerRadius: 3)
                .fill(subject?.color ?? themeService.currentTheme.accent)
                .frame(width: 3)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(assignment.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(themeService.currentTheme.text)
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    Text(subject?.name ?? "Assignment")
                        .font(.caption)
                        .foregroundColor(themeService.currentTheme.textSecondary)
                    
                    Text("•")
                        .font(.caption)
                        .foregroundColor(themeService.currentTheme.textSecondary)
                    
                    Text(formattedDate)
                        .font(.caption)
                        .foregroundColor(themeService.currentTheme.textSecondary)
                }
            }
            
            Spacer()
            
            VStack(spacing: 4) {
                // Priority badge
                Text(assignment.priority.displayName.prefix(1))
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 20, height: 20)
                    .background(
                        Circle()
                            .fill(assignment.priority.color)
                    )
                
                // Days remaining
                Text(assignment.countdownText.replacingOccurrences(of: "Due ", with: ""))
                    .font(.caption2)
                    .foregroundColor(assignment.urgencyColor)
                    .lineLimit(1)
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill((subject?.color ?? themeService.currentTheme.accent).opacity(0.08))
        )
    }
}

#Preview {
    AssignmentReminderWidget(isVisible: true)
        .environmentObject(ThemeService.shared)
        .modelContainer(for: [Assignment.self, Subject.self])
        .padding()
}
