//
//  ParticleEffect.swift
//  benk
//
//  Created on 2025-12-11
//

import SwiftUI

struct Particle: Identifiable {
    let id: Int
    let position: CGPoint
    let baseOpacity: Double
    let blur: CGFloat
    let phase: Double
    let speed: Double
}

struct ParticleEffect: View {
    let particleCount: Int
    let color: Color
    let particleSize: CGFloat
    
    // Pre-generated particles at init time - no waiting for onAppear
    private let particles: [Particle]
    
    private let screenWidth = UIScreen.main.bounds.width
    private let screenHeight = UIScreen.main.bounds.height
    
    init(particleCount: Int = 20, color: Color = .white, particleSize: CGFloat = 2, seed: Int = 0) {
        self.particleCount = particleCount
        self.color = color
        self.particleSize = particleSize
        
        // Generate particles immediately at init with deterministic positions
        var rng = SeededRandomNumberGenerator(seed: UInt64(seed))
        let w = UIScreen.main.bounds.width
        let h = UIScreen.main.bounds.height
        
        self.particles = (0..<particleCount).map { index in
            Particle(
                id: index,
                position: CGPoint(
                    x: CGFloat.random(in: 0...w, using: &rng),
                    y: CGFloat.random(in: 0...h, using: &rng)
                ),
                baseOpacity: Double.random(in: 0.3...0.8, using: &rng),
                blur: CGFloat.random(in: 0...1.5, using: &rng),
                phase: Double.random(in: 0...(2 * .pi), using: &rng),
                speed: Double.random(in: 0.5...1.5, using: &rng)
            )
        }
    }
    
    var body: some View {
        TimelineView(.animation(minimumInterval: 0.1)) { timeline in
            Canvas { context, size in
                let time = timeline.date.timeIntervalSinceReferenceDate
                
                for particle in particles {
                    let animatedOpacity = particle.baseOpacity * (0.5 + 0.5 * sin(time * particle.speed + particle.phase))
                    
                    let rect = CGRect(
                        x: particle.position.x - particleSize / 2,
                        y: particle.position.y - particleSize / 2,
                        width: particleSize,
                        height: particleSize
                    )
                    
                    if particle.blur > 0 {
                        let blurLayers = 3
                        for i in 0..<blurLayers {
                            let scale = 1.0 + CGFloat(i) * particle.blur * 0.3
                            let layerOpacity = animatedOpacity / Double(i + 1)
                            let expandedRect = CGRect(
                                x: particle.position.x - (particleSize * scale) / 2,
                                y: particle.position.y - (particleSize * scale) / 2,
                                width: particleSize * scale,
                                height: particleSize * scale
                            )
                            context.fill(
                                Circle().path(in: expandedRect),
                                with: .color(color.opacity(layerOpacity))
                            )
                        }
                    } else {
                        context.fill(
                            Circle().path(in: rect),
                            with: .color(color.opacity(animatedOpacity))
                        )
                    }
                }
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Seeded Random Number Generator for deterministic positions
struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64
    
    init(seed: UInt64) {
        self.state = seed == 0 ? 1 : seed
    }
    
    mutating func next() -> UInt64 {
        // Simple xorshift algorithm
        state ^= state << 13
        state ^= state >> 7
        state ^= state << 17
        return state
    }
}

// MARK: - Optimized Star Field Effect
struct StarFieldEffect: View {
    var body: some View {
        ZStack {
            ParticleEffect(particleCount: 20, color: .white, particleSize: 1.5, seed: 100)
            ParticleEffect(particleCount: 12, color: .white.opacity(0.6), particleSize: 1, seed: 200)
            ParticleEffect(particleCount: 8, color: .white.opacity(0.4), particleSize: 0.5, seed: 300)
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Optimized Sparkle Effect
struct SparkleEffect: View {
    var body: some View {
        ZStack {
            ParticleEffect(particleCount: 10, color: .yellow, particleSize: 3, seed: 400)
            ParticleEffect(particleCount: 5, color: .pink.opacity(0.7), particleSize: 2, seed: 500)
        }
        .allowsHitTesting(false)
    }
}
