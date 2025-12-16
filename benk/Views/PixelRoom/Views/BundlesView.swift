//
//  BundlesView.swift
//  Pixel Room Customizer
//
//  View for browsing and purchasing item bundles
//

import SwiftUI

struct BundlesView: View {
    @StateObject private var shopManager = ShopManager.shared
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var currencyManager: CurrencyManager
    @Environment(\.dismiss) var dismiss
    
    // Alert state managed at view level for centered display
    @State private var showPurchaseAlert = false
    @State private var purchaseMessage = ""
    
    var body: some View {
        ZStack {
            themeManager.backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button {
                        SoundManager.shared.buttonTap()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(themeManager.secondaryText)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 4) {
                        Text("🎁 Bundles")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(themeManager.primaryText)
                        
                        Text("Save big with bundle deals!")
                            .font(.system(size: 12))
                            .foregroundColor(themeManager.secondaryText)
                    }
                    
                    Spacer()
                    
                    // Balance display
                    HStack(spacing: 4) {
                        Text("\(currencyManager.coins)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.yellow)
                        Text("💰")
                    }
                }
                .padding()
                
                // Bundles list
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(shopManager.availableBundles.filter { $0.isActive }) { bundle in
                            BundleCard(
                                bundle: bundle,
                                showPurchaseAlert: $showPurchaseAlert,
                                purchaseMessage: $purchaseMessage
                            )
                        }
                    }
                    .padding()
                }
            }
        }
        .pixelAlert(isPresented: $showPurchaseAlert, title: "BUNDLE", message: purchaseMessage)
    }
}

#Preview("BundlesView") {
    BundlesView()
        .environmentObject(ThemeManager())
        .environmentObject(CurrencyManager.shared)
}
