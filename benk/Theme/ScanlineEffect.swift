//
//  ScanlineEffect.swift
//  benk
//
//  Created on 2025-12-11
//

import SwiftUI

struct ScanlineEffect: View {
    var body: some View {
        TimelineView(.animation(minimumInterval: 0.033)) { timeline in
            Canvas { context, size in
                // Calculate animated offset (cycles every 2 seconds, moves 4 pixels)
                let time = timeline.date.timeIntervalSinceReferenceDate
                let cyclePosition = time.truncatingRemainder(dividingBy: 2.0) / 2.0
                let offset = cyclePosition * 4.0
                
                // Draw scanlines efficiently in a single pass
                let lineHeight: CGFloat = 2
                let spacing: CGFloat = 4
                var y = offset
                
                while y < size.height + spacing {
                    let rect = CGRect(x: 0, y: y, width: size.width, height: lineHeight)
                    context.fill(Path(rect), with: .color(.white.opacity(0.03)))
                    y += spacing
                }
            }
        }
        .allowsHitTesting(false)
    }
}
