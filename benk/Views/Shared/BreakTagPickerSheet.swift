//
//  BreakTagPickerSheet.swift
//  benk
//
//  Created on 2025-12-13
//

import SwiftUI

struct BreakTagPickerSheet: View {
    let breakDuration: Int
    let onLog: (String) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeService: ThemeService
    @State private var customTagText: String = ""
    @FocusState private var isFocused: Bool
    
    private let defaultTags = ["meals", "bathroom", "rest", "other"]
    
    private var formattedDuration: String {
        let minutes = breakDuration / 60
        let seconds = breakDuration % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var body: some View {
        ZStack {
            themeService.currentTheme.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom Glass Header
                HStack {
                    Button(action: { dismiss() }) {
                        Text("Discard")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(themeService.currentTheme.textSecondary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        Capsule()
                                            .stroke(themeService.currentTheme.textSecondary.opacity(0.2), lineWidth: 1)
                                    )
                            )
                    }
                    
                    Spacer()
                    
                    Text("Log Break")
                        .font(.headline)
                        .foregroundColor(themeService.currentTheme.text)
                    
                    Spacer()
                    
                    // Invisible spacer for symmetry
                     Text("Discard")
                         .font(.subheadline)
                         .fontWeight(.medium)
                         .foregroundColor(.clear)
                         .padding(.horizontal, 16)
                         .padding(.vertical, 8)
                         .opacity(0)
                }
                .padding()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header Content
                        VStack(spacing: 8) {
                            Text("Break Time")
                                .font(.headline)
                                .foregroundColor(themeService.currentTheme.textSecondary)
                            
                            Text(formattedDuration)
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundColor(themeService.currentTheme.text)
                        }
                        .padding(.top, 16)
                        
                        // Tag Input
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Log Activity")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(themeService.currentTheme.textSecondary)
                                .padding(.horizontal)
                            
                            // Custom Tag Input
                            HStack(spacing: 4) {
                                Text("#")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(themeService.currentTheme.accent)
                                
                                TextField("custom-tag", text: $customTagText)
                                    .font(.title3)
                                    .foregroundColor(themeService.currentTheme.text)
                                    .submitLabel(.done)
                                    .focused($isFocused)
                                    .onSubmit {
                                        if !customTagText.isEmpty {
                                            logTag(customTagText)
                                        }
                                    }
                                
                                if !customTagText.isEmpty {
                                    Button(action: {
                                        logTag(customTagText)
                                    }) {
                                        Image(systemName: "arrow.up.circle.fill")
                                            .font(.title2)
                                            .foregroundColor(themeService.currentTheme.accent)
                                    }
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(themeService.currentTheme.primary.opacity(0.3), lineWidth: 1)
                                    )
                            )
                            .padding(.horizontal)
                            
                            // Quick Tags Grid
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                ForEach(defaultTags, id: \.self) { tag in
                                    Button(action: {
                                        logTag(tag)
                                    }) {
                                        HStack {
                                            Text("#")
                                                .fontWeight(.bold)
                                                .foregroundColor(themeService.currentTheme.accent)
                                            Text(tag)
                                                .fontWeight(.medium)
                                                .foregroundColor(themeService.currentTheme.text)
                                            Spacer()
                                        }
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(.ultraThinMaterial)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(themeService.currentTheme.primary.opacity(0.2), lineWidth: 1)
                                                )
                                        )
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        Spacer()
                    }
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .onAppear {
            isFocused = true
        }
    }
    
    private func logTag(_ tag: String) {
        let cleanTag = tag.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
        let finalTag = "#\(cleanTag)"
        
        onLog(finalTag)
        dismiss()
        HapticManager.shared.success()
    }
}

#Preview {
    BreakTagPickerSheet(breakDuration: 305) { tag in
        print("Logged: \(tag)")
    }
    .environmentObject(ThemeService.shared)
}
