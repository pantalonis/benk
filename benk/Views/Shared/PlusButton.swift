//
//  PlusButton.swift
//  benk
//
//  Created on 2025-12-15
//

import SwiftUI

struct PlusButton: View {
    @Binding var isExpanded: Bool
    @EnvironmentObject var themeService: ThemeService
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                isExpanded.toggle()
            }
            HapticManager.shared.selection()
        }) {
            ZStack {
                // Dark background circle
                Circle()
                    .fill(Color.black)
                    .frame(width: 64, height: 64)
                    .shadow(color: .black.opacity(0.3), radius: 12, x: 0, y: 6)
                
                // Icon - rotates between + and x
                Image(systemName: isExpanded ? "xmark" : "plus")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(isExpanded ? 45 : 0))
            }
            .scaleEffect(isPressed ? 0.92 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .pressEvents {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                isPressed = true
            }
        } onRelease: {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                isPressed = false
            }
        }
    }
}

#Preview {
    @Previewable @State var isExpanded = false
    
    ZStack {
        Color.gray.ignoresSafeArea()
        PlusButton(isExpanded: $isExpanded)
    }
    .environmentObject(ThemeService.shared)
}
