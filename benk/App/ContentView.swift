//
//  ContentView.swift
//  benk
//
//  Created on 2025-12-11
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var themeService: ThemeService
    @EnvironmentObject var badgeService: BadgeService
    @EnvironmentObject var xpService: XPService
    @State private var selectedTab = 0
    @State private var isPlusExpanded = false
    @Query private var userProfiles: [UserProfile]
    
    var userProfile: UserProfile {
        if let profile = userProfiles.first {
            return profile
        } else {
            // Create default profile
            let newProfile = UserProfile()
            modelContext.insert(newProfile)
            return newProfile
        }
    }
    
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Main content based on selected tab
                Group {
                    switch selectedTab {
                    case 0:
                        HomeView()
                    case 1:
                        RoomView()
                    case 2:
                        GroupsView()
                    case 3:
                        ProfileView()
                    default:
                        HomeView()
                    }
                }
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.15), value: selectedTab)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Custom liquid glass tab bar overlay with plus button
                VStack {
                    Spacer()
                    HStack(spacing: 12) {
                        LiquidGlassTabBar(selectedTab: $selectedTab)
                        PlusButton(isExpanded: $isPlusExpanded)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
                .ignoresSafeArea(edges: .bottom)
            }
            .onAppear {
                initializeDefaultData()
                
                // One-time migration: Sync legacy UserProfile coins to the new CurrencyManager
                if !UserDefaults.standard.bool(forKey: "coins_migrated_v2") {
                    CurrencyManager.shared.coins = userProfile.coins
                    UserDefaults.standard.set(true, forKey: "coins_migrated_v2")
                }
            }
            .overlay {
                // Badge Earned Celebration Popup
                if badgeService.showBadgeEarnedPopup, let badge = badgeService.newlyEarnedBadge {
                    BadgeEarnedPopup(badge: badge) {
                        badgeService.dismissBadgePopup()
                    }
                    .transition(.opacity.combined(with: .scale))
                    .zIndex(100)
                }
                
                // Level Up Celebration Popup
                if xpService.showLevelUpPopup {
                    LevelUpPopup(newLevel: xpService.newLevel) {
                        xpService.dismissLevelUpPopup()
                    }
                    .transition(.opacity.combined(with: .scale))
                    .zIndex(101)
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: badgeService.showBadgeEarnedPopup)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: xpService.showLevelUpPopup)
            .toolbarBackground(.hidden, for: .navigationBar)
        }
    }
    
    private func initializeDefaultData() {
        // Initialize UserProfile if none exists
        let profileDescriptor = FetchDescriptor<UserProfile>()
        if let count = try? modelContext.fetchCount(profileDescriptor), count == 0 {
            let newProfile = UserProfile()
            modelContext.insert(newProfile)
        }

        // Initialize default subjects if none exist
        let descriptor = FetchDescriptor<Subject>()
        if let count = try? modelContext.fetchCount(descriptor), count == 0 {
            DataController.shared.initializeDefaultSubjects(context: modelContext)
        }
        
        // Initialize default techniques if none exist
        let techDescriptor = FetchDescriptor<Technique>()
        if let count = try? modelContext.fetchCount(techDescriptor), count == 0 {
            StudyTechniqueDatabase.seedTechniques(context: modelContext)
        }
        
        // Initialize default badges - always ensure we have the latest badge set
        // If badge count doesn't match expected, or any badge is missing titleName, recreate all badges
        let badgeDescriptor = FetchDescriptor<Badge>()
        let expectedBadgeCount = 33 // Total badges we create (including Holiday Hero)
        if let badges = try? modelContext.fetch(badgeDescriptor) {
            let needsRecreation = badges.isEmpty || 
                                  badges.count != expectedBadgeCount ||
                                  badges.contains { $0.titleName.isEmpty }
            if needsRecreation {
                // Delete old badges and recreate
                try? modelContext.delete(model: Badge.self)
                try? modelContext.save()
                DataController.shared.initializeDefaultBadges(context: modelContext)
            }
        } else {
            DataController.shared.initializeDefaultBadges(context: modelContext)
        }
        
        // Check and refresh quests
        QuestStats.shared.checkResets()
        QuestService.shared.checkRefresh()
        
        // Check all badges on app load (will queue popups for any newly earned badges)
        badgeService.checkAllBadgesOnLoad(context: modelContext)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [UserProfile.self, StudySession.self, Task.self])
        .environmentObject(ThemeService.shared)
        .environmentObject(TimerService.shared)
}
