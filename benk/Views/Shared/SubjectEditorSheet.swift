//
//  SubjectEditorSheet.swift
//  benk
//
//  Created on 2025-12-12
//

import SwiftUI
import SwiftData

struct SubjectEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var themeService: ThemeService
    
    let subject: Subject?  // nil for new subject
    
    @State private var name: String = ""
    @State private var selectedIcon: String = "book.fill"
    @State private var selectedColorHex: String = "#3B82F6"
    
    // Available icons for subjects
    private let availableIcons = [
        "book.fill", "book.closed.fill", "books.vertical.fill", "text.book.closed.fill",
        "pencil", "pencil.circle.fill", "highlighter",
        "graduationcap.fill", "brain.head.profile", "lightbulb.fill",
        "atom", "function", "sum", "x.squareroot",
        "flask.fill", "testtube.2", "scope",
        "globe", "map.fill", "building.columns.fill",
        "paintbrush.fill", "music.note", "theatermasks.fill",
        "dumbbell.fill", "sportscourt.fill", "figure.run",
        "laptopcomputer", "desktopcomputer", "iphone",
        "gear", "wrench.and.screwdriver.fill", "hammer.fill"
    ]
    
    // Preset colors
    private let presetColors: [(name: String, hex: String)] = [
        ("Blue", "#3B82F6"),
        ("Purple", "#A855F7"),
        ("Pink", "#EC4899"),
        ("Red", "#EF4444"),
        ("Orange", "#F97316"),
        ("Yellow", "#EAB308"),
        ("Green", "#10B981"),
        ("Teal", "#14B8A6"),
        ("Cyan", "#06B6D4"),
        ("Indigo", "#6366F1")
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                themeService.currentTheme.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Name Input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Name")
                                .font(.headline)
                                .foregroundColor(themeService.currentTheme.text)
                            
                            TextField("Subject name", text: $name)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(themeService.currentTheme.surface.opacity(0.3))
                                )
                                .foregroundColor(themeService.currentTheme.text)
                        }
                        .padding(.horizontal)
                        
                        // Preview
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Preview")
                                .font(.headline)
                                .foregroundColor(themeService.currentTheme.text)
                            
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(Color(hex: selectedColorHex)?.opacity(0.2) ?? .blue.opacity(0.2))
                                        .frame(width: 60, height: 60)
                                    
                                    Image(systemName: selectedIcon)
                                        .font(.title)
                                        .foregroundColor(Color(hex: selectedColorHex) ?? .blue)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(name.isEmpty ? "Subject Name" : name)
                                        .font(.headline)
                                        .foregroundColor(themeService.currentTheme.text)
                                    
                                    Text("0m studied")
                                        .font(.subheadline)
                                        .foregroundColor(themeService.currentTheme.textSecondary)
                                }
                                
                                Spacer()
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.ultraThinMaterial)
                            )
                        }
                        .padding(.horizontal)
                        
                        // Icon Picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Icon")
                                .font(.headline)
                                .foregroundColor(themeService.currentTheme.text)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 6), spacing: 12) {
                                ForEach(availableIcons, id: \.self) { icon in
                                    Button(action: {
                                        selectedIcon = icon
                                        HapticManager.shared.selection()
                                    }) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(selectedIcon == icon ?
                                                      themeService.currentTheme.accent.opacity(0.2) :
                                                      themeService.currentTheme.surface.opacity(0.2))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(
                                                            selectedIcon == icon ?
                                                            themeService.currentTheme.accent :
                                                            Color.clear,
                                                            lineWidth: 2
                                                        )
                                                )
                                            
                                            Image(systemName: icon)
                                                .font(.title3)
                                                .foregroundColor(
                                                    selectedIcon == icon ?
                                                    themeService.currentTheme.accent :
                                                    themeService.currentTheme.text
                                                )
                                        }
                                        .frame(height: 50)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Color Picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Color")
                                .font(.headline)
                                .foregroundColor(themeService.currentTheme.text)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 5), spacing: 12) {
                                ForEach(presetColors, id: \.hex) { colorOption in
                                    Button(action: {
                                        selectedColorHex = colorOption.hex
                                        HapticManager.shared.selection()
                                    }) {
                                        ZStack {
                                            Circle()
                                                .fill(Color(hex: colorOption.hex) ?? .blue)
                                                .frame(height: 50)
                                            
                                            if selectedColorHex == colorOption.hex {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .font(.title2)
                                                    .foregroundColor(.white)
                                                    .shadow(radius: 2)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle(subject == nil ? "New Subject" : "Edit Subject")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(themeService.currentTheme.text)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveSubject()
                    }
                    .foregroundColor(themeService.currentTheme.accent)
                    .disabled(name.isEmpty)
                }
            }
            .onAppear {
                if let subject = subject {
                    // Editing existing subject
                    name = subject.name
                    selectedIcon = subject.iconName
                    selectedColorHex = subject.colorHex
                }
            }
        }
    }
    
    private func saveSubject() {
        if let existingSubject = subject {
            // Update existing subject
            existingSubject.name = name
            existingSubject.iconName = selectedIcon
            existingSubject.colorHex = selectedColorHex
        } else {
            // Create new subject
            let newSubject = Subject(
                name: name,
                colorHex: selectedColorHex,
                iconName: selectedIcon
            )
            modelContext.insert(newSubject)
        }
        
        HapticManager.shared.success()
        dismiss()
    }
}

#Preview {
    SubjectEditorSheet(subject: nil)
        .modelContainer(for: Subject.self)
        .environmentObject(ThemeService.shared)
}
