//
//  StoreView.swift
//  benk
//
//  Created on 2025-12-11
//

import SwiftUI
import SwiftData

struct StoreView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var themeService: ThemeService
    
    @Query private var userProfiles: [UserProfile]
    
    var userProfile: UserProfile {
        userProfiles.first ?? UserProfile()
    }
    
    var body: some View {
        ZStack {
            ThemedBackground(theme: themeService.currentTheme)
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header with coin balance
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "arrow.left")
                                .font(.title2.weight(.semibold))
                                .foregroundColor(themeService.currentTheme.text)
                                .frame(width: 44, height: 44)
                                .background(themeService.currentTheme.surface.opacity(0.5))
                                .clipShape(Circle())
                        }
                        
                        Text("Theme Store")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(themeService.currentTheme.text)
                        
                        Spacer()
                        
                        HStack(spacing: 8) {
                            Image(systemName: "dollarsign.circle.fill")
                                .foregroundColor(.yellow)
                            Text("\(CurrencyManager.shared.coins)")
                                .fontWeight(.bold)
                                .foregroundColor(themeService.currentTheme.text)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .glassCard()
                    }
                    .padding()
                    
                    // Theme Grid
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(themeService.allThemes, id: \.id) { theme in
                            ThemeStoreCard(theme: theme)
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 40)
                }
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
    
    @Environment(\.dismiss) private var dismiss
}

struct ThemeStoreCard: View {
    let theme: AppTheme
    
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var themeService: ThemeService
    @Query private var userProfiles: [UserProfile]
    
    @State private var showPurchaseAlert = false
    
    var userProfile: UserProfile {
        userProfiles.first ?? UserProfile()
    }
    
    var isOwned: Bool {
        themeService.isThemeOwned(theme.id, profile: userProfile)
    }
    
    var body: some View {
        GlassCard {
            VStack(spacing: 12) {
                // Theme preview
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(theme.background)
                        .frame(height: 120)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(theme.accent, lineWidth: 2)
                        )
                    
                    if isOwned {
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.white)
                                    .font(.title3)
                                    .padding(8)
                                    .background(Circle().fill(Color.green))
                                    .padding(8)
                            }
                        }
                    }
                }
                
                Text(theme.name)
                    .font(.headline)
                    .foregroundColor(themeService.currentTheme.text)
                
                if isOwned {
                    Button(action: {
                        themeService.applyTheme(theme)
                    }) {
                        Text("Use Theme")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(themeService.currentTheme.accent)
                            )
                    }
                } else {
                    Button(action: {
                        purchaseTheme()
                    }) {
                        HStack {
                            Text("\(theme.price)")
                            Image(systemName: "dollarsign.circle.fill")
                        }
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(CurrencyManager.shared.coins >= theme.price ? themeService.currentTheme.primary : Color.gray)
                        )
                    }
                    .disabled(CurrencyManager.shared.coins < theme.price)
                }
            }
        }
    }
    
    private func purchaseTheme() {
        let success = themeService.purchaseTheme(theme, profile: userProfile, context: modelContext)
        if success {
            themeService.applyTheme(theme)
        }
    }
}

#Preview {
    NavigationStack {
        StoreView()
            .modelContainer(for: [UserProfile.self])
            .environmentObject(ThemeService.shared)
    }
}
