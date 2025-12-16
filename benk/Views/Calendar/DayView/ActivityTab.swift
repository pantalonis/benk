//
//  ActivityTab.swift
//  benk
//
//  Created on 2025-12-15
//

import SwiftUI
import SwiftData

struct ActivityTab: View {
    let selectedDate: Date
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var themeService: ThemeService
    @Query private var completedSessions: [StudySession]
    
    var sessionsForDay: [StudySession] {
        let calendar = Calendar.current
        let dayStart = calendar.startOfDay(for: selectedDate)
        guard let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) else { return [] }
        
        return completedSessions.filter { session in
            session.isCompleted && session.timestamp >= dayStart && session.timestamp < dayEnd
        }.sorted { $0.timestamp < $1.timestamp }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            if sessionsForDay.isEmpty {
                emptyState
            } else {
                timeline
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "clock")
                .font(.system(size: 48))
                .foregroundColor(themeService.currentTheme.textSecondary.opacity(0.5))
            
            Text("No study sessions today")
                .font(.headline)
                .foregroundColor(themeService.currentTheme.text)
            
            Text("Start studying to see your activity here")
                .font(.subheadline)
                .foregroundColor(themeService.currentTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
    
    private var timeline: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(sessionsForDay) { session in
                HStack(alignment: .top, spacing: 16) {
                    // Time label
                    Text(formatTime(session.timestamp))
                        .font(.caption)
                        .foregroundColor(themeService.currentTheme.textSecondary)
                        .frame(width: 50, alignment: .trailing)
                    
                    // Session block
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(themeService.currentTheme.primary)
                                .frame(width: 8, height: 8)
                            
                            Text(formatDuration(session.duration))
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(themeService.currentTheme.text)
                        }
                        
                        Text("\(session.xpEarned) XP earned")
                            .font(.caption)
                            .foregroundColor(themeService.currentTheme.textSecondary)
                    }
                    .padding(.vertical, 8)
                    
                    Spacer()
                }
                .padding(.vertical, 4)
            }
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
    
    private func formatDuration(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        
        if hours > 0 {
            return "\(hours)h \(remainingMinutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

#Preview {
    ActivityTab(selectedDate: Date())
        .environmentObject(ThemeService.shared)
        .modelContainer(for: [StudySession.self])
}
