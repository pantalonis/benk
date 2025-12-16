//
//  GameSystemsInfoView.swift
//  benk
//
//  Created on 2025-12-14
//

import SwiftUI

struct GameSystemsInfoView: View {
    @EnvironmentObject var themeService: ThemeService
    @State private var currentPage = 0
    @State private var appeared = false
    
    var body: some View {
        ZStack {
            themeService.currentTheme.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Page indicator dots
                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .fill(currentPage == index ? pageColor(for: index) : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .scaleEffect(currentPage == index ? 1.2 : 1.0)
                            .animation(.spring(response: 0.3), value: currentPage)
                    }
                }
                .padding(.top, 8)
                
                TabView(selection: $currentPage) {
                    LevelSystemSection()
                        .tag(0)
                    
                    BadgeSystemSection()
                        .tag(1)
                    
                    StreakSystemSection()
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .onChange(of: currentPage) {
                    HapticManager.shared.selection()
                }
            }
        }
        .navigationTitle("How It Works")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                appeared = true
            }
        }
    }
    
    private func pageColor(for index: Int) -> Color {
        switch index {
        case 0: return LevelTier.color(for: 25) // Gold
        case 1: return Color(hex: "#FFD700") ?? .yellow
        case 2: return StreakMilestone.color(for: 50)
        default: return .white
        }
    }
}

// MARK: - Level System Section
struct LevelSystemSection: View {
    @EnvironmentObject var themeService: ThemeService
    @State private var animatedLevel = 1
    @State private var showTiers = false
    @State private var selectedTier: Int? = nil
    
    // All level tier data
    private let tiers: [(range: String, name: String, level: Int)] = [
        ("1-4", "Bronze I", 1),
        ("5-9", "Bronze II", 5),
        ("10-14", "Silver I", 10),
        ("15-19", "Silver II", 15),
        ("20-24", "Gold I", 20),
        ("25-29", "Gold II", 25),
        ("30-34", "Platinum I", 30),
        ("35-39", "Platinum II", 35),
        ("40-49", "Diamond I", 40),
        ("50-59", "Diamond II", 50),
        ("60-69", "Amethyst", 60),
        ("70-79", "Emerald", 70),
        ("80-89", "Ruby", 80),
        ("90-99", "Sapphire", 90),
        ("100+", "Legendary", 100)
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Animated Level Shield
                animatedShieldSection
                
                // XP Explanation
                xpExplanationCard
                
                // Tier Grid
                tierGridSection
                
                Spacer(minLength: 60)
            }
            .padding(.horizontal)
            .padding(.top, 20)
        }
        .onAppear {
            startTierAnimation()
            withAnimation(.spring(response: 0.6).delay(0.3)) {
                showTiers = true
            }
        }
    }
    
    private var animatedShieldSection: some View {
        VStack(spacing: 16) {
            Text("Level System")
                .font(.title.weight(.bold))
                .foregroundColor(themeService.currentTheme.text)
            
            Text("Earn XP to level up and unlock new ranks")
                .font(.subheadline)
                .foregroundColor(themeService.currentTheme.textSecondary)
                .multilineTextAlignment(.center)
            
            // Animated shield that cycles through tiers
            ZStack {
                // Glow effect
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                LevelTier.color(for: animatedLevel).opacity(0.4),
                                LevelTier.color(for: animatedLevel).opacity(0.1),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 30,
                            endRadius: 80
                        )
                    )
                    .frame(width: 160, height: 160)
                
                // Shield shape
                LevelShield()
                    .fill(
                        LinearGradient(
                            colors: [
                                LevelTier.color(for: animatedLevel),
                                LevelTier.secondaryColor(for: animatedLevel)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 90)
                    .shadow(color: LevelTier.color(for: animatedLevel).opacity(0.5), radius: 15)
                
                // Level number
                VStack(spacing: 0) {
                    Text("LVL")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white.opacity(0.8))
                    Text("\(animatedLevel)")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                }
            }
            .animation(.easeInOut(duration: 0.5), value: animatedLevel)
            
            // Current tier name
            Text(LevelTier.name(for: animatedLevel))
                .font(.headline)
                .foregroundColor(LevelTier.color(for: animatedLevel))
                .animation(.easeInOut(duration: 0.3), value: animatedLevel)
        }
    }
    
    private var xpExplanationCard: some View {
        GlassCard(padding: 16) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "sparkles")
                        .foregroundColor(.yellow)
                    Text("How XP Works")
                        .font(.headline)
                        .foregroundColor(themeService.currentTheme.text)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    xpInfoRow(icon: "clock.fill", text: "1 minute of study = 1 XP")
                    xpInfoRow(icon: "arrow.up.circle.fill", text: "Each level requires more XP")
                    xpInfoRow(icon: "gift.fill", text: "Level up to earn bonus coins")
                    xpInfoRow(icon: "star.fill", text: "Techniques can multiply XP earned")
                }
            }
        }
    }
    
    private func xpInfoRow(icon: String, text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(themeService.currentTheme.primary)
                .frame(width: 20)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(themeService.currentTheme.textSecondary)
        }
    }
    
    private var tierGridSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("All Ranks")
                .font(.headline)
                .foregroundColor(themeService.currentTheme.text)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 10) {
                ForEach(Array(tiers.enumerated()), id: \.offset) { index, tier in
                    TierCard(
                        name: tier.name,
                        range: tier.range,
                        color: LevelTier.color(for: tier.level),
                        isSelected: selectedTier == index
                    )
                    .opacity(showTiers ? 1 : 0)
                    .offset(y: showTiers ? 0 : 20)
                    .animation(
                        .spring(response: 0.5, dampingFraction: 0.7)
                        .delay(Double(index) * 0.05),
                        value: showTiers
                    )
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3)) {
                            selectedTier = selectedTier == index ? nil : index
                            animatedLevel = tier.level
                        }
                        HapticManager.shared.selection()
                    }
                }
            }
        }
    }
    
    private func startTierAnimation() {
        // Cycle through tiers automatically
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            if selectedTier == nil {
                let levels = [1, 5, 10, 15, 20, 25, 30, 35, 40, 50, 60, 70, 80, 90, 100]
                if let currentIndex = levels.firstIndex(of: animatedLevel) {
                    let nextIndex = (currentIndex + 1) % levels.count
                    withAnimation(.easeInOut(duration: 0.5)) {
                        animatedLevel = levels[nextIndex]
                    }
                }
            }
        }
    }
}

// MARK: - Tier Card
struct TierCard: View {
    let name: String
    let range: String
    let color: Color
    let isSelected: Bool
    
    @EnvironmentObject var themeService: ThemeService
    
    var body: some View {
        VStack(spacing: 4) {
            // Mini shield
            LevelShield()
                .fill(
                    LinearGradient(
                        colors: [color, color.opacity(0.7)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 24, height: 28)
                .shadow(color: color.opacity(isSelected ? 0.6 : 0.3), radius: isSelected ? 8 : 4)
            
            Text(name)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(color)
                .lineLimit(1)
            
            Text("Lvl \(range)")
                .font(.system(size: 8))
                .foregroundColor(themeService.currentTheme.textSecondary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(themeService.currentTheme.surface.opacity(isSelected ? 0.5 : 0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(color.opacity(isSelected ? 0.5 : 0), lineWidth: 1)
                )
        )
        .scaleEffect(isSelected ? 1.05 : 1.0)
    }
}

// MARK: - Badge System Section
struct BadgeSystemSection: View {
    @EnvironmentObject var themeService: ThemeService
    @State private var showCategories = false
    @State private var glowPulse = false
    @State private var selectedCategory: BadgeCategory? = nil
    
    private let categories: [(category: BadgeCategory, icon: String, description: String)] = [
        (.streak, "flame.fill", "Study consecutive days"),
        (.dailyGoal, "target", "Hit your daily goals"),
        (.technique, "lightbulb.fill", "Try different study methods"),
        (.timeSpent, "clock.fill", "Accumulate study hours"),
        (.taskCompletion, "checkmark.circle.fill", "Complete tasks"),
        (.special, "star.fill", "Special achievements"),
        (.xpMilestone, "sparkles", "Reach XP milestones"),
        (.subjectMastery, "book.fill", "Master subjects")
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Animated Badge Header
                animatedBadgeSection
                
                // How to Earn Card
                howToEarnCard
                
                // Category Grid
                categoryGridSection
                
                Spacer(minLength: 60)
            }
            .padding(.horizontal)
            .padding(.top, 20)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6).delay(0.3)) {
                showCategories = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                glowPulse = true
            }
        }
    }
    
    private var animatedBadgeSection: some View {
        VStack(spacing: 16) {
            Text("Badge System")
                .font(.title.weight(.bold))
                .foregroundColor(themeService.currentTheme.text)
            
            Text("Earn badges by completing achievements")
                .font(.subheadline)
                .foregroundColor(themeService.currentTheme.textSecondary)
                .multilineTextAlignment(.center)
            
            // Animated hexagon badge
            ZStack {
                // Glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.yellow.opacity(0.4),
                                Color.yellow.opacity(0.1),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 30,
                            endRadius: 80
                        )
                    )
                    .frame(width: 160, height: 160)
                    .scaleEffect(glowPulse ? 1.1 : 0.9)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: glowPulse)
                
                // Badge hexagon
                BadgeHexagon()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "#FFD700") ?? .yellow,
                                Color(hex: "#B8860B") ?? .orange
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 90)
                    .shadow(color: Color.yellow.opacity(0.5), radius: 15)
                
                // Star icon
                Image(systemName: "star.fill")
                    .font(.system(size: 30))
                    .foregroundColor(.white)
            }
            
            Text("32 Badges to Collect")
                .font(.headline)
                .foregroundColor(Color(hex: "#FFD700") ?? .yellow)
        }
    }
    
    private var howToEarnCard: some View {
        GlassCard(padding: 16) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "trophy.fill")
                        .foregroundColor(.yellow)
                    Text("How to Earn Badges")
                        .font(.headline)
                        .foregroundColor(themeService.currentTheme.text)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    badgeInfoRow(icon: "chart.bar.fill", text: "Track progress on each badge")
                    badgeInfoRow(icon: "bell.badge.fill", text: "Get notified when you earn one")
                    badgeInfoRow(icon: "dollarsign.circle.fill", text: "Earn bonus coins for badges")
                    badgeInfoRow(icon: "book.closed.fill", text: "Each badge has unique lore")
                }
            }
        }
    }
    
    private func badgeInfoRow(icon: String, text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(themeService.currentTheme.primary)
                .frame(width: 20)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(themeService.currentTheme.textSecondary)
        }
    }
    
    private var categoryGridSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Badge Categories")
                .font(.headline)
                .foregroundColor(themeService.currentTheme.text)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 10) {
                ForEach(Array(categories.enumerated()), id: \.offset) { index, item in
                    CategoryCard(
                        name: categoryName(item.category),
                        icon: item.icon,
                        description: item.description,
                        isSelected: selectedCategory == item.category
                    )
                    .opacity(showCategories ? 1 : 0)
                    .offset(y: showCategories ? 0 : 20)
                    .animation(
                        .spring(response: 0.5, dampingFraction: 0.7)
                        .delay(Double(index) * 0.08),
                        value: showCategories
                    )
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3)) {
                            selectedCategory = selectedCategory == item.category ? nil : item.category
                        }
                        HapticManager.shared.selection()
                    }
                }
            }
        }
    }
    
    private func categoryName(_ category: BadgeCategory) -> String {
        switch category {
        case .streak: return "Streak"
        case .dailyGoal: return "Daily Goal"
        case .technique: return "Technique"
        case .timeSpent: return "Time Spent"
        case .taskCompletion: return "Tasks"
        case .special: return "Special"
        case .xpMilestone: return "XP Milestone"
        case .subjectMastery: return "Subject"
        }
    }
}

// MARK: - Category Card
struct CategoryCard: View {
    let name: String
    let icon: String
    let description: String
    let isSelected: Bool
    
    @EnvironmentObject var themeService: ThemeService
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(themeService.currentTheme.primary)
            
            Text(name)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(themeService.currentTheme.text)
            
            Text(description)
                .font(.system(size: 9))
                .foregroundColor(themeService.currentTheme.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(themeService.currentTheme.surface.opacity(isSelected ? 0.5 : 0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(themeService.currentTheme.primary.opacity(isSelected ? 0.5 : 0), lineWidth: 1)
                )
        )
        .scaleEffect(isSelected ? 1.03 : 1.0)
    }
}

// MARK: - Streak System Section
struct StreakSystemSection: View {
    @EnvironmentObject var themeService: ThemeService
    @State private var animatedStreak = 0
    @State private var showMilestones = false
    @State private var flamePulse = false
    
    private let milestones: [(days: Int, color: Color, name: String)] = [
        (10, StreakMilestone.color(for: 10), "Red Hot"),
        (25, StreakMilestone.color(for: 25), "Purple Power"),
        (50, StreakMilestone.color(for: 50), "Blue Blaze"),
        (100, StreakMilestone.color(for: 100), "Teal Fire"),
        (200, StreakMilestone.color(for: 200), "Green Flame"),
        (300, StreakMilestone.color(for: 300), "Golden Glow"),
        (500, StreakMilestone.color(for: 500), "Indigo Inferno"),
        (1000, .white, "Rainbow Legend")
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Animated Flame Header
                animatedFlameSection
                
                // How Streaks Work Card
                streakExplanationCard
                
                // Milestone Timeline
                milestoneTimelineSection
                
                Spacer(minLength: 60)
            }
            .padding(.horizontal)
            .padding(.top, 20)
        }
        .onAppear {
            startStreakAnimation()
            withAnimation(.spring(response: 0.6).delay(0.3)) {
                showMilestones = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                flamePulse = true
            }
        }
    }
    
    private var animatedFlameSection: some View {
        VStack(spacing: 16) {
            Text("Streak System")
                .font(.title.weight(.bold))
                .foregroundColor(themeService.currentTheme.text)
            
            Text("Study every day to build your streak")
                .font(.subheadline)
                .foregroundColor(themeService.currentTheme.textSecondary)
                .multilineTextAlignment(.center)
            
            // Animated flame
            ZStack {
                // Glow
                if StreakMilestone.isRainbow(for: animatedStreak) {
                    Circle()
                        .fill(
                            AngularGradient(
                                colors: StreakMilestone.rainbowColors + [StreakMilestone.rainbowColors.first ?? .red],
                                center: .center
                            )
                        )
                        .blur(radius: 25)
                        .frame(width: 140, height: 140)
                        .scaleEffect(flamePulse ? 1.1 : 0.9)
                        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: flamePulse)
                } else {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    StreakMilestone.color(for: animatedStreak).opacity(0.5),
                                    StreakMilestone.color(for: animatedStreak).opacity(0.2),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 30,
                                endRadius: 80
                            )
                        )
                        .frame(width: 160, height: 160)
                        .scaleEffect(flamePulse ? 1.05 : 0.95)
                        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: flamePulse)
                }
                
                // Flame icon
                Image(systemName: "flame.fill")
                    .font(.system(size: 70))
                    .foregroundStyle(
                        StreakMilestone.isRainbow(for: animatedStreak)
                            ? AnyShapeStyle(LinearGradient(
                                colors: StreakMilestone.rainbowColors,
                                startPoint: .top,
                                endPoint: .bottom
                            ))
                            : AnyShapeStyle(StreakMilestone.color(for: animatedStreak))
                    )
                    .shadow(color: StreakMilestone.color(for: animatedStreak).opacity(0.5), radius: 10)
                
                // Day count
                Text("\(animatedStreak)")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.5), radius: 2)
                    .offset(y: 5)
            }
            .animation(.easeInOut(duration: 0.5), value: animatedStreak)
            
            // Current milestone name
            Text(milestoneName(for: animatedStreak))
                .font(.headline)
                .foregroundColor(StreakMilestone.color(for: animatedStreak))
                .animation(.easeInOut(duration: 0.3), value: animatedStreak)
        }
    }
    
    private var streakExplanationCard: some View {
        GlassCard(padding: 16) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.orange)
                    Text("How Streaks Work")
                        .font(.headline)
                        .foregroundColor(themeService.currentTheme.text)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    streakInfoRow(icon: "sun.max.fill", text: "Study at least once per day")
                    streakInfoRow(icon: "arrow.up.forward", text: "Streak increases each day")
                    streakInfoRow(icon: "paintpalette.fill", text: "Flame color changes at milestones")
                    streakInfoRow(icon: "sparkles", text: "Reach 1000 days for rainbow!")
                }
            }
        }
    }
    
    private func streakInfoRow(icon: String, text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.orange)
                .frame(width: 20)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(themeService.currentTheme.textSecondary)
        }
    }
    
    private var milestoneTimelineSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Streak Milestones")
                .font(.headline)
                .foregroundColor(themeService.currentTheme.text)
            
            VStack(spacing: 0) {
                ForEach(Array(milestones.enumerated()), id: \.offset) { index, milestone in
                    MilestoneRow(
                        days: milestone.days,
                        color: milestone.color,
                        name: milestone.name,
                        isRainbow: milestone.days >= 1000,
                        isLast: index == milestones.count - 1
                    )
                    .opacity(showMilestones ? 1 : 0)
                    .offset(x: showMilestones ? 0 : -30)
                    .animation(
                        .spring(response: 0.5, dampingFraction: 0.7)
                        .delay(Double(index) * 0.1),
                        value: showMilestones
                    )
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            animatedStreak = milestone.days
                        }
                        HapticManager.shared.selection()
                    }
                }
            }
        }
    }
    
    private func milestoneName(for streak: Int) -> String {
        switch streak {
        case 0..<10: return "Getting Started"
        case 10..<25: return "Red Hot"
        case 25..<50: return "Purple Power"
        case 50..<100: return "Blue Blaze"
        case 100..<200: return "Teal Fire"
        case 200..<300: return "Green Flame"
        case 300..<400: return "Golden Glow"
        case 400..<500: return "Pink Passion"
        case 500..<600: return "Indigo Inferno"
        case 600..<700: return "Mint Master"
        case 700..<800: return "Cyan Champion"
        case 800..<900: return "Bronze Boss"
        case 900..<1000: return "Silver Sage"
        default: return "Rainbow Legend"
        }
    }
    
    private func startStreakAnimation() {
        let streakValues = [0, 10, 25, 50, 100, 200, 300, 500, 1000]
        var index = 0
        
        Timer.scheduledTimer(withTimeInterval: 2.5, repeats: true) { _ in
            index = (index + 1) % streakValues.count
            withAnimation(.easeInOut(duration: 0.5)) {
                animatedStreak = streakValues[index]
            }
        }
    }
}

// MARK: - Milestone Row
struct MilestoneRow: View {
    let days: Int
    let color: Color
    let name: String
    let isRainbow: Bool
    let isLast: Bool
    
    @EnvironmentObject var themeService: ThemeService
    
    var body: some View {
        HStack(spacing: 16) {
            // Timeline dot and line
            VStack(spacing: 0) {
                Circle()
                    .fill(isRainbow ? Color.white : color)
                    .frame(width: 12, height: 12)
                    .overlay(
                        Circle()
                            .stroke(color.opacity(0.5), lineWidth: 2)
                    )
                    .shadow(color: color.opacity(0.5), radius: 4)
                
                if !isLast {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [color.opacity(0.5), themeService.currentTheme.surface.opacity(0.3)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 2, height: 40)
                }
            }
            
            // Flame icon
            if isRainbow {
                Image(systemName: "flame.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(
                        LinearGradient(
                            colors: StreakMilestone.rainbowColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            } else {
                Image(systemName: "flame.fill")
                    .font(.system(size: 24))
                    .foregroundColor(color)
            }
            
            // Info
            VStack(alignment: .leading, spacing: 2) {
                Text("\(days) Days")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(isRainbow ? .white : color)
                
                Text(name)
                    .font(.system(size: 12))
                    .foregroundColor(themeService.currentTheme.textSecondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// BadgeHexagon is defined in MilestonesView.swift

#Preview {
    NavigationStack {
        GameSystemsInfoView()
    }
    .environmentObject(ThemeService.shared)
}

