//
//  EventCreationSheet.swift
//  benk
//
//  Created on 2025-12-15
//

import SwiftUI
import SwiftData

struct EventCreationSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeService: ThemeService
    
    @State private var title: String = ""
    @State private var location: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date().addingTimeInterval(3600) // 1 hour later
    @State private var isAllDay: Bool = false
    @State private var repeatOption: RepeatOption = .none
    @State private var notes: String = ""
    @State private var selectedColor: Color = .blue
    
    let colorOptions: [Color] = [
        .blue, .red, .green, .orange, .purple, .pink, .yellow, .cyan
    ]
    
    var canSave: Bool {
        !title.isEmpty
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                ThemedBackground(theme: themeService.currentTheme)
                
                Form {
                    Section("Event Details") {
                        TextField("Title", text: $title)
                        
                        TextField("Location (optional)", text: $location)
                    }
                    
                    Section("Date & Time") {
                        Toggle("All Day", isOn: $isAllDay)
                        
                        if isAllDay {
                            DatePicker("Date", selection: $startDate, displayedComponents: .date)
                        } else {
                            DatePicker("Starts", selection: $startDate)
                            DatePicker("Ends", selection: $endDate)
                        }
                    }
                    
                    Section("Repeat") {
                        Picker("Repeat", selection: $repeatOption) {
                            ForEach(RepeatOption.allCases, id: \.self) { option in
                                Text(option.displayName).tag(option)
                            }
                        }
                    }
                    
                    Section("Color") {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(colorOptions, id: \.self) { color in
                                    Button(action: {
                                        selectedColor = color
                                        HapticManager.shared.selection()
                                    }) {
                                        Circle()
                                            .fill(color)
                                            .frame(width: 40, height: 40)
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.white, lineWidth: selectedColor == color ? 3 : 0)
                                            )
                                            .shadow(radius: selectedColor == color ? 4 : 0)
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    
                    Section("Notes") {
                        TextEditor(text: $notes)
                            .frame(minHeight: 100)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("New Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveEvent()
                    }
                    .disabled(!canSave)
                }
            }
        }
    }
    
    private func saveEvent() {
        let event = Event(
            title: title,
            location: location,
            startTime: startDate,
            endTime: isAllDay ? Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: startDate) ?? startDate : endDate,
            isAllDay: isAllDay,
            repeatOption: repeatOption,
            notes: notes,
            colorHex: selectedColor.toHex() ?? "#007AFF"
        )
        
        CalendarService.shared.createEvent(event, context: modelContext)
        HapticManager.shared.success()
        dismiss()
    }
}

#Preview {
    EventCreationSheet()
        .environmentObject(ThemeService.shared)
        .modelContainer(for: [Event.self])
}
