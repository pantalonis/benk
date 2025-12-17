//
//  SnowEffect.swift
//  benk
//
//  Created on 2025-12-15
//

import SwiftUI

struct SnowEffect: View {
    @State private var snowflakes: [Snowflake]
    @State private var accumulatedSnow: [AccumulatedSnowflake] = []
    
    private let screenWidth = UIScreen.main.bounds.width
    private let screenHeight = UIScreen.main.bounds.height
    
    struct Snowflake: Identifiable {
        let id: Int
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
    
    init() {
        // Generate snowflakes at init time with deterministic positions
        var rng = SeededRandomNumberGenerator(seed: 12345)
        let w = UIScreen.main.bounds.width
        let h = UIScreen.main.bounds.height
        
        var flakes: [Snowflake] = []
        for i in 0..<60 {
            let flake = Snowflake(
                id: i,
                x: CGFloat.random(in: 0...w, using: &rng),
                y: CGFloat.random(in: -50...h, using: &rng),
                size: CGFloat.random(in: 2...6, using: &rng),
                speed: CGFloat.random(in: 1...3, using: &rng),
                opacity: Double.random(in: 0.4...1.0, using: &rng),
                wobbleAmount: CGFloat.random(in: 5...15, using: &rng),
                wobblePhase: CGFloat.random(in: 0...(.pi * 2), using: &rng)
            )
            flakes.append(flake)
        }
        _snowflakes = State(initialValue: flakes)
    }
    
    var body: some View {
        TimelineView(.animation(minimumInterval: 0.05)) { timeline in
            Canvas { context, size in
                // Draw falling snowflakes
                for flake in snowflakes {
                    let wobble = sin(flake.wobblePhase) * flake.wobbleAmount
                    let x = flake.x + wobble
                    let y = flake.y
                    
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
                    let y = screenHeight - snow.size / 2
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
                    path.move(to: CGPoint(x: 0, y: screenHeight))
                    
                    for x in stride(from: 0, to: screenWidth + 20, by: 20) {
                        let waveHeight = sin(x * 0.1) * 5 + snowPileHeight
                        path.addLine(to: CGPoint(x: x, y: screenHeight - waveHeight))
                    }
                    path.addLine(to: CGPoint(x: screenWidth, y: screenHeight))
                    path.closeSubpath()
                    
                    context.opacity = 0.95
                    context.fill(path, with: .color(.white))
                }
            }
            .onChange(of: timeline.date) { _, _ in
                updateSnowflakes()
            }
        }
        .allowsHitTesting(false)
    }
    
    private func updateSnowflakes() {
        for i in snowflakes.indices {
            snowflakes[i].y += snowflakes[i].speed
            snowflakes[i].wobblePhase += 0.1
            
            if snowflakes[i].y > screenHeight - 20 {
                if Bool.random() && accumulatedSnow.count < 200 {
                    accumulatedSnow.append(AccumulatedSnowflake(
                        x: snowflakes[i].x,
                        size: snowflakes[i].size * 0.8
                    ))
                }
                
                snowflakes[i].y = -10
                snowflakes[i].x = CGFloat.random(in: 0...screenWidth)
            }
        }
        
        if accumulatedSnow.count > 150 && Bool.random() {
            accumulatedSnow.removeFirst()
        }
    }
}

// Seeded RNG is in ParticleEffect.swift

#Preview {
    ZStack {
        Color.black.opacity(0.9)
        SnowEffect()
    }
    .ignoresSafeArea()
}
