//
//  Extensions.swift
//  benk
//
//  Created on 2025-12-11
//

import SwiftUI

// MARK: - View Extensions
extension View {
    /// Apply glass morphism effect
    func glassCard(padding: CGFloat = 16, cornerRadius: CGFloat = 20) -> some View {
        self
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(
                                LinearGradient(
                                    colors: [.white.opacity(0.3), .white.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
    
    /// Apply glow effect
    func glowEffect(color: Color, radius: CGFloat = 10, opacity: Double = 0.6) -> some View {
        self
            .shadow(color: color.opacity(opacity), radius: radius, x: 0, y: 0)
            .shadow(color: color.opacity(opacity * 0.5), radius: radius * 2, x: 0, y: 0)
    }
    
    /// Apply pulsing animation
    func pulsingEffect(duration: Double = 1.5) -> some View {
        self.modifier(PulsingModifier(duration: duration))
    }
    
    /// Handle press and release events for buttons
    func pressEvents(onPress: @escaping (() -> Void), onRelease: @escaping (() -> Void)) -> some View {
        self.modifier(PressActions(onPress: onPress, onRelease: onRelease))
    }
}

struct PulsingModifier: ViewModifier {
    let duration: Double
    @State private var scale: CGFloat = 1.0
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: duration)
                    .repeatForever(autoreverses: true)
                ) {
                    scale = 1.1
                }
            }
    }
}

struct PressActions: ViewModifier {
    var onPress: () -> Void
    var onRelease: () -> Void
    
    @State private var isPressed = false
    
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isPressed {
                            isPressed = true
                            onPress()
                        }
                    }
                    .onEnded { _ in
                        isPressed = false
                        onRelease()
                    }
            )
    }
}

// MARK: - Date Extensions
extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
    
    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }
    
    func daysFrom(_ date: Date) -> Int {
        Calendar.current.dateComponents([.day], from: date.startOfDay, to: self.startOfDay).day ?? 0
    }
}

// MARK: - Double Extensions
extension Double {
    func formatted(decimals: Int = 1) -> String {
        String(format: "%.\(decimals)f", self)
    }
}

// MARK: - Int Extensions  
extension Int {
    var minutesFormatted: String {
        let hours = self / 60
        let minutes = self % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    /// Format seconds as HH:mm:ss
    var timeFormatted: String {
        let hours = self / 3600
        let minutes = (self % 3600) / 60
        let seconds = self % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    /// Format minutes as HH:mm:ss (assuming 00 seconds)
    var minutesAsTimeFormatted: String {
        let hours = self / 60
        let minutes = self % 60
        return String(format: "%02d:%02d:00", hours, minutes)
    }
}

// MARK: - TextEditor Placeholder Extension
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .topLeading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
