//
//  PixelButton.swift
//  Pixel Room Customizer
//
//  Custom pixel-styled button component
//

import SwiftUI

struct PixelButton: View {
    let title: String
    let icon: String?
    let gradient: LinearGradient
    let action: () -> Void
    var isDisabled: Bool = false
    
    @State private var isPressed = false
    
    init(
        title: String,
        icon: String? = nil,
        gradient: LinearGradient,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.gradient = gradient
        self.isDisabled = isDisabled
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            if !isDisabled {
                action()
            }
        }) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }
                
                Text(title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        isDisabled ? 
                        LinearGradient(
                            colors: [Color.gray.opacity(0.3)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ) : 
                        gradient
                    )
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .opacity(isDisabled ? 0.5 : 1.0)
        }
        .disabled(isDisabled)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isDisabled {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
    }
}

struct PixelCard: View {
    @EnvironmentObject var themeManager: ThemeManager
    var content: AnyView
    
    init<Content: View>(@ViewBuilder content: () -> Content) {
        self.content = AnyView(content())
    }
    
    var body: some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(themeManager.cardBackground)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
            )
    }
}
