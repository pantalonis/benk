//
//  TechniquePickerSheet.swift
//  benk
//
//  Created on 2025-12-13
//

import SwiftUI
import SwiftData

struct TechniquePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var themeService: ThemeService
    
    @Query(sort: \Technique.category) private var allTechniques: [Technique]
    
    let onSelect: (Technique) -> Void
    
    @State private var searchText = ""
    
    var filteredTechniques: [Technique] {
        if searchText.isEmpty {
            return allTechniques
        }
        return allTechniques.filter { technique in
            technique.name.localizedCaseInsensitiveContains(searchText) ||
            technique.category.localizedCaseInsensitiveContains(searchText) ||
            technique.techniqueDescription.localizedCaseInsensitiveContains(searchText) ||
            (technique.subcategory?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }
    
    var groupedTechniques: [(String, [Technique])] {
        let grouped = Dictionary(grouping: filteredTechniques, by: { $0.category })
        return grouped.sorted { $0.key < $1.key }.map { ($0.key, $0.value.sorted { $0.name < $1.name }) }
    }
    
    var body: some View {
        ZStack {
            themeService.currentTheme.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom Glass Header
                HStack {
                    // Invisible spacer for symmetry
                     Text("Skip")
                         .font(.subheadline)
                         .fontWeight(.medium)
                         .foregroundColor(.clear)
                         .padding(.horizontal, 16)
                         .padding(.vertical, 8)
                         .opacity(0)
                    
                    Spacer()
                    
                    Text("Select Study Technique")
                        .font(.headline)
                        .foregroundColor(themeService.currentTheme.text)
                    
                    Spacer()
                     
                    Button(action: { dismiss() }) {
                        Text("Skip")
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
                }
                .padding()
                .background(
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .ignoresSafeArea()
                )
                
                VStack(spacing: 0) {
                    searchBar
                    techniquesList
                }
            }
        }
        .onAppear {
            // Seed techniques if needed
            StudyTechniqueDatabase.seedTechniques(context: modelContext)
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(themeService.currentTheme.textSecondary)
            
            TextField("Search techniques...", text: $searchText)
                .foregroundColor(themeService.currentTheme.text)
                .autocorrectionDisabled()
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(themeService.currentTheme.textSecondary)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(themeService.currentTheme.primary.opacity(0.3), lineWidth: 1)
                )
        )
        .padding()
    }
    
    @ViewBuilder
    private var techniquesList: some View {
        if filteredTechniques.isEmpty {
            emptyState
        } else {
            techniquesScrollView
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(themeService.currentTheme.textSecondary.opacity(0.5))
            
            Text("No techniques found")
                .font(.headline)
                .foregroundColor(themeService.currentTheme.text)
            
            Text("Try a different search term")
                .font(.subheadline)
                .foregroundColor(themeService.currentTheme.textSecondary)
        }
        .frame(maxHeight: .infinity)
    }
    
    private var techniquesScrollView: some View {
        ScrollView {
            LazyVStack(spacing: 16, pinnedViews: [.sectionHeaders]) {
                ForEach(groupedTechniques, id: \.0) { category, techniques in
                    Section {
                        ForEach(techniques) { technique in
                            TechniqueRow(
                                technique: technique,
                                onSelect: {
                                    onSelect(technique)
                                    dismiss()
                                    HapticManager.shared.selection()
                                }
                            )
                        }
                    } header: {
                        categoryHeader(category)
                    }
                }
            }
            .padding(.bottom)
            .padding(.top, 8)
        }
        .mask(
            VStack(spacing: 0) {
                // Top fade
                LinearGradient(
                    colors: [.clear, .black],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 20)
                
                // Solid content area
                Rectangle()
                    .fill(.black)
            }
        )
    }
    
    private func categoryHeader(_ category: String) -> some View {
        ZStack {
            // Liquid glass background
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    LinearGradient(
                        colors: [
                            themeService.currentTheme.primary.opacity(0.1),
                            themeService.currentTheme.accent.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    themeService.currentTheme.primary.opacity(0.3),
                                    themeService.currentTheme.accent.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: themeService.currentTheme.glow.opacity(0.15), radius: 8, x: 0, y: 4)
            
            // Category text
            HStack {
                Text(category)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                themeService.currentTheme.text,
                                themeService.currentTheme.text.opacity(0.8)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                
                Spacer()
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}



struct TechniqueRow: View {
    let technique: Technique
    let onSelect: () -> Void
    
    @EnvironmentObject var themeService: ThemeService
    
    var effectivenessStars: String {
        String(repeating: "⭐", count: min(technique.effectivenessRating / 2, 5))
    }
    
    var body: some View {
        Button(action: onSelect) {
            HStack(alignment: .top, spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(themeService.currentTheme.primary.opacity(0.2))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: technique.iconName)
                        .font(.title3)
                        .foregroundColor(themeService.currentTheme.primary)
                }
                
                // Info
                VStack(alignment: .leading, spacing: 6) {
                    // Name and Category Badge
                    HStack(spacing: 8) {
                        Text(technique.name)
                            .font(.headline)
                            .foregroundColor(themeService.currentTheme.text)
                        
                        if let subcategory = technique.subcategory {
                            Text(subcategory)
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(themeService.currentTheme.accent)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(themeService.currentTheme.accent.opacity(0.2))
                                )
                        }
                    }
                    
                    // Description
                    Text(technique.techniqueDescription)
                        .font(.subheadline)
                        .foregroundColor(themeService.currentTheme.textSecondary)
                        .lineLimit(2)
                    
                    // Effectiveness Rating
                    HStack(spacing: 4) {
                        Text(effectivenessStars)
                            .font(.caption)
                        
                        Text("(\(technique.effectivenessRating)/10)")
                            .font(.caption2)
                            .foregroundColor(themeService.currentTheme.textSecondary)
                    }
                }
                
                Spacer()
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(themeService.currentTheme.textSecondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                themeService.currentTheme.primary.opacity(0.2),
                                lineWidth: 1
                            )
                    )
            )
            .shadow(color: themeService.currentTheme.glow.opacity(0.1), radius: 6, x: 0, y: 3)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal)
    }
}

#Preview {
    TechniquePickerSheet { technique in
        print("Selected: \(technique.name)")
    }
    .modelContainer(for: Technique.self)
    .environmentObject(ThemeService.shared)
}
