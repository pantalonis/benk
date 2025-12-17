//
//  ThemedBackground.swift
//  benk
//
//  Created on 2025-12-11
//

import SwiftUI

struct ThemedBackground: View {
    let theme: AppTheme
    
    // Pre-computed screen dimensions to avoid layout passes
    private let screenWidth = UIScreen.main.bounds.width
    private let screenHeight = UIScreen.main.bounds.height
    
    var body: some View {
        ZStack {
            // Base gradient background
            theme.background
            
            // Theme-specific effects - all use fixed screen dimensions with explicit positioning
            if theme.hasStars {
                StarFieldEffect()
                    .frame(width: screenWidth, height: screenHeight)
                    .position(x: screenWidth / 2, y: screenHeight / 2)
            }
            
            if theme.hasCuteElements {
                SparkleEffect()
                    .frame(width: screenWidth, height: screenHeight)
                    .position(x: screenWidth / 2, y: screenHeight / 2)
            }
            
            if theme.hasScanline {
                ScanlineEffect()
                    .frame(width: screenWidth, height: screenHeight)
                    .position(x: screenWidth / 2, y: screenHeight / 2)
            }
            
            // Christmas effects
            if theme.hasSnow {
                SnowEffect()
                    .frame(width: screenWidth, height: screenHeight)
                    .position(x: screenWidth / 2, y: screenHeight / 2)
            }
            
            // Cloud effects - immersive floating clouds
            if theme.hasClouds {
                CloudEffect()
                    .frame(width: screenWidth, height: screenHeight)
                    .position(x: screenWidth / 2, y: screenHeight / 2)
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - Immersive Cloud Effect
struct CloudEffect: View {
    private let screenWidth = UIScreen.main.bounds.width
    private let screenHeight = UIScreen.main.bounds.height
    
    var body: some View {
        TimelineView(.animation(minimumInterval: 1/15)) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            
            ZStack {
                // Background layer clouds (slow, large, subtle)
                ForEach(0..<5, id: \.self) { index in
                    FloatingCloud(
                        config: CloudConfig.backgroundCloud(index: index, screenHeight: screenHeight),
                        screenWidth: screenWidth,
                        time: time
                    )
                }
                
                // Middle layer clouds (medium speed and size)
                ForEach(0..<5, id: \.self) { index in
                    FloatingCloud(
                        config: CloudConfig.middleCloud(index: index, screenHeight: screenHeight),
                        screenWidth: screenWidth,
                        time: time
                    )
                }
                
                // Foreground layer clouds (faster, smaller, more opaque)
                ForEach(0..<5, id: \.self) { index in
                    FloatingCloud(
                        config: CloudConfig.foregroundCloud(index: index, screenHeight: screenHeight),
                        screenWidth: screenWidth,
                        time: time
                    )
                }
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Cloud Configuration
struct CloudConfig {
    let width: CGFloat
    let height: CGFloat
    let opacity: Double
    let yPosition: CGFloat
    let cycleDuration: Double
    let startOffset: Double
    let blurRadius: CGFloat
    let shadowOpacity: Double
    
    static func backgroundCloud(index: Int, screenHeight: CGFloat) -> CloudConfig {
        let positions: [CGFloat] = [0.08, 0.25, 0.45, 0.65, 0.85]
        let widths: [CGFloat] = [220, 180, 200, 190, 170]
        let durations: [Double] = [70, 65, 75, 60, 80]
        let offsets: [Double] = [0.0, 0.35, 0.15, 0.55, 0.75]
        
        return CloudConfig(
            width: widths[index % widths.count],
            height: widths[index % widths.count] * 0.4,
            opacity: 0.35,
            yPosition: screenHeight * positions[index % positions.count],
            cycleDuration: durations[index % durations.count],
            startOffset: offsets[index % offsets.count],
            blurRadius: 8,
            shadowOpacity: 0.1
        )
    }
    
    static func middleCloud(index: Int, screenHeight: CGFloat) -> CloudConfig {
        let positions: [CGFloat] = [0.12, 0.30, 0.50, 0.70, 0.88]
        let widths: [CGFloat] = [150, 130, 160, 140, 120]
        let durations: [Double] = [50, 45, 55, 48, 52]
        let offsets: [Double] = [0.2, 0.6, 0.4, 0.8, 0.1]
        
        return CloudConfig(
            width: widths[index % widths.count],
            height: widths[index % widths.count] * 0.45,
            opacity: 0.55,
            yPosition: screenHeight * positions[index % positions.count],
            cycleDuration: durations[index % durations.count],
            startOffset: offsets[index % offsets.count],
            blurRadius: 4,
            shadowOpacity: 0.15
        )
    }
    
    static func foregroundCloud(index: Int, screenHeight: CGFloat) -> CloudConfig {
        let positions: [CGFloat] = [0.05, 0.22, 0.40, 0.58, 0.78]
        let widths: [CGFloat] = [100, 90, 110, 85, 95]
        let durations: [Double] = [30, 28, 35, 32, 26]
        let offsets: [Double] = [0.5, 0.1, 0.7, 0.3, 0.9]
        
        return CloudConfig(
            width: widths[index % widths.count],
            height: widths[index % widths.count] * 0.5,
            opacity: 0.75,
            yPosition: screenHeight * positions[index % positions.count],
            cycleDuration: durations[index % durations.count],
            startOffset: offsets[index % offsets.count],
            blurRadius: 1,
            shadowOpacity: 0.25
        )
    }
}

// MARK: - Floating Cloud View
struct FloatingCloud: View {
    let config: CloudConfig
    let screenWidth: CGFloat
    let time: TimeInterval
    
    var xPosition: CGFloat {
        let progress = (time / config.cycleDuration + config.startOffset).truncatingRemainder(dividingBy: 1.0)
        let totalDistance = screenWidth + config.width * 2
        return -config.width + (CGFloat(progress) * totalDistance)
    }
    
    var body: some View {
        CloudShape()
            .fill(
                LinearGradient(
                    colors: [
                        Color.white.opacity(config.opacity),
                        Color.white.opacity(config.opacity * 0.8)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: config.width, height: config.height)
            .blur(radius: config.blurRadius)
            .shadow(color: .white.opacity(config.shadowOpacity), radius: 15, x: 0, y: 8)
            .position(x: xPosition, y: config.yPosition)
    }
}

// MARK: - Cloud Shape
struct CloudShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        
        // Create a fluffy cloud shape using overlapping ellipses
        path.addEllipse(in: CGRect(x: width * 0.0, y: height * 0.45, width: width * 0.28, height: height * 0.5))
        path.addEllipse(in: CGRect(x: width * 0.15, y: height * 0.25, width: width * 0.32, height: height * 0.65))
        path.addEllipse(in: CGRect(x: width * 0.35, y: height * 0.15, width: width * 0.35, height: height * 0.75))
        path.addEllipse(in: CGRect(x: width * 0.55, y: height * 0.30, width: width * 0.30, height: height * 0.55))
        path.addEllipse(in: CGRect(x: width * 0.72, y: height * 0.40, width: width * 0.28, height: height * 0.48))
        
        return path
    }
}

#Preview {
    ThemedBackground(theme: CloudyDayTheme())
}
