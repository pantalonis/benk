//
//  ConfirmationDialog.swift
//  Pixel Room Customizer
//
//  Reusable confirmation dialog for destructive actions
//

import SwiftUI

struct ConfirmationDialogView: View {
    let title: String
    let message: String
    let confirmText: String
    let cancelText: String
    let confirmAction: () -> Void
    let cancelAction: () -> Void
    let isDestructive: Bool
    
    @EnvironmentObject var themeManager: ThemeManager
    
    init(
        title: String,
        message: String,
        confirmText: String = "Confirm",
        cancelText: String = "Cancel",
        isDestructive: Bool = false,
        confirmAction: @escaping () -> Void,
        cancelAction: @escaping () -> Void
    ) {
        self.title = title
        self.message = message
        self.confirmText = confirmText
        self.cancelText = cancelText
        self.isDestructive = isDestructive
        self.confirmAction = confirmAction
        self.cancelAction = cancelAction
    }
    
    var body: some View {
        ZStack {
            // Backdrop
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    cancelAction()
                }
            
            // Dialog
            VStack(spacing: 20) {
                // Title
                Text(title)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(themeManager.primaryText)
                
                // Message
                Text(message)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(themeManager.secondaryText)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Buttons
                HStack(spacing: 12) {
                    // Cancel
                    Button(action: {
                        HapticManager.shared.light()
                        cancelAction()
                    }) {
                        Text(cancelText)
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(themeManager.primaryText)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(themeManager.cardBackground)
                            )
                    }
                    
                    // Confirm
                    Button(action: {
                        HapticManager.shared.medium()
                        confirmAction()
                    }) {
                        Text(confirmText)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(
                                        isDestructive ?
                                        LinearGradient(
                                            colors: [Color.red, Color.red.opacity(0.8)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ) :
                                        themeManager.primaryGradient
                                    )
                            )
                    }
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(themeManager.secondaryBackground)
                    .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
            )
            .padding(.horizontal, 40)
        }
    }
}

// MARK: - Preview

#Preview {
    ConfirmationDialogView(
        title: "Remove Item?",
        message: "Are you sure you want to remove this item from your room? It will be returned to your inventory.",
        confirmText: "Remove",
        cancelText: "Cancel",
        isDestructive: true,
        confirmAction: {},
        cancelAction: {}
    )
    .environmentObject(ThemeManager())
}
