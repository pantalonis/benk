//
//  ParticleEffect.swift
//  benk
//
//  Created on 2025-12-11
//

import SwiftUI

struct Particle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var baseOpacity: Double
    var blur: CGFloat
    var phase: Double // For animation timing
    var speed: Double // Animation speed multiplier
}

struct ParticleEffect: View {
    let particleCount: Int
    let color: Color
    let particleSize: CGFloat
    
    @State private var particles: [Particle] = []
    @State private var canvasSize: CGSize = .zero
    
    init(particleCount: Int = 20, color: Color = .white, particleSize: CGFloat = 2) {
        self.particleCount = particleCount
        self.color = color
        self.particleSize = particleSize
    }
    
    var body: some View {
        GeometryReader { geometry in
            TimelineView(.animation(minimumInterval: 0.05)) { timeline in
                Canvas { context, size in
                    let time = timeline.date.timeIntervalSinceReferenceDate
                    
                    for particle in particles {
                        // Calculate animated opacity using sine wave
                        let animatedOpacity = particle.baseOpacity * (0.5 + 0.5 * sin(time * particle.speed + particle.phase))
                        
                        // Draw particle
                        let rect = CGRect(
                            x: particle.position.x - particleSize / 2,
                            y: particle.position.y - particleSize / 2,
                            width: particleSize,
                            height: particleSize
                        )
                        
                        // Apply blur by drawing multiple circles with decreasing opacity
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
            .onAppear {
                generateParticles(in: geometry.size)
            }
            .onChange(of: geometry.size) { _, newSize in
                if canvasSize != newSize {
                    canvasSize = newSize
                    generateParticles(in: newSize)
                }
            }
        }
    }
    
    private func generateParticles(in size: CGSize) {
        guard size.width > 0 && size.height > 0 else { return }
        canvasSize = size
        
        particles = (0..<particleCount).map { _ in
            Particle(
                position: CGPoint(
                    x: CGFloat.random(in: 0...size.width),
                    y: CGFloat.random(in: 0...size.height)
                ),
                baseOpacity: Double.random(in: 0.3...0.8),
                blur: CGFloat.random(in: 0...1.5),
                phase: Double.random(in: 0...(2 * .pi)),
                speed: Double.random(in: 0.5...1.5)
            )
        }
    }
}

// MARK: - Optimized Star Field Effect (reduced from 100 to 40 particles)
struct StarFieldEffect: View {
    var body: some View {
        ZStack {
            ParticleEffect(particleCount: 20, color: .white, particleSize: 1.5)
            ParticleEffect(particleCount: 12, color: .white.opacity(0.6), particleSize: 1)
            ParticleEffect(particleCount: 8, color: .white.opacity(0.4), particleSize: 0.5)
        }
    }
}

// MARK: - Optimized Sparkle Effect (reduced from 25 to 15 particles)
struct SparkleEffect: View {
    var body: some View {
        ZStack {
            ParticleEffect(particleCount: 10, color: .yellow, particleSize: 3)
            ParticleEffect(particleCount: 5, color: .pink.opacity(0.7), particleSize: 2)
        }
    }
}
