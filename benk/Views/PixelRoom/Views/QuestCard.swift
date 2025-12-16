//
//  QuestCard.swift
//  benk
//
//  Reusable quest card component for all quest types
//

import SwiftUI

struct QuestCard: View {
    let template: QuestTemplate
    let currentProgress: Int
    let isCompleted: Bool
    let isClaimed: Bool
    let onTap: () -> Void
    let onClaim: () -> Void
    
    @EnvironmentObject var themeService: ThemeService
    
    private var progressPercentage: Double {
        min(Double(currentProgress) / Double(template.targetValue), 1.0)
    }
    
    private var remainingCount: Int {
        max(template.targetValue - currentProgress, 0)
    }
    
    var body: some View {
        Button {
            onTap()
        } label: {
            GlassCard(padding: 14) {
                HStack(spacing: 14) {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(
                                isCompleted && !isClaimed ?
                                LinearGradient(
                                    colors: [.green.opacity(0.5), .green.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ) :
                                LinearGradient(
                                    colors: [template.color.opacity(0.3), template.color.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: template.icon)
                            .font(.system(size: 22))
                            .foregroundColor(isClaimed ? themeService.currentTheme.textSecondary : template.color)
                        
                        // Checkmark overlay for claimed
                        if isClaimed {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.green)
                                .background(Circle().fill(Color.white).frame(width: 14, height: 14))
                                .offset(x: 18, y: -18)
                        }
                    }
                    
                    // Content
                    VStack(alignment: .leading, spacing: 4) {
                        Text(template.title)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(isClaimed ? themeService.currentTheme.textSecondary : themeService.currentTheme.text)
                            .lineLimit(1)
                        
                        Text(template.description)
                            .font(.system(size: 12))
                            .foregroundColor(themeService.currentTheme.textSecondary)
                            .lineLimit(1)
                        
                        // Progress Bar
                        if !isClaimed {
                            HStack(spacing: 8) {
                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(themeService.currentTheme.textSecondary.opacity(0.2))
                                            .frame(height: 6)
                                        
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(
                                                isCompleted ?
                                                LinearGradient(colors: [.green, .green.opacity(0.8)], startPoint: .leading, endPoint: .trailing) :
                                                LinearGradient(colors: [template.color, template.color.opacity(0.7)], startPoint: .leading, endPoint: .trailing)
                                            )
                                            .frame(width: geometry.size.width * progressPercentage, height: 6)
                                            .animation(.spring(response: 0.4), value: progressPercentage)
                                    }
                                }
                                .frame(height: 6)
                                
                                Text("\(currentProgress)/\(template.targetValue)")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(themeService.currentTheme.textSecondary)
                                    .frame(width: 50, alignment: .trailing)
                            }
                        }
                    }
                    
                    Spacer(minLength: 8)
                    
                    // Right side: Reward or Claim button
                    if isCompleted && !isClaimed {
                        // Claim Button
                        Button {
                            onClaim()
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "dollarsign.circle.fill")
                                    .foregroundColor(.yellow)
                                    .font(.system(size: 14))
                                Text("+\(template.coinReward)")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [.green, .green.opacity(0.8)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            )
                            .shadow(color: .green.opacity(0.4), radius: 6, x: 0, y: 3)
                        }
                        .buttonStyle(PlainButtonStyle())
                    } else if isClaimed {
                        // Claimed indicator
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                            Text("Done")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundColor(.green.opacity(0.7))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(.green.opacity(0.15))
                        )
                    } else {
                        // Coin reward preview
                        VStack(spacing: 2) {
                            Image(systemName: "dollarsign.circle.fill")
                                .foregroundColor(.yellow.opacity(0.6))
                                .font(.system(size: 18))
                            Text("\(template.coinReward)")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(themeService.currentTheme.textSecondary)
                        }
                    }
                }
            }
            .opacity(isClaimed ? 0.7 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 12) {
        QuestCard(
            template: QuestCatalog.dailyQuests[0],
            currentProgress: 1,
            isCompleted: false,
            isClaimed: false,
            onTap: {},
            onClaim: {}
        )
        
        QuestCard(
            template: QuestCatalog.dailyQuests[1],
            currentProgress: 5,
            isCompleted: true,
            isClaimed: false,
            onTap: {},
            onClaim: {}
        )
        
        QuestCard(
            template: QuestCatalog.dailyQuests[2],
            currentProgress: 10,
            isCompleted: true,
            isClaimed: true,
            onTap: {},
            onClaim: {}
        )
    }
    .padding()
    .background(Color.black)
    .environmentObject(ThemeService.shared)
}
