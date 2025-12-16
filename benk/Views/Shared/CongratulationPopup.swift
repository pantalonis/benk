
import SwiftUI

struct CongratulationPopup: View {
    @EnvironmentObject var themeService: ThemeService
    
    var body: some View {
        ZStack {
            // Background blur
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .frame(width: 200, height: 120)
                .shadow(color: themeService.currentTheme.glow.opacity(0.3), radius: 20, x: 0, y: 10)
            
            // Content
            VStack(spacing: 12) {
                Image(systemName: "star.fill")
                    .font(.system(size: 40))
                    .foregroundColor(themeService.currentTheme.accent)
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    .animation(.spring(response: 0.6, dampingFraction: 0.6).repeatForever(autoreverses: false), value: isAnimating)
                
                Text("Task Completed!")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(themeService.currentTheme.text)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(themeService.currentTheme.accent.opacity(0.5), lineWidth: 1)
        )
        .onAppear {
            isAnimating = true
        }
    }
    
    @State private var isAnimating = false
}

#Preview {
    CongratulationPopup()
        .environmentObject(ThemeService.shared)
        .padding()
        .background(Color.black)
}
