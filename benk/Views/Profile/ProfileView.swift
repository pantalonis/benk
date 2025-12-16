//
//  ProfileView.swift
//  benk
//
//  Created on 2025-12-11
//

import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var themeService: ThemeService
    
    @Query private var userProfiles: [UserProfile]
    @Query(filter: #Predicate<StudySession> { $0.isCompleted })
    private var completedSessions: [StudySession]
    @Query(filter: #Predicate<Badge> { $0.isEarned }) 
    private var earnedBadges: [Badge]
    @Query private var allBadges: [Badge]
    
    @State private var showEditProfile = false
    
    var userProfile: UserProfile {
        userProfiles.first ?? UserProfile()
    }
    
    /// Get the user's selected title badge if one is equipped
    var selectedTitleBadge: Badge? {
        guard let badgeId = userProfile.selectedTitleBadgeId else { return nil }
        return allBadges.first { $0.id == badgeId && $0.isEarned }
    }
    
    var totalStudyTime: Int {
        completedSessions.reduce(0) { $0 + $1.duration }
    }
    
    var body: some View {
        ZStack {
            ThemedBackground(theme: themeService.currentTheme)
            
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            themeService.currentTheme.primary,
                                            themeService.currentTheme.accent
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 100, height: 100)
                            
                            Text(String(userProfile.username.prefix(1)).uppercased())
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .glowEffect(color: themeService.currentTheme.glow, radius: 20, opacity: 0.6)
                        
                        Text(userProfile.username)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(themeService.currentTheme.text)
                        
                        // Title dropdown (styled larger for profile)
                        TitleDropdownLarge(
                            selectedBadge: selectedTitleBadge,
                            earnedBadges: Array(earnedBadges),
                            onSelect: { badgeId in
                                userProfile.selectedTitleBadgeId = badgeId
                                try? modelContext.save()
                                HapticManager.shared.selection()
                            }
                        )
                        
                        // Level tier shown below
                        Text(LevelTier.name(for: userProfile.level))
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(LevelTier.color(for: userProfile.level))
                        
                        HStack(spacing: 16) {
                            VStack(spacing: 4) {
                                Text("Lvl \(userProfile.level)")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(LevelTier.color(for: userProfile.level))
                                Text("LEVEL")
                                    .font(.caption2)
                                    .foregroundColor(themeService.currentTheme.textSecondary)
                            }
                            
                            Divider()
                                .frame(height: 36)
                            
                            VStack(spacing: 4) {
                                Text("\(userProfile.xp)")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(themeService.currentTheme.accent)
                                Text("XP")
                                    .font(.caption2)
                                    .foregroundColor(themeService.currentTheme.textSecondary)
                            }
                            
                            Divider()
                                .frame(height: 36)
                            
                            VStack(spacing: 4) {
                                Text("\(userProfile.currentStreak)")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(StreakMilestone.color(for: userProfile.currentStreak))
                                Text("STREAK")
                                    .font(.caption2)
                                    .foregroundColor(themeService.currentTheme.textSecondary)
                            }
                            
                            Divider()
                                .frame(height: 36)
                            
                            VStack(spacing: 4) {
                                Text("\(CurrencyManager.shared.coins)")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.yellow)
                                Text("COINS")
                                    .font(.caption2)
                                    .foregroundColor(themeService.currentTheme.textSecondary)
                            }
                        }
                        .padding()
                        .glassCard()
                    }
                    .padding(.horizontal)
                    
                    // Actions
                    VStack(spacing: 12) {
                        NavigationLink(destination: StudyAnalyticsView()) {
                            HStack {
                                Image(systemName: "chart.bar.fill")
                                    .foregroundColor(.blue)
                                Text("Study Analytics")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .foregroundColor(themeService.currentTheme.text)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.ultraThinMaterial)
                            )
                        }
                        
                        NavigationLink(destination: SettingsView()) {
                            HStack {
                                Image(systemName: "gear")
                                    .foregroundColor(.gray)
                                Text("Settings")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .foregroundColor(themeService.currentTheme.text)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.ultraThinMaterial)
                            )
                        }
                        
                        NavigationLink(destination: StoreView()) {
                            HStack {
                                Image(systemName: "cart.fill")
                                    .foregroundColor(.purple)
                                Text("Theme Store")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .foregroundColor(themeService.currentTheme.text)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.ultraThinMaterial)
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 100)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProfileView()
            .modelContainer(for: [UserProfile.self, StudySession.self, Badge.self])
            .environmentObject(ThemeService.shared)
    }
}
