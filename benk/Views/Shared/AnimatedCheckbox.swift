//
//  AnimatedCheckbox.swift
//  benk
//
//  Created on 2025-12-11
//

import SwiftUI

struct AnimatedCheckbox: View {
    @Binding var isChecked: Bool
    let onToggle: () -> Void
    
    @EnvironmentObject var themeService: ThemeService
    @State private var checkmarkScale: CGFloat = 0.0
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            HapticManager.shared.light()
            withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
                isChecked.toggle()
                checkmarkScale = isChecked ? 1.0 : 0.0
            }
            onToggle()
        }) {
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: 8)
                    .fill(isChecked ? themeService.currentTheme.accent : Color.clear)
                    .frame(width: 26, height: 26)
                
                // Border
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        isChecked ? themeService.currentTheme.accent : themeService.currentTheme.textSecondary.opacity(0.5),
                        lineWidth: 2
                    )
                    .frame(width: 26, height: 26)
                
                // Checkmark
                Image(systemName: "checkmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .scaleEffect(isChecked ? 1.0 : 0.0)
                    .opacity(isChecked ? 1.0 : 0.0)
            }
            .scaleEffect(isPressed ? 0.85 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: isChecked)
        }
        .buttonStyle(PlainButtonStyle())
        .pressEvents {
            isPressed = true
        } onRelease: {
            isPressed = false
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var isChecked = false
        
        var body: some View {
            AnimatedCheckbox(isChecked: $isChecked) {
                print("Toggled")
            }
            .environmentObject(ThemeService.shared)
        }
    }
    
    return PreviewWrapper()
        .padding()
        .background(Color.black)
}
