//
//  GlassCard.swift
//  benk
//
//  Created on 2025-12-11
//

import SwiftUI

struct GlassCard<Content: View>: View {
    let content: Content
    let padding: CGFloat
    let cornerRadius: CGFloat
    
    @EnvironmentObject var themeService: ThemeService
    
    init(
        padding: CGFloat = 16,
        cornerRadius: CGFloat = 24,
        @ViewBuilder content: () -> Content
    ) {
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(glassBackground)
        // Removed compositingGroup() - it forces expensive offscreen rendering
        // For complex animated content, use .drawingGroup(opaque: false) at the call site instead
    }
    
    private var glassBackground: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(.ultraThinMaterial)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.08),
                                Color.white.opacity(0.02)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.4),
                                Color.white.opacity(0.1),
                                Color.white.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.5
                    )
            )
            .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
    }
}

// MARK: - Animated Appearance Modifier
struct AnimatedAppearance: ViewModifier {
    let delay: Double
    @State private var isVisible = false
    
    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 12)
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(delay)) {
                    isVisible = true
                }
            }
    }
}

extension View {
    func animatedAppearance(delay: Double = 0) -> some View {
        modifier(AnimatedAppearance(delay: delay))
    }
}

#Preview {
    GlassCard {
        Text("Glass Card Content")
            .foregroundColor(.white)
    }
    .environmentObject(ThemeService.shared)
    .background(Color.black)
}
