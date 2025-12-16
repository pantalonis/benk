//
//  DayDetailSheet.swift
//  benk
//
//  Created on 2025-12-15
//

import SwiftUI

struct DayDetailSheet: View {
    @Binding var selectedDate: Date
    @Binding var isPresented: Bool
    @EnvironmentObject var themeService: ThemeService
    
    @State private var dragOffset: CGFloat = 0
    @State private var zoomLevel: CGFloat = 1.0 // 1.0 = 80pt/hour, 1.5 = 120pt, 2.0 = 160pt
    @State private var showingActionMenu = false
    @State private var showingEventCreation = false
    @State private var showingExamCreation = false
    @State private var showingAssignmentCreation = false
    @State private var showingAnalytics = false
    
    /// Track which timeline item is in edit mode (passed from DayTimelineView)
    @State private var editingItemId: UUID? = nil
    
    /// Whether dismiss gesture should be disabled (when editing a timeline event)
    private var isDismissDisabled: Bool {
        editingItemId != nil
    }
    
    var selectedDateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter.string(from: selectedDate)
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    // Pull-down handle - ONLY this area can dismiss the sheet
                    VStack(spacing: 0) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(themeService.currentTheme.textSecondary.opacity(0.3))
                            .frame(width: 40, height: 6)
                            .padding(.top, 8)
                            .padding(.bottom, 12)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                if value.translation.height > 0 {
                                    dragOffset = value.translation.height
                                }
                            }
                            .onEnded { value in
                                if value.translation.height > 150 {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                        isPresented = false
                                    }
                                    HapticManager.shared.success()
                                    dragOffset = 0
                                } else {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        dragOffset = 0
                                    }
                                }
                            }
                    )
                    
                    // Date header with zoom controls
                    HStack {
                        Text(selectedDateText)
                            .font(.headline)
                            .foregroundColor(themeService.currentTheme.text)
                        
                        Spacer()
                        
                        // Zoom controls
                        HStack(spacing: 12) {
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    zoomLevel = max(0.5, zoomLevel - 0.5)
                                }
                                HapticManager.shared.selection()
                            }) {
                                Image(systemName: "minus.magnifyingglass")
                                    .font(.system(size: 16))
                                    .foregroundColor(themeService.currentTheme.text)
                                    .frame(width: 32, height: 32)
                                    .background(
                                        Circle()
                                            .fill(themeService.currentTheme.textSecondary.opacity(0.1))
                                    )
                            }
                            .disabled(zoomLevel <= 0.5)
                            
                            Text("\(Int(zoomLevel * 100))%")
                                .font(.caption)
                                .foregroundColor(themeService.currentTheme.textSecondary)
                                .frame(width: 50)
                            
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    zoomLevel = min(5.0, zoomLevel + 0.5)
                                }
                                HapticManager.shared.selection()
                            }) {
                                Image(systemName: "plus.magnifyingglass")
                                    .font(.system(size: 16))
                                    .foregroundColor(themeService.currentTheme.text)
                                    .frame(width: 32, height: 32)
                                    .background(
                                        Circle()
                                            .fill(themeService.currentTheme.textSecondary.opacity(0.1))
                                    )
                            }
                            .disabled(zoomLevel >= 5.0)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 12)
                    
                    // 5-Week Calendar Bar
                    CalendarBar(selectedDate: $selectedDate)
                        .padding(.bottom, 8)
                    
                    Divider()
                    
                    // Timeline view with zoom and edit mode tracking
                    DayTimelineView(selectedDate: selectedDate, zoomLevel: $zoomLevel, editingItemId: $editingItemId)
                        .padding(.top, 8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    ThemedBackground(theme: themeService.currentTheme)
                        .ignoresSafeArea()
                )
                .cornerRadius(20, corners: [.topLeft, .topRight])
                .offset(y: max(0, dragOffset))
            }
            .ignoresSafeArea(.all, edges: .bottom)
            
            // Floating Action Menu - Bottom Right
            VStack(spacing: 16) {
                // Action Buttons (appear above X button when menu is open)
                if showingActionMenu {
                    VStack(spacing: 12) {
                        DayActionButton(
                            icon: "calendar.badge.plus",
                            label: "Add Event",
                            color: .blue,
                            themeService: themeService
                        ) {
                            showingEventCreation = true
                            showingActionMenu = false
                        }
                        
                        DayActionButton(
                            icon: "doc.text.fill",
                            label: "Add Exam",
                            color: .red,
                            themeService: themeService
                        ) {
                            showingExamCreation = true
                            showingActionMenu = false
                        }
                        
                        DayActionButton(
                            icon: "checkmark.square.fill",
                            label: "Assignment",
                            color: .orange,
                            themeService: themeService
                        ) {
                            showingAssignmentCreation = true
                            showingActionMenu = false
                        }
                        
                        DayActionButton(
                            icon: "chart.bar.fill",
                            label: "Analytics",
                            color: .purple,
                            themeService: themeService
                        ) {
                            showingAnalytics = true
                            showingActionMenu = false
                        }
                    }
                    .frame(width: 220)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                // Main FAB button - X when open, + when closed - STAYS IN SAME SPOT
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        showingActionMenu.toggle()
                    }
                    HapticManager.shared.medium()
                }) {
                    ZStack {
                        Circle()
                            .fill(themeService.currentTheme.primary)
                            .frame(width: 64, height: 64)
                            .shadow(color: themeService.currentTheme.primary.opacity(0.4), radius: 12, x: 0, y: 6)
                        
                        Image(systemName: showingActionMenu ? "xmark" : "plus")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                            .rotationEffect(.degrees(showingActionMenu ? 90 : 0))
                    }
                }
            }
            .padding(.trailing, 20)
            .padding(.bottom, 30)
        }
        .sheet(isPresented: $showingEventCreation) {
            EventCreationSheet()
        }
        .sheet(isPresented: $showingExamCreation) {
            ExamFormSheet()
        }
        .sheet(isPresented: $showingAssignmentCreation) {
            AssignmentCreationSheet()
        }
    }
}

// MARK: - Day Action Button (Full Width Rectangle)
struct DayActionButton: View {
    let icon: String
    let label: String
    let color: Color
    let themeService: ThemeService
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            HapticManager.shared.selection()
            action()
        }) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                
                Text(label)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(themeService.currentTheme.text)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            )
            .overlay(
                Capsule()
                    .stroke(
                        LinearGradient(
                            colors: [
                                color.opacity(0.6),
                                color.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Action Box Component (Legacy - for reference)
struct ActionBox: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    @EnvironmentObject var themeService: ThemeService
    
    var body: some View {
        Button(action: {
            HapticManager.shared.selection()
            action()
        }) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(themeService.currentTheme.text)
            }
            .frame(width: 100, height: 100)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

// MARK: - Corner Radius Extension
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    DayDetailSheet(
        selectedDate: .constant(Date()),
        isPresented: .constant(true)
    )
    .environmentObject(ThemeService.shared)
}
