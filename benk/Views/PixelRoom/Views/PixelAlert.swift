//
//  PixelAlert.swift
//  Pixel Room Customizer
//
//  Custom pixel-art style alert view
//

import SwiftUI

struct PixelAlert: View {
    let title: String
    let message: String
    let onDismiss: () -> Void
    
    @State private var animateIn = false
    
    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }
            
            // Alert Box
            VStack(spacing: 20) {
                // Title
                Text(title)
                    .font(.custom("Courier-Bold", size: 24))
                    .foregroundColor(.yellow)
                    .shadow(color: .black, radius: 0, x: 2, y: 2)
                
                // Divider
                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(height: 2)
                
                // Message
                Text(message)
                    .font(.custom("Courier", size: 16))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Button
                Button(action: {
                    SoundManager.shared.buttonTap()
                    onDismiss()
                }) {
                    Text("OK")
                        .font(.custom("Courier-Bold", size: 18))
                        .foregroundColor(.black)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 10)
                        .background(Color.yellow)
                        .cornerRadius(0) // Sharp corners for pixel feel
                        .overlay(
                            Rectangle()
                                .stroke(Color.white, lineWidth: 2)
                        )
                }
                .padding(.top, 10)
            }
            .padding(25)
            .background(
                ZStack {
                    // Main background
                    Color(red: 0.2, green: 0.18, blue: 0.25)
                    
                    // Pixel border effect
                    Rectangle()
                        .strokeBorder(Color.white, lineWidth: 4)
                    
                    Rectangle()
                        .strokeBorder(Color.black, lineWidth: 2)
                        .padding(2)
                }
            )
            .frame(maxWidth: 300)
            .scaleEffect(animateIn ? 1.0 : 0.8)
            .opacity(animateIn ? 1.0 : 0.0)
            .onAppear {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    animateIn = true
                }
            }
        }
    }
}

extension View {
    func pixelAlert(isPresented: Binding<Bool>, title: String, message: String) -> some View {
        ZStack {
            self
            
            if isPresented.wrappedValue {
                PixelAlert(title: title, message: message) {
                    withAnimation {
                        isPresented.wrappedValue = false
                    }
                }
                .zIndex(1000) // Ensure it's on top
            }
        }
    }
}
