//
//  FurnitureAnimationView.swift
//  Pixel Room Customizer
//
//  Animated furniture view with context-aware animations
//

import SwiftUI

struct FurnitureAnimationView: View {
    let imageName: String
    let itemName: String
    let size: CGSize
    
    @State private var glowOpacity: Double = 0.8
    @State private var swayRotation: Double = 0
    @State private var pulseScale: CGFloat = 1.0
    @State private var floatOffset: CGFloat = 0
    @State private var flickerOpacity: Double = 1.0
    @State private var tickRotation: Double = 0
    
    var body: some View {
        ZStack {
            // Glow effect for lights and electronics
            if shouldGlow {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size.width, height: size.height)
                    .blur(radius: 8)
                    .opacity(glowOpacity * 0.6)
                    .blendMode(.screen)
            }
            
            // Main furniture image
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: size.width, height: size.height)
                .rotationEffect(.degrees(animationRotation))
                .scaleEffect(animationScale)
                .offset(y: animationOffset)
                .opacity(animationOpacity)
        }
        .onAppear {
            startAnimations()
        }
    }
    
    // MARK: - Animation Properties
    
    private var shouldGlow: Bool {
        isLight || isElectronic
    }
    
    private var animationRotation: Double {
        if isPlant { return swayRotation }
        if isClock { return tickRotation }
        return 0
    }
    
    private var animationScale: CGFloat {
        if isElectronic || isLight { return pulseScale }
        return 1.0
    }
    
    private var animationOffset: CGFloat {
        if isFloating { return floatOffset }
        return 0
    }
    
    private var animationOpacity: Double {
        if isLight && shouldFlicker { return flickerOpacity }
        return 1.0
    }
    
    // MARK: - Item Type Detection
    
    private var isLight: Bool {
        let lightKeywords = ["lamp", "light", "lantern", "candle"]
        return lightKeywords.contains(where: { itemName.lowercased().contains($0) })
    }
    
    private var isPlant: Bool {
        let plantKeywords = ["plant", "fern", "cactus", "tree", "flower"]
        return plantKeywords.contains(where: { itemName.lowercased().contains($0) })
    }
    
    private var isElectronic: Bool {
        let electronicKeywords = ["tv", "computer", "pc", "screen", "monitor", "console", "game"]
        return electronicKeywords.contains(where: { itemName.lowercased().contains($0) })
    }
    
    private var isClock: Bool {
        itemName.lowercased().contains("clock")
    }
    
    private var isFloating: Bool {
        let floatingKeywords = ["balloon", "orb", "floating", "fairy"]
        return floatingKeywords.contains(where: { itemName.lowercased().contains($0) })
    }
    
    private var shouldFlicker: Bool {
        let flickerKeywords = ["candle", "lantern"]
        return flickerKeywords.contains(where: { itemName.lowercased().contains($0) })
    }
    
    // MARK: - Start Animations
    
    private func startAnimations() {
        if isLight {
            startGlowAnimation()
            if shouldFlicker {
                startFlickerAnimation()
            }
        }
        
        if isPlant {
            startSwayAnimation()
        }
        
        if isElectronic {
            startPulseAnimation()
            startGlowAnimation()
        }
        
        if isClock {
            startTickAnimation()
        }
        
        if isFloating {
            startFloatAnimation()
        }
    }
    
    // MARK: - Glow Animation (Lights & Electronics)
    
    private func startGlowAnimation() {
        withAnimation(
            .easeInOut(duration: 2.0)
            .repeatForever(autoreverses: true)
        ) {
            glowOpacity = 1.0
        }
    }
    
    // MARK: - Flicker Animation (Candles, Lanterns)
    
    private func startFlickerAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            withAnimation(.linear(duration: 0.05)) {
                flickerOpacity = Double.random(in: 0.85...1.0)
            }
        }
    }
    
    // MARK: - Sway Animation (Plants)
    
    private func startSwayAnimation() {
        withAnimation(
            .easeInOut(duration: 3.0)
            .repeatForever(autoreverses: true)
        ) {
            swayRotation = 3
        }
    }
    
    // MARK: - Pulse Animation (Electronics)
    
    private func startPulseAnimation() {
        withAnimation(
            .easeInOut(duration: 1.5)
            .repeatForever(autoreverses: true)
        ) {
            pulseScale = 1.02
        }
    }
    
    // MARK: - Tick Animation (Clocks)
    
    private func startTickAnimation() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            withAnimation(.linear(duration: 0.1)) {
                tickRotation += 6 // Small tick movement
            }
            
            // Reset after full rotation
            if tickRotation >= 360 {
                tickRotation = 0
            }
        }
    }
    
    // MARK: - Float Animation (Floating Objects)
    
    private func startFloatAnimation() {
        withAnimation(
            .easeInOut(duration: 2.5)
            .repeatForever(autoreverses: true)
        ) {
            floatOffset = -8
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black
        VStack(spacing: 30) {
            FurnitureAnimationView(
                imageName: "fur_extra_5",
                itemName: "Study Lamp",
                size: CGSize(width: 100, height: 100)
            )
            
            FurnitureAnimationView(
                imageName: "fur_extra_9",
                itemName: "Potted Fern",
                size: CGSize(width: 100, height: 100)
            )
            
            FurnitureAnimationView(
                imageName: "fur_extra_13",
                itemName: "Vintage TV",
                size: CGSize(width: 100, height: 100)
            )
        }
    }
}
