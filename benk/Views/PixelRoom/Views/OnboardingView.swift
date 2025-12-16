//
//  OnboardingView.swift
//  Pixel Room Customizer
//
//  Beautiful onboarding experience for new users
//

import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var currentPage = 0
    @EnvironmentObject var themeManager: ThemeManager
    
    let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "🏠",
            title: "Welcome to Pixel Room!",
            description: "Design and decorate your own cozy pixel art room. Collect furniture, customize your space, and make it uniquely yours!",
            color: Color.blue
        ),
        OnboardingPage(
            icon: "💰",
            title: "Earn Coins",
            description: "Complete daily tasks, maintain login streaks, and unlock achievements to earn coins. Use them to buy awesome items!",
            color: Color.yellow
        ),
        OnboardingPage(
            icon: "🛒",
            title: "Visit the Shop",
            description: "Tap the Shop tab to browse furniture, decorations, pets, and room themes. Buy items with your coins!",
            color: Color.purple
        ),
        OnboardingPage(
            icon: "🎨",
            title: "Decorate Your Room",
            description: "Tap the Inventory tab, then drag items into your room. Move them around, rotate with two fingers, and create your perfect space!",
            color: Color.orange
        ),
        OnboardingPage(
            icon: "✨",
            title: "Ready to Start!",
            description: "Complete daily tasks to earn your first coins, then start decorating. Have fun building your dream room!",
            color: Color.pink
        )
    ]
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.1, blue: 0.15),
                    Color(red: 0.15, green: 0.12, blue: 0.2)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    Button {
                        completeOnboarding()
                    } label: {
                        Text("Skip")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(themeManager.secondaryText)
                            .padding()
                    }
                }
                
                // Page content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // Custom page indicator
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(currentPage == index ? Color.white : Color.white.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .scaleEffect(currentPage == index ? 1.2 : 1.0)
                            .animation(.spring(response: 0.3), value: currentPage)
                    }
                }
                .padding(.bottom, 20)
                
                // Next/Get Started button
                Button {
                    if currentPage < pages.count - 1 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        completeOnboarding()
                    }
                } label: {
                    Text(currentPage == pages.count - 1 ? "Get Started" : "Next")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(themeManager.primaryText)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [pages[currentPage].color, pages[currentPage].color.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
    }
    
    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        withAnimation {
            isPresented = false
        }
    }
}

struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
    let color: Color
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Icon
            Text(page.icon)
                .font(.system(size: 100))
                .padding()
                .background(
                    Circle()
                        .fill(page.color.opacity(0.2))
                        .frame(width: 180, height: 180)
                )
            
            // Title
            Text(page.title)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(themeManager.primaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Description
            Text(page.description)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(themeManager.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .lineSpacing(6)
            
            Spacer()
        }
    }
}

#Preview {
    OnboardingView(isPresented: .constant(true))
        .environmentObject(ThemeManager())
}
