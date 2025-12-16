//
//  GlassToast.swift
//  benk
//
//  Modern liquid glass toast notification with fun animations
//

import SwiftUI

enum ToastType {
    case purchased
    case placed
    case success
    case info
    
    var icon: String {
        switch self {
        case .purchased: return "bag.fill.badge.plus"
        case .placed: return "checkmark.circle.fill"
        case .success: return "star.fill"
        case .info: return "info.circle.fill"
        }
    }
    
    var gradient: [Color] {
        switch self {
        case .purchased: return [.yellow, .orange]
        case .placed: return [.green, .mint]
        case .success: return [.purple, .pink]
        case .info: return [.blue, .cyan]
        }
    }
    
    var emoji: String {
        switch self {
        case .purchased: return "🎉"
        case .placed: return "✨"
        case .success: return "🌟"
        case .info: return "💡"
        }
    }
}

struct GlassToast: View {
    let type: ToastType
    let title: String
    let message: String
    let onDismiss: () -> Void
    
    @State private var animateIn = false
    @State private var iconScale: CGFloat = 0.5
    @State private var confettiOffset: CGFloat = 0
    @State private var shimmerOffset: CGFloat = -200
    @State private var pulseScale: CGFloat = 1.0
    
    @EnvironmentObject var themeService: ThemeService
    
    var body: some View {
        ZStack {
            // Semi-transparent backdrop
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissWithAnimation()
                }
            
            // Toast Card
            VStack(spacing: 16) {
                // Animated Icon with glow
                ZStack {
                    // Glow effect
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: type.gradient.map { $0.opacity(0.5) } + [Color.clear],
                                center: .center,
                                startRadius: 10,
                                endRadius: 60
                            )
                        )
                        .frame(width: 100, height: 100)
                        .scaleEffect(pulseScale)
                    
                    // Icon background
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: type.gradient,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 70, height: 70)
                        .shadow(color: type.gradient.first?.opacity(0.5) ?? .clear, radius: 15, x: 0, y: 5)
                    
                    // Icon
                    Image(systemName: type.icon)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .scaleEffect(iconScale)
                }
                
                // Emoji burst
                Text(type.emoji)
                    .font(.system(size: 28))
                    .offset(y: confettiOffset)
                    .opacity(animateIn ? 1 : 0)
                
                // Title
                Text(title)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: type.gradient,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                // Message
                Text(message)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
                
                // Dismiss button
                Button {
                    SoundManager.shared.buttonTap()
                    HapticManager.shared.light()
                    dismissWithAnimation()
                } label: {
                    Text("Awesome!")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: type.gradient,
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .overlay(
                                    Capsule()
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                        )
                        .shadow(color: type.gradient.first?.opacity(0.4) ?? .clear, radius: 10, x: 0, y: 5)
                }
                .padding(.top, 8)
            }
            .padding(28)
            .background(
                ZStack {
                    // Glass background
                    RoundedRectangle(cornerRadius: 28)
                        .fill(.ultraThinMaterial)
                    
                    // Gradient overlay
                    RoundedRectangle(cornerRadius: 28)
                        .fill(
                            LinearGradient(
                                colors: [
                                    type.gradient.first?.opacity(0.15) ?? .clear,
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    // Shimmer effect
                    RoundedRectangle(cornerRadius: 28)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.clear,
                                    Color.white.opacity(0.2),
                                    Color.clear
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .offset(x: shimmerOffset)
                        .mask(
                            RoundedRectangle(cornerRadius: 28)
                        )
                    
                    // Border
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.4),
                                    Color.white.opacity(0.1),
                                    Color.white.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
            )
            .frame(maxWidth: 320)
            .scaleEffect(animateIn ? 1.0 : 0.7)
            .opacity(animateIn ? 1.0 : 0.0)
            .offset(y: animateIn ? 0 : 50)
        }
        .onAppear {
            // Entry animations
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                animateIn = true
            }
            
            withAnimation(.spring(response: 0.6, dampingFraction: 0.5).delay(0.1)) {
                iconScale = 1.0
            }
            
            withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
                confettiOffset = -15
            }
            
            // Pulse animation
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                pulseScale = 1.15
            }
            
            // Shimmer animation
            withAnimation(.linear(duration: 1.5).delay(0.3)) {
                shimmerOffset = 400
            }
            
            // Auto dismiss after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                dismissWithAnimation()
            }
        }
    }
    
    private func dismissWithAnimation() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            animateIn = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onDismiss()
        }
    }
}

// MARK: - View Extension for easy usage
extension View {
    func glassToast(
        isPresented: Binding<Bool>,
        type: ToastType,
        title: String,
        message: String
    ) -> some View {
        ZStack {
            self
            
            if isPresented.wrappedValue {
                GlassToast(
                    type: type,
                    title: title,
                    message: message
                ) {
                    isPresented.wrappedValue = false
                }
                .zIndex(9999) // Ensure it's on top of everything
                .transition(.opacity)
            }
        }
    }
    
    // Keep backwards compatibility with pixelAlert but use new style
    func pixelAlert(isPresented: Binding<Bool>, title: String, message: String) -> some View {
        let toastType: ToastType = {
            if title.uppercased().contains("SHOP") || title.uppercased().contains("BUNDLE") || title.uppercased().contains("DEAL") {
                return .purchased
            } else if title.uppercased().contains("INVENTORY") {
                return .placed
            } else {
                return .success
            }
        }()
        
        let displayTitle: String = {
            if title.uppercased().contains("SHOP") || title.uppercased().contains("BUNDLE") || title.uppercased().contains("DEAL") {
                return "Item Purchased!"
            } else if title.uppercased().contains("INVENTORY") {
                return "Item Placed!"
            } else {
                return title
            }
        }()
        
        return glassToast(
            isPresented: isPresented,
            type: toastType,
            title: displayTitle,
            message: message
        )
    }
}

// MARK: - Preview
#Preview("Purchased") {
    ZStack {
        Color.black.ignoresSafeArea()
        
        GlassToast(
            type: .purchased,
            title: "Item Purchased!",
            message: "Cozy Bed is now in your inventory!"
        ) {}
        .environmentObject(ThemeService.shared)
    }
}

#Preview("Placed") {
    ZStack {
        Color.black.ignoresSafeArea()
        
        GlassToast(
            type: .placed,
            title: "Item Placed!",
            message: "Cozy Bed has been placed in your room!"
        ) {}
        .environmentObject(ThemeService.shared)
    }
}
