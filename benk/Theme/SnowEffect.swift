//
//  SnowEffect.swift
//  benk
//
//  Created on 2025-12-15
//

import SwiftUI

struct SnowEffect: View {
    @State private var snowflakes: [Snowflake] = []
    @State private var accumulatedSnow: [AccumulatedSnowflake] = []
    
    struct Snowflake: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        let size: CGFloat
        let speed: CGFloat
        let opacity: Double
        let wobbleAmount: CGFloat
        var wobblePhase: CGFloat
    }
    
    struct AccumulatedSnowflake: Identifiable {
        let id = UUID()
        let x: CGFloat
        let size: CGFloat
    }
    
    var body: some View {
        TimelineView(.animation(minimumInterval: 0.03)) { timeline in
            Canvas { context, size in
                // Draw falling snowflakes
                for flake in snowflakes {
                    let wobble = sin(flake.wobblePhase) * flake.wobbleAmount
                    let x = flake.x + wobble
                    let y = flake.y
                    
                    // Draw snowflake with glow
                    let center = CGPoint(x: x, y: y)
                    
                    // Outer glow
                    context.opacity = flake.opacity * 0.3
                    context.fill(
                        Circle().path(in: CGRect(
                            x: center.x - flake.size * 1.5,
                            y: center.y - flake.size * 1.5,
                            width: flake.size * 3,
                            height: flake.size * 3
                        )),
                        with: .color(.white.opacity(0.3))
                    )
                    
                    // Main snowflake
                    context.opacity = flake.opacity
                    context.fill(
                        Circle().path(in: CGRect(
                            x: center.x - flake.size / 2,
                            y: center.y - flake.size / 2,
                            width: flake.size,
                            height: flake.size
                        )),
                        with: .color(.white)
                    )
                }
                
                // Draw accumulated snow at bottom
                for snow in accumulatedSnow {
                    let y = size.height - snow.size / 2
                    context.opacity = 0.9
                    context.fill(
                        Circle().path(in: CGRect(
                            x: snow.x - snow.size / 2,
                            y: y - snow.size / 2,
                            width: snow.size,
                            height: snow.size
                        )),
                        with: .color(.white)
                    )
                }
                
                // Snow pile at bottom
                let snowPileHeight: CGFloat = min(CGFloat(accumulatedSnow.count) * 0.15, 30)
                if snowPileHeight > 0 {
                    var path = Path()
                    path.move(to: CGPoint(x: 0, y: size.height))
                    
                    // Create wavy snow pile
                    for x in stride(from: 0, to: size.width + 20, by: 20) {
                        let waveHeight = sin(x * 0.1) * 5 + snowPileHeight
                        path.addLine(to: CGPoint(x: x, y: size.height - waveHeight))
                    }
                    path.addLine(to: CGPoint(x: size.width, y: size.height))
                    path.closeSubpath()
                    
                    context.opacity = 0.95
                    context.fill(path, with: .color(.white))
                }
            }
            .onChange(of: timeline.date) { _, _ in
                updateSnowflakes()
            }
        }
        .onAppear {
            initializeSnowflakes()
        }
        .allowsHitTesting(false)
    }
    
    private func initializeSnowflakes() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        // Create initial snowflakes
        for _ in 0..<60 {
            let flake = Snowflake(
                x: CGFloat.random(in: 0...screenWidth),
                y: CGFloat.random(in: -50...screenHeight),
                size: CGFloat.random(in: 2...6),
                speed: CGFloat.random(in: 1...3),
                opacity: Double.random(in: 0.4...1.0),
                wobbleAmount: CGFloat.random(in: 5...15),
                wobblePhase: CGFloat.random(in: 0...(.pi * 2))
            )
            snowflakes.append(flake)
        }
    }
    
    private func updateSnowflakes() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        for i in snowflakes.indices {
            // Move snowflake down
            snowflakes[i].y += snowflakes[i].speed
            snowflakes[i].wobblePhase += 0.1
            
            // Check if reached bottom
            if snowflakes[i].y > screenHeight - 20 {
                // Add to accumulated snow (with some probability)
                if Bool.random() && accumulatedSnow.count < 200 {
                    accumulatedSnow.append(AccumulatedSnowflake(
                        x: snowflakes[i].x,
                        size: snowflakes[i].size * 0.8
                    ))
                }
                
                // Reset to top
                snowflakes[i].y = -10
                snowflakes[i].x = CGFloat.random(in: 0...screenWidth)
            }
        }
        
        // Slowly melt accumulated snow
        if accumulatedSnow.count > 150 && Bool.random() {
            accumulatedSnow.removeFirst()
        }
    }
}

#Preview {
    ZStack {
        Color.black.opacity(0.9)
        SnowEffect()
    }
    .ignoresSafeArea()
}


