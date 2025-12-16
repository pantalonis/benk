//
//  StreakRewardCard.swift
//  benk
//
//  Streak reward card with glowing fire icon
//

import SwiftUI

struct StreakRewardCard: View {
    let streak: Int
    let canClaim: Bool
    let coinReward: Int
    let onClaim: () -> Void
    
    @EnvironmentObject var themeService: ThemeService
    @State private var pulseAnimation = false
    
    // Streak color based on milestone
    private var streakColor: Color {
        StreakMilestone.color(for: streak)
    }
    
    private var isRainbow: Bool {
        StreakMilestone.isRainbow(for: streak)
    }
    
    var body: some View {
        GlassCard(padding: 16) {
            HStack(spacing: 16) {
                // Fire Icon with Streak Number
                ZStack {
                    // Glow effect
                    if canClaim {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        streakColor.opacity(0.6),
                                        streakColor.opacity(0.2),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 10,
                                    endRadius: 50
                                )
                            )
                            .frame(width: 80, height: 80)
                            .scaleEffect(pulseAnimation ? 1.2 : 1.0)
                            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: pulseAnimation)
                    }
                    
                    // Fire icon with number inside
                    ZStack {
                        if isRainbow {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 50))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: StreakMilestone.rainbowColors,
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        } else {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 50))
                                .foregroundColor(streakColor)
                        }
                        
                        Text("\(streak)")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                            .offset(y: 4)
                    }
                    .shadow(color: streakColor.opacity(canClaim ? 0.8 : 0.3), radius: canClaim ? 15 : 5, x: 0, y: 0)
                }
                .frame(width: 70, height: 70)
                
                // Text Content
                VStack(alignment: .leading, spacing: 4) {
                    Text("Streak Reward")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(themeService.currentTheme.text)
                        .lineLimit(1)
                    
                    HStack(spacing: 3) {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.yellow)
                        Text("+\(coinReward)")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.yellow)
                    }
                    .lineLimit(1)
                    
                    if canClaim {
                        Text("Ready to claim!")
                            .font(.system(size: 11))
                            .foregroundColor(.green)
                            .lineLimit(1)
                    } else {
                        Text("Come back tomorrow")
                            .font(.system(size: 11))
                            .foregroundColor(themeService.currentTheme.textSecondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                }
                
                Spacer()
                
                // Claim Button
                Button {
                    onClaim()
                } label: {
                    Text(canClaim ? "Claim" : "Claimed")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(canClaim ? 
                                    LinearGradient(
                                        colors: [.orange, .red],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ) : 
                                    LinearGradient(
                                        colors: [Color.gray.opacity(0.5), Color.gray.opacity(0.3)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                        .shadow(color: canClaim ? .orange.opacity(0.5) : .clear, radius: 8, x: 0, y: 4)
                }
                .disabled(!canClaim)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    LinearGradient(
                        colors: canClaim ? [.orange.opacity(0.6), .red.opacity(0.4)] : [Color.clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: canClaim ? 1.5 : 0
                )
        )
        .onAppear {
            if canClaim {
                pulseAnimation = true
            }
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        StreakRewardCard(streak: 7, canClaim: true, coinReward: 15, onClaim: {})
        StreakRewardCard(streak: 25, canClaim: false, coinReward: 25, onClaim: {})
    }
    .padding()
    .background(Color.black)
    .environmentObject(ThemeService.shared)
}
