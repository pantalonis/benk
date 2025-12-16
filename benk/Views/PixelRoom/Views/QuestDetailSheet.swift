//
//  QuestDetailSheet.swift
//  benk
//
//  Detail popup for quests with instructions, progress, and lore
//  Similar to BadgeDetailPopup from MilestonesView
//

import SwiftUI

struct QuestDetailSheet: View {
    let template: QuestTemplate
    let currentProgress: Int
    let isCompleted: Bool
    let isClaimed: Bool
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeService: ThemeService
    
    @State private var glowPulse = false
    
    private var progressPercentage: Double {
        min(Double(currentProgress) / Double(template.targetValue), 1.0)
    }
    
    private var remainingCount: Int {
        max(template.targetValue - currentProgress, 0)
    }
    
    var body: some View {
        ZStack {
            // Background
            themeService.currentTheme.background
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Close button area
                    HStack {
                        Spacer()
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(themeService.currentTheme.textSecondary)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Large Icon with Glow
                    ZStack {
                        // Glow effect
                        if isCompleted {
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            template.color.opacity(0.5),
                                            template.color.opacity(0.2),
                                            Color.clear
                                        ],
                                        center: .center,
                                        startRadius: 30,
                                        endRadius: 90
                                    )
                                )
                                .frame(width: 180, height: 180)
                                .scaleEffect(glowPulse ? 1.1 : 1.0)
                                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: glowPulse)
                                .onAppear { glowPulse = true }
                        }
                        
                        // Background circle
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        template.color.opacity(isCompleted ? 0.4 : 0.2),
                                        template.color.opacity(isCompleted ? 0.2 : 0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                        
                        // Inner circle
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        template.color.opacity(isCompleted ? 0.8 : 0.4),
                                        template.color.opacity(isCompleted ? 0.6 : 0.3)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 100, height: 100)
                        
                        // Icon
                        Image(systemName: template.icon)
                            .font(.system(size: 45, weight: .semibold))
                            .foregroundColor(isCompleted ? .white : themeService.currentTheme.textSecondary)
                            .shadow(color: isCompleted ? template.color.opacity(0.8) : .clear, radius: 6, x: 0, y: 0)
                        
                        // Checkmark overlay for claimed
                        if isClaimed {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.green)
                                .background(Circle().fill(Color.white).padding(-4))
                                .offset(x: 40, y: 40)
                        }
                    }
                    .padding(.top, 10)
                    
                    // Title
                    Text(template.title)
                        .font(.title.weight(.bold))
                        .foregroundColor(themeService.currentTheme.text)
                        .multilineTextAlignment(.center)
                    
                    // Status Badge
                    statusBadge
                    
                    // Coin Reward
                    HStack(spacing: 6) {
                        Image(systemName: "dollarsign.circle.fill")
                            .foregroundColor(.yellow)
                            .font(.system(size: 20))
                        Text("\(template.coinReward) coins")
                            .font(.headline)
                            .foregroundColor(.yellow)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.yellow.opacity(0.15))
                    )
                    
                    // Progress Section
                    GlassCard(padding: 16) {
                        VStack(spacing: 12) {
                            Text("Progress")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(themeService.currentTheme.textSecondary)
                            
                            // Progress Bar
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(themeService.currentTheme.textSecondary.opacity(0.2))
                                    .frame(height: 12)
                                
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(
                                        isCompleted ?
                                        LinearGradient(colors: [.green, .green.opacity(0.7)], startPoint: .leading, endPoint: .trailing) :
                                        LinearGradient(colors: [template.color, template.color.opacity(0.7)], startPoint: .leading, endPoint: .trailing)
                                    )
                                    .frame(width: nil, height: 12)
                                    .scaleEffect(x: progressPercentage, y: 1, anchor: .leading)
                                    .animation(.spring(response: 0.5), value: progressPercentage)
                            }
                            
                            // Progress Text
                            HStack {
                                Text("\(currentProgress)/\(template.targetValue)")
                                    .font(.title3.weight(.bold))
                                    .foregroundColor(themeService.currentTheme.text)
                                
                                Spacer()
                                
                                Text("\(Int(progressPercentage * 100))%")
                                    .font(.title3.weight(.semibold))
                                    .foregroundColor(template.color)
                            }
                            
                            // Remaining count
                            if !isCompleted {
                                Text("\(remainingCount) more to go!")
                                    .font(.subheadline)
                                    .foregroundColor(themeService.currentTheme.textSecondary)
                            } else if !isClaimed {
                                Text("🎉 Ready to claim!")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // How to Complete Section
                    GlassCard(padding: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "lightbulb.fill")
                                    .foregroundColor(.yellow)
                                Text("How to complete")
                                    .font(.headline.weight(.semibold))
                                    .foregroundColor(themeService.currentTheme.text)
                            }
                            
                            Text(template.instructions)
                                .font(.subheadline)
                                .foregroundColor(themeService.currentTheme.text.opacity(0.9))
                                .multilineTextAlignment(.leading)
                                .lineSpacing(4)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Lore Section
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "book.fill")
                                .foregroundColor(template.color)
                            Text("Lore")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(themeService.currentTheme.textSecondary)
                        }
                        
                        Text(template.lore)
                            .font(.subheadline)
                            .foregroundColor(themeService.currentTheme.text.opacity(0.8))
                            .italic()
                            .multilineTextAlignment(.leading)
                            .lineSpacing(4)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(template.color.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(template.color.opacity(0.2), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal)
                    
                    Spacer(minLength: 40)
                }
                .padding(.top, 20)
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
    
    // MARK: - Status Badge
    private var statusBadge: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(statusColor)
                .frame(width: 10, height: 10)
            
            Text(statusText)
                .font(.subheadline.weight(.medium))
                .foregroundColor(statusColor)
        }
    }
    
    private var statusText: String {
        if isClaimed {
            return "Completed"
        } else if isCompleted {
            return "Ready to Claim"
        } else if currentProgress > 0 {
            return "In Progress"
        } else {
            return "Not Started"
        }
    }
    
    private var statusColor: Color {
        if isClaimed {
            return .green
        } else if isCompleted {
            return .yellow
        } else if currentProgress > 0 {
            return .blue
        } else {
            return themeService.currentTheme.textSecondary
        }
    }
}

// MARK: - Preview
#Preview {
    QuestDetailSheet(
        template: QuestCatalog.dailyQuests[0],
        currentProgress: 2,
        isCompleted: false,
        isClaimed: false
    )
    .environmentObject(ThemeService.shared)
}
