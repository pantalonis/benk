//
//  SantaEffect.swift
//  benk
//
//  Created on 2025-12-15
//

import SwiftUI

struct SantaEffect: View {
    @State private var santaX: CGFloat = -200
    @State private var santaY: CGFloat = 100
    @State private var isFlying = false
    @State private var showSanta = false
    @State private var bobOffset: CGFloat = 0
    
    let timer = Timer.publish(every: 30, on: .main, in: .common).autoconnect() // Santa appears every 30 seconds
    
    var body: some View {
        GeometryReader { geometry in
            if showSanta {
                ZStack {
                    // Santa's sleigh with reindeer
                    HStack(spacing: -10) {
                        // Reindeer
                        Text("🦌")
                            .font(.system(size: 30))
                            .offset(y: bobOffset * 0.8)
                        
                        Text("🦌")
                            .font(.system(size: 28))
                            .offset(y: -bobOffset * 0.6)
                        
                        // Sleigh with Santa
                        ZStack {
                            Text("🛷")
                                .font(.system(size: 35))
                            Text("🎅")
                                .font(.system(size: 28))
                                .offset(x: 5, y: -15)
                        }
                        .offset(y: bobOffset)
                        
                        // Gift trail
                        if santaX > 100 {
                            Text("🎁")
                                .font(.system(size: 16))
                                .offset(x: -30, y: 20 + bobOffset * 2)
                                .opacity(0.8)
                        }
                    }
                    .scaleEffect(x: -1, y: 1) // Flip horizontally so Santa faces right
                    .position(x: santaX, y: santaY + bobOffset)
                    .shadow(color: .white.opacity(0.5), radius: 10)
                }
            }
        }
        .allowsHitTesting(false)
        .onAppear {
            // Initial delay before first Santa
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                triggerSanta()
            }
        }
        .onReceive(timer) { _ in
            if !isFlying {
                triggerSanta()
            }
        }
        .onChange(of: isFlying) { _, flying in
            if flying {
                withAnimation(.linear(duration: 0.3).repeatForever(autoreverses: true)) {
                    bobOffset = 8
                }
            }
        }
    }
    
    private func triggerSanta() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        // Random Y position in top third of screen
        santaY = CGFloat.random(in: 80...(screenHeight * 0.35))
        santaX = -200
        showSanta = true
        isFlying = true
        bobOffset = 0
        
        // Animate Santa across screen
        withAnimation(.linear(duration: 8)) {
            santaX = screenWidth + 200
        }
        
        // Hide Santa after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 8.5) {
            showSanta = false
            isFlying = false
            bobOffset = 0
        }
    }
}

// Christmas decorations for glass cards
struct ChristmasDecorations: View {
    var body: some View {
        GeometryReader { geometry in
            // Holly in corners
            VStack {
                HStack {
                    Text("🎄")
                        .font(.system(size: 14))
                        .opacity(0.6)
                    Spacer()
                    Text("⭐")
                        .font(.system(size: 12))
                        .opacity(0.5)
                }
                Spacer()
            }
            .padding(8)
        }
        .allowsHitTesting(false)
    }
}

// Christmas lights effect (subtle twinkling border)
struct ChristmasLightsEffect: View {
    @State private var phase: CGFloat = 0
    
    var body: some View {
        TimelineView(.animation(minimumInterval: 0.5)) { timeline in
            GeometryReader { geometry in
                Canvas { context, size in
                    let colors: [Color] = [.red, .green, .yellow, .blue, .red, .green, .yellow, .blue]
                    let lightCount = Int(size.width / 30)
                    
                    for i in 0..<lightCount {
                        let x = CGFloat(i) * 30 + 15
                        let colorIndex = (i + Int(phase)) % colors.count
                        let isOn = (i + Int(phase)) % 3 != 0
                        
                        if isOn {
                            // Glow
                            context.opacity = 0.5
                            context.fill(
                                Circle().path(in: CGRect(x: x - 6, y: -3, width: 12, height: 12)),
                                with: .color(colors[colorIndex].opacity(0.5))
                            )
                            // Light
                            context.opacity = 1.0
                            context.fill(
                                Circle().path(in: CGRect(x: x - 4, y: -1, width: 8, height: 8)),
                                with: .color(colors[colorIndex])
                            )
                        } else {
                            context.opacity = 0.3
                            context.fill(
                                Circle().path(in: CGRect(x: x - 3, y: 0, width: 6, height: 6)),
                                with: .color(.gray)
                            )
                        }
                    }
                }
            }
            .onChange(of: timeline.date) { _, _ in
                phase += 1
            }
        }
        .frame(height: 10)
        .allowsHitTesting(false)
    }
}

#Preview {
    ZStack {
        Color.black.opacity(0.9)
        SantaEffect()
    }
    .ignoresSafeArea()
}


