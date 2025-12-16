//
//  PetAnimationView.swift
//  Pixel Room Customizer
//
//  Animated pet view with breathing, bobbing, and idle animations
//

import SwiftUI

struct PetAnimationView: View {
    let imageName: String
    let size: CGSize
    
    @State private var breathingScale: CGFloat = 1.0
    @State private var bobbingOffset: CGFloat = 0
    @State private var wiggleRotation: Double = 0
    @State private var blinkOpacity: Double = 1.0
    
    var body: some View {
        ZStack {
            // Main pet image
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: size.width, height: size.height)
                .scaleEffect(breathingScale)
                .offset(y: bobbingOffset)
                .rotationEffect(.degrees(wiggleRotation))
                .opacity(blinkOpacity)
        }
        .onAppear {
            startBreathingAnimation()
            startBobbingAnimation()
            startWiggleAnimation()
            startBlinkAnimation()
        }
    }
    
    // MARK: - Breathing Animation
    
    private func startBreathingAnimation() {
        withAnimation(
            .easeInOut(duration: 2.0)
            .repeatForever(autoreverses: true)
        ) {
            breathingScale = 1.05
        }
    }
    
    // MARK: - Bobbing Animation
    
    private func startBobbingAnimation() {
        withAnimation(
            .easeInOut(duration: 1.5)
            .repeatForever(autoreverses: true)
        ) {
            bobbingOffset = -3
        }
    }
    
    // MARK: - Wiggle Animation
    
    private func startWiggleAnimation() {
        // Random wiggle every few seconds
        Timer.scheduledTimer(withTimeInterval: Double.random(in: 3...6), repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.3)) {
                wiggleRotation = Double.random(in: -5...5)
            }
            
            // Return to center
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    wiggleRotation = 0
                }
            }
        }
    }
    
    // MARK: - Blink Animation
    
    private func startBlinkAnimation() {
        // Random blink every 3-7 seconds
        Timer.scheduledTimer(withTimeInterval: Double.random(in: 3...7), repeats: true) { _ in
            // Quick blink
            withAnimation(.linear(duration: 0.1)) {
                blinkOpacity = 0.3
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.linear(duration: 0.1)) {
                    blinkOpacity = 1.0
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black
        PetAnimationView(imageName: "pet_1", size: CGSize(width: 100, height: 100))
    }
}
