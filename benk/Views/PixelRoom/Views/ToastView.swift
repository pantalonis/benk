//
//  ToastView.swift
//  Pixel Room Customizer
//
//  Toast notification system for user feedback
//

import SwiftUI

struct ToastView: View {
    let message: String
    let type: ToastType
    
    enum ToastType {
        case success
        case error
        case info
        case warning
        
        var icon: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .error: return "xmark.circle.fill"
            case .info: return "info.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .success: return .green
            case .error: return .red
            case .info: return .blue
            case .warning: return .orange
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: type.icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
            
            Text(message)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(2)
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(type.color)
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
        )
        .padding(.horizontal)
    }
}

// MARK: - Toast Modifier

struct ToastModifier: ViewModifier {
    @Binding var isShowing: Bool
    let message: String
    let type: ToastView.ToastType
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if isShowing {
                VStack {
                    ToastView(message: message, type: type)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                withAnimation {
                                    isShowing = false
                                }
                            }
                        }
                    
                    Spacer()
                }
                .zIndex(999)
            }
        }
    }
}

extension View {
    func toast(isShowing: Binding<Bool>, message: String, type: ToastView.ToastType = .info) -> some View {
        self.modifier(ToastModifier(isShowing: isShowing, message: message, type: type))
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        ToastView(message: "Purchase successful!", type: .success)
        ToastView(message: "Not enough coins!", type: .error)
        ToastView(message: "Item added to room", type: .info)
        ToastView(message: "Room is full!", type: .warning)
    }
    .padding()
    .background(Color.black)
}
