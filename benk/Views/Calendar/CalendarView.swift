//
//  CalendarView.swift
//  benk
//
//  Created on 2025-12-15
//

import SwiftUI
import SwiftData

struct CalendarView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeService: ThemeService
    @StateObject private var viewModel = CalendarViewModel()
    
    @State private var showingDayDetail = false
    
    var autoOpenToday: Bool = false
    
    var body: some View {
        ZStack {
            ThemedBackground(theme: themeService.currentTheme)
            
            ZStack(alignment: .top) {
                // Month View (main content/background layer)
                MonthView(
                    viewModel: viewModel,
                    showingDayDetail: $showingDayDetail,
                    contentTopPadding: 70 // Space for transparent header
                )
                
                // Header with custom back button and transparent background
                header
                    .background(Color.clear) // Transparent
            }
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showingDayDetail) {
            DayDetailSheet(
                selectedDate: $viewModel.selectedDate,
                isPresented: $showingDayDetail
            )
            .presentationDetents([.fraction(0.99)])
            .presentationDragIndicator(.hidden)
            .presentationBackground(.clear)
        }
        .onAppear {
            if autoOpenToday {
                // Slight delay to ensure view is ready
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    viewModel.goToToday()
                    showingDayDetail = true
                }
            }
        }
    }
    
    private var header: some View {
        HStack {
            // Custom back button
            Button(action: {
                dismiss()
                HapticManager.shared.selection()
            }) {
                ZStack {
                    Circle()
                        .fill(themeService.currentTheme.primary.opacity(0.3))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "chevron.left")
                        .foregroundColor(themeService.currentTheme.primary)
                        .font(.system(size: 18, weight: .semibold))
                }
            }
            
            Spacer()
            
            Text("Calendar")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(themeService.currentTheme.text)
            
            Spacer()
            
            // Today button
            Button(action: {
                viewModel.goToToday()
                HapticManager.shared.selection()
            }) {
                Text("Today")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(themeService.currentTheme.primary)
                    .padding(.horizontal, 12)
                    .padding (.vertical, 8)
                    .background(
                        Capsule()
                            .fill(themeService.currentTheme.primary.opacity(0.15))
                    )
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }
}

#Preview {
    NavigationStack {
        CalendarView()
            .modelContainer(for: [Event.self, Exam.self, Assignment.self])
            .environmentObject(ThemeService.shared)
    }
}
