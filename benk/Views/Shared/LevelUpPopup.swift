//
//  LevelUpPopup.swift
//  benk
//
//  Created on 2025-12-14
//

import SwiftUI

// MARK: - Streak Milestone Colors
struct StreakMilestone {
    /// Get color for a streak milestone
    static func color(for streak: Int) -> Color {
        switch streak {
        case 0..<10:
            return Color(hex: "#FF9500") ?? .orange   // Default orange
        case 10..<25:
            return Color(hex: "#FF3B30") ?? .red      // Red
        case 25..<50:
            return Color(hex: "#AF52DE") ?? .purple   // Purple
        case 50..<100:
            return Color(hex: "#007AFF") ?? .blue     // Blue
        case 100..<200:
            return Color(hex: "#5AC8FA") ?? .cyan     // Teal
        case 200..<300:
            return Color(hex: "#34C759") ?? .green    // Green
        case 300..<400:
            return Color(hex: "#FFCC00") ?? .yellow   // Yellow
        case 400..<500:
            return Color(hex: "#FF2D55") ?? .pink     // Pink
        case 500..<600:
            return Color(hex: "#5856D6") ?? .indigo   // Indigo
        case 600..<700:
            return Color(hex: "#00C7BE") ?? .teal     // Mint
        case 700..<800:
            return Color(hex: "#32ADE6") ?? .cyan     // Cyan
        case 800..<900:
            return Color(hex: "#A2845E") ?? .brown    // Brown
        case 900..<1000:
            return Color(hex: "#C0C0C0") ?? .gray     // Silver
        default:
            return .white // Rainbow handled separately
        }
    }
    
    /// Check if streak is at rainbow tier (1000+)
    static func isRainbow(for streak: Int) -> Bool {
        return streak >= 1000
    }
    
    /// Get rainbow gradient colors for 1000+ streak
    static var rainbowColors: [Color] {
        [.red, .orange, .yellow, .green, .blue, .purple, .pink]
    }
}

// MARK: - Level Tier Colors
struct LevelTier {
    /// Get color for a level tier
    static func color(for level: Int) -> Color {
        switch level {
        case 1...4:
            return Color(hex: "#CD7F32") ?? .orange    // Bronze I
        case 5...9:
            return Color(hex: "#B87333") ?? .orange    // Bronze II
        case 10...14:
            return Color(hex: "#C0C0C0") ?? .gray      // Silver I
        case 15...19:
            return Color(hex: "#A8A9AD") ?? .gray      // Silver II
        case 20...24:
            return Color(hex: "#D4AF37") ?? .yellow    // Gold I
        case 25...29:
            return Color(hex: "#FFD700") ?? .yellow    // Gold II
        case 30...34:
            return Color(hex: "#E5E4E2") ?? .white     // Platinum I
        case 35...39:
            return Color(hex: "#E8E8E8") ?? .white     // Platinum II
        case 40...49:
            return Color(hex: "#B9F2FF") ?? .cyan      // Diamond I
        case 50...59:
            return Color(hex: "#87CEEB") ?? .cyan      // Diamond II
        case 60...69:
            return Color(hex: "#9966CC") ?? .purple    // Amethyst
        case 70...79:
            return Color(hex: "#50C878") ?? .green     // Emerald
        case 80...89:
            return Color(hex: "#E0115F") ?? .red       // Ruby
        case 90...99:
            return Color(hex: "#0F52BA") ?? .blue      // Sapphire
        default:
            return Color(hex: "#FF6B6B") ?? .pink      // Legendary (100+)
        }
    }
    
    /// Get tier name for display
    static func name(for level: Int) -> String {
        switch level {
        case 1...4:
            return "Bronze I"
        case 5...9:
            return "Bronze II"
        case 10...14:
            return "Silver I"
        case 15...19:
            return "Silver II"
        case 20...24:
            return "Gold I"
        case 25...29:
            return "Gold II"
        case 30...34:
            return "Platinum I"
        case 35...39:
            return "Platinum II"
        case 40...49:
            return "Diamond I"
        case 50...59:
            return "Diamond II"
        case 60...69:
            return "Amethyst"
        case 70...79:
            return "Emerald"
        case 80...89:
            return "Ruby"
        case 90...99:
            return "Sapphire"
        default:
            return "Legendary"
        }
    }
    
    /// Get secondary color for gradients
    static func secondaryColor(for level: Int) -> Color {
        switch level {
        case 1...4:
            return Color(hex: "#8B4513") ?? .brown     // Darker bronze I
        case 5...9:
            return Color(hex: "#7A4E2A") ?? .brown     // Darker bronze II
        case 10...14:
            return Color(hex: "#808080") ?? .gray      // Darker silver I
        case 15...19:
            return Color(hex: "#696969") ?? .gray      // Darker silver II
        case 20...24:
            return Color(hex: "#B8860B") ?? .orange    // Darker gold I
        case 25...29:
            return Color(hex: "#DAA520") ?? .orange    // Darker gold II
        case 30...34:
            return Color(hex: "#C0C0C0") ?? .gray      // Darker platinum I
        case 35...39:
            return Color(hex: "#D3D3D3") ?? .gray      // Darker platinum II
        case 40...49:
            return Color(hex: "#5F9EA0") ?? .teal      // Darker diamond I
        case 50...59:
            return Color(hex: "#4682B4") ?? .blue      // Darker diamond II
        case 60...69:
            return Color(hex: "#7B68EE") ?? .purple    // Darker amethyst
        case 70...79:
            return Color(hex: "#2E8B57") ?? .green     // Darker emerald
        case 80...89:
            return Color(hex: "#8B0000") ?? .red       // Darker ruby
        case 90...99:
            return Color(hex: "#00008B") ?? .blue      // Darker sapphire
        default:
            return Color(hex: "#FF4757") ?? .red       // Darker legendary
        }
    }
}

// MARK: - Level Up Popup
struct LevelUpPopup: View {
    let newLevel: Int
    let onDismiss: () -> Void
    
    @EnvironmentObject var themeService: ThemeService
    @State private var animateIn = false
    @State private var glowPulse = false
    
    private var tierColor: Color {
        LevelTier.color(for: newLevel)
    }
    
    private var tierSecondaryColor: Color {
        LevelTier.secondaryColor(for: newLevel)
    }
    
    private var tierName: String {
        LevelTier.name(for: newLevel)
    }
    
    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissWithAnimation()
                }
            
            VStack(spacing: 20) {
                // "Level Up!" text
                Text("Level Up!")
                    .font(.title.weight(.bold))
                    .foregroundColor(.white)
                    .scaleEffect(animateIn ? 1 : 0.5)
                    .opacity(animateIn ? 1 : 0)
                
                // Large Level Badge
                ZStack {
                    // Tier color glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    tierColor.opacity(0.6),
                                    tierColor.opacity(0.3),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 50,
                                endRadius: 120
                            )
                        )
                        .frame(width: 240, height: 240)
                        .scaleEffect(animateIn ? 1.2 : 0.5)
                        .scaleEffect(glowPulse ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: glowPulse)
                    
                    // Shield/Badge shape
                    LevelShield()
                        .fill(
                            LinearGradient(
                                colors: [
                                    tierColor.opacity(0.9),
                                    tierSecondaryColor.opacity(0.8),
                                    tierColor.opacity(0.7)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 140, height: 160)
                        .shadow(color: tierColor.opacity(0.6), radius: 20, x: 0, y: 5)
                    
                    LevelShield()
                        .fill(
                            LinearGradient(
                                colors: [
                                    tierColor,
                                    tierSecondaryColor.opacity(0.8)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 115, height: 130)
                    
                    // Level number
                    VStack(spacing: 2) {
                        Text("LVL")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text("\(newLevel)")
                            .font(.system(size: 44, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: tierColor.opacity(0.8), radius: 6, x: 0, y: 0)
                    }
                }
                .scaleEffect(animateIn ? 1 : 0)
                .rotationEffect(.degrees(animateIn ? 0 : -30))
                
                // Tier name
                Text(tierName)
                    .font(.title2.weight(.bold))
                    .foregroundColor(tierColor)
                    .opacity(animateIn ? 1 : 0)
                
                // Congratulations text
                Text("Congratulations on reaching Level \(newLevel)!")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .opacity(animateIn ? 1 : 0)
                
                // Coins earned display
                HStack(spacing: 6) {
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.yellow, .orange],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    Text("+\(newLevel * 10) coins")
                        .font(.headline.weight(.bold))
                        .foregroundColor(.yellow)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Capsule()
                                .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                        )
                )
                .shadow(color: .yellow.opacity(0.3), radius: 8)
                .opacity(animateIn ? 1 : 0)
                .scaleEffect(animateIn ? 1 : 0.5)
                
                // Tap to continue
                Text("Tap to continue")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.top, 20)
                    .opacity(animateIn ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                animateIn = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                glowPulse = true
            }
            HapticManager.shared.success()
        }
        .onTapGesture {
            dismissWithAnimation()
        }
    }
    
    private func dismissWithAnimation() {
        withAnimation(.easeOut(duration: 0.2)) {
            animateIn = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            onDismiss()
        }
    }
}

// MARK: - Level Shield Shape (similar to badge hexagon but shield-like)
struct LevelShield: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        
        // Shield shape
        path.move(to: CGPoint(x: width * 0.5, y: 0))
        path.addLine(to: CGPoint(x: width, y: height * 0.15))
        path.addLine(to: CGPoint(x: width, y: height * 0.6))
        path.addQuadCurve(
            to: CGPoint(x: width * 0.5, y: height),
            control: CGPoint(x: width * 0.85, y: height * 0.85)
        )
        path.addQuadCurve(
            to: CGPoint(x: 0, y: height * 0.6),
            control: CGPoint(x: width * 0.15, y: height * 0.85)
        )
        path.addLine(to: CGPoint(x: 0, y: height * 0.15))
        path.closeSubpath()
        
        return path
    }
}

#Preview {
    ZStack {
        Color.black
        LevelUpPopup(newLevel: 25) { }
    }
    .environmentObject(ThemeService.shared)
}

