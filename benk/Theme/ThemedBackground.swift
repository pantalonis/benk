//
//  ThemedBackground.swift
//  benk
//
//  Created on 2025-12-11
//

import SwiftUI

struct ThemedBackground: View {
    let theme: AppTheme
    
    var body: some View {
        ZStack {
            // Base gradient background
            theme.background
                .ignoresSafeArea()
            
            // Theme-specific effects
            if theme.hasStars {
                StarFieldEffect()
                    .ignoresSafeArea()
            }
            
            if theme.hasCuteElements {
                SparkleEffect()
                    .ignoresSafeArea()
            }
            
            if theme.hasScanline {
                ScanlineEffect()
                    .ignoresSafeArea()
            }
            
            // Christmas effects
            if theme.hasSnow {
                SnowEffect()
                    .ignoresSafeArea()
            }
        }
    }
}

#Preview {
    ThemedBackground(theme: SpaceTheme())
}
