//
//  CurrentNextEventWidget.swift
//  benk
//
//  Created on 2025-12-17
//

import SwiftUI
import SwiftData

struct CurrentNextEventWidget: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var themeService: ThemeService
    let isVisible: Bool
    
    @State private var animateEntry = false
    
    // Fetch events for the next 48 hours to find current/next
    var events: [Event] {
        let now = Date()
        // Start a bit before now to catch events currently in progress
        let start = now.addingTimeInterval(-24 * 3600) 
        let end = now.addingTimeInterval(48 * 3600)
        return CalendarService.shared.getEvents(from: start, to: end, context: modelContext)
    }
    
    var currentEvent: Event? {
        let now = Date()
        return events.first { event in
            event.startTime <= now && event.endTime > now
        }
    }
    
    var nextEvent: Event? {
        let now = Date()
        // First event that starts after now, excluding the current event if fetched
        return events
            .filter { $0.startTime > now }
            .sorted { $0.startTime < $1.startTime }
            .first
    }
    
    var body: some View {
        NavigationLink(destination: CalendarView(autoOpenToday: true)) {
            GlassCard(padding: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    // Header
                    HStack(spacing: 6) {
                        Image(systemName: "calendar")
                            .foregroundColor(themeService.currentTheme.accent)
                            .font(.callout)
                        
                        Text("Calendar")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(themeService.currentTheme.text)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption2)
                            .foregroundColor(themeService.currentTheme.textSecondary)
                    }
                    
                    if currentEvent == nil && nextEvent == nil {
                        emptyStateView
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            if let current = currentEvent {
                                currentEventRow(current)
                            }
                            
                            if let next = nextEvent {
                                if currentEvent != nil {
                                    Divider()
                                        .background(themeService.currentTheme.textSecondary.opacity(0.2))
                                }
                                nextEventRow(next)
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
            }
        }
    }
    
    // MARK: - Subviews
    
    private var emptyStateView: some View {
        HStack {
            Spacer()
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(themeService.currentTheme.textSecondary.opacity(0.1))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 20))
                        .foregroundColor(themeService.currentTheme.textSecondary.opacity(0.5))
                }
                .scaleEffect(animateEntry ? 1.0 : 0.8)
                .opacity(animateEntry ? 1.0 : 0.0)
                
                Text("No upcoming events")
                    .font(.caption)
                    .foregroundColor(themeService.currentTheme.textSecondary)
                    .opacity(animateEntry ? 1.0 : 0.0)
            }
            Spacer()
        }
        .frame(maxHeight: .infinity)
    }
    
    private func currentEventRow(_ event: Event) -> some View {
        HStack(alignment: .top, spacing: 10) {
            // Time strip indicator
            RoundedRectangle(cornerRadius: 2)
                .fill(event.color)
                .frame(width: 3)
                .frame(maxHeight: .infinity)
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text("NOW")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(
                            Capsule().fill(Color.red)
                        )
                    
                    Spacer()
                    
                    Text("Ends \(event.endTime.formatted(date: .omitted, time: .shortened))")
                        .font(.caption2)
                        .foregroundColor(themeService.currentTheme.textSecondary)
                }
                
                Text(event.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(themeService.currentTheme.text)
                    .lineLimit(1)
                
                if !event.location.isEmpty {
                    HStack(spacing: 3) {
                        Image(systemName: "location.fill")
                            .font(.caption2)
                            .scaleEffect(0.8)
                        Text(event.location)
                            .font(.caption2)
                    }
                    .foregroundColor(themeService.currentTheme.textSecondary)
                }
            }
        }
        .opacity(animateEntry ? 1.0 : 0.0)
        .offset(y: animateEntry ? 0 : 10)
    }
    
    private func nextEventRow(_ event: Event) -> some View {
        HStack(alignment: .top, spacing: 10) {
            // Time strip indicator
            RoundedRectangle(cornerRadius: 2)
                .fill(event.color.opacity(0.5))
                .frame(width: 3)
                .frame(maxHeight: .infinity)
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text("UP NEXT")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(themeService.currentTheme.accent)
                    
                    Spacer()
                    
                    Text(event.startTime.formatted(date: .omitted, time: .shortened))
                        .font(.caption2)
                        .foregroundColor(themeService.currentTheme.textSecondary)
                }
                
                Text(event.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(themeService.currentTheme.text)
                    .lineLimit(1)
                
                if !event.location.isEmpty {
                    HStack(spacing: 3) {
                        Image(systemName: "location.fill")
                            .font(.caption2)
                            .scaleEffect(0.8)
                        Text(event.location)
                            .font(.caption2)
                    }
                    .foregroundColor(themeService.currentTheme.textSecondary)
                }
            }
        }
        .opacity(animateEntry ? 1.0 : 0.0)
        .offset(y: animateEntry ? 0 : 10)
        .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1), value: animateEntry)
    }
}

#Preview {
    CurrentNextEventWidget(isVisible: true)
        .environmentObject(ThemeService.shared)
        .modelContainer(for: [Event.self])
        .padding()
        .background(Color.black)
}
