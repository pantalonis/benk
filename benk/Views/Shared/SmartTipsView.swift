//
//  SmartTipsView.swift
//  benk
//
//  Created on 2025-12-11
//

import SwiftUI

struct SmartTipsView: View {
    @EnvironmentObject var themeService: ThemeService
    @State private var currentTipIndex = 0
    @State private var isDismissed = false
    
    let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        if !isDismissed {
            GlassCard(padding: 12) {
                HStack(spacing: 12) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(themeService.currentTheme.accent)
                        .font(.title3)
                    
                    Text(Constants.smartTips[currentTipIndex])
                        .font(.footnote)
                        .foregroundColor(themeService.currentTheme.text)
                        .lineLimit(2)
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            isDismissed = true
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(themeService.currentTheme.textSecondary)
                            .font(.title3)
                    }
                }
            }
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .onReceive(timer) { _ in
                withAnimation {
                    currentTipIndex = (currentTipIndex + 1) % Constants.smartTips.count
                }
            }
        }
    }
}

#Preview {
    SmartTipsView()
        .padding()
        .environmentObject(ThemeService.shared)
        .background(Color.black)
}
