//
//  EnhancedShopViews.swift
//  Pixel Room Customizer
//
//  UI components for sales, bundles, and coin earning
//

import SwiftUI

// MARK: - Daily Deal Banner

struct DailyDealBanner: View {
    @StateObject private var shopManager = ShopManager.shared
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var currencyManager: CurrencyManager
    @EnvironmentObject var inventoryManager: InventoryManager
    
    @State private var showPurchaseAlert = false
    @State private var purchaseMessage = ""
    
    var body: some View {
        if let deal = shopManager.dailyDeal,
           deal.isToday,
           let item = ItemCatalog.allShopItems.first(where: { $0.id == deal.itemId }) {
            
            VStack(spacing: 0) {
                dealCard(deal: deal, item: item)
            }
            .pixelAlert(isPresented: $showPurchaseAlert, title: "DAILY DEAL", message: purchaseMessage)
        }
    }
    
    private func dealCard(deal: DailyDeal, item: Item) -> some View {
        HStack(spacing: 16) {
            itemImage(item)
            dealDetails(item: item, deal: deal)
            Spacer()
            buyButton(item: item, deal: deal)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.4), .white.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
    
    private func itemImage(_ item: Item) -> some View {
        ZStack {
            Image(item.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 70, height: 70)
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.orange.opacity(0.1))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                )
        }
    }
    
    private func dealDetails(item: Item, deal: DailyDeal) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            headerRow(item: item, deal: deal)
            
            Text(item.name)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(themeManager.primaryText)
                .lineLimit(1)
            
            priceRow(item: item, deal: deal)
        }
    }
    
    private func headerRow(item: Item, deal: DailyDeal) -> some View {
        HStack {
            Image(systemName: "flame.fill")
                .font(.system(size: 10))
                .foregroundColor(.orange)
            Text("DEAL OF THE DAY")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.orange)
                .tracking(1)
            
            Spacer()
            
            savingsBadge(item: item, deal: deal)
        }
    }
    
    private func savingsBadge(item: Item, deal: DailyDeal) -> some View {
        let savings = Int(((Double(item.price) - Double(deal.dealPrice)) / Double(item.price)) * 100)
        return Text("SAVE \(savings)%")
            .font(.system(size: 9, weight: .bold))
            .foregroundColor(.green)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(
                Capsule()
                    .fill(Color.green.opacity(0.15))
                    .overlay(
                        Capsule().stroke(Color.green.opacity(0.3), lineWidth: 0.5)
                    )
            )
    }
    
    private func priceRow(item: Item, deal: DailyDeal) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            HStack(spacing: 2) {
                Text("\(deal.dealPrice)")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.orange)
                Text("💰")
                    .font(.system(size: 14))
            }
            
            Text("\(item.price)")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(themeManager.secondaryText)
                .strikethrough()
        }
    }
    
    private func buyButton(item: Item, deal: DailyDeal) -> some View {
        Button {
            SoundManager.shared.buttonTap()
            purchaseDeal(item: item, price: deal.dealPrice)
        } label: {
            Image(systemName: "cart.fill")
                .font(.system(size: 18))
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.orange, .red],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: .orange.opacity(0.4), radius: 8, x: 0, y: 4)
                )
        }
        .disabled(inventoryManager.owns(item))
        .opacity(inventoryManager.owns(item) ? 0.5 : 1.0)
    }
    
    private func purchaseDeal(item: Item, price: Int) {
        if currencyManager.canAfford(price) {
            if currencyManager.spend(price) {
                inventoryManager.addItem(item)
                purchaseMessage = "Deal claimed! \(item.name) added to inventory!"
                showPurchaseAlert = true
                HapticManager.shared.success()
            }
        } else {
            purchaseMessage = "Not enough coins! You need \(price - currencyManager.coins) more."
            showPurchaseAlert = true
        }
    }
}

// MARK: - Bundle Card

struct BundleCard: View {
    let bundle: ItemBundle
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var currencyManager: CurrencyManager
    @StateObject private var shopManager = ShopManager.shared
    
    @State private var showPurchaseAlert = false
    @State private var purchaseMessage = ""
    @State private var showDetails = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text(bundle.icon)
                    .font(.system(size: 32))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(bundle.name)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(themeManager.primaryText)
                    
                    Text(bundle.description)
                        .font(.system(size: 12))
                        .foregroundColor(themeManager.secondaryText)
                }
                
                Spacer()
                
                if bundle.isLimitedTime {
                    VStack {
                        Image(systemName: "clock.fill")
                            .foregroundColor(.orange)
                        Text("Limited")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.orange)
                    }
                }
            }
            
            // Items preview
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(bundle.itemIds.prefix(4), id: \.self) { itemId in
                        if let item = ItemCatalog.allShopItems.first(where: { $0.id == itemId }) {
                            Image(item.imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                    
                    if bundle.itemIds.count > 4 {
                        Text("+\(bundle.itemIds.count - 4)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(themeManager.secondaryText)
                            .frame(width: 50, height: 50)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
            }
            
            // Pricing
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text("\(bundle.regularPrice)")
                            .font(.system(size: 14))
                            .foregroundColor(themeManager.secondaryText)
                            .strikethrough()
                        
                        Text("💰")
                            .font(.system(size: 12))
                    }
                    
                    HStack(spacing: 4) {
                        Text("\(bundle.bundlePrice)")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.green)
                        
                        Text("💰")
                            .font(.system(size: 20))
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("SAVE \(bundle.discountPercent)%")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.green)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color.green.opacity(0.2)))
                    
                    Button {
                        SoundManager.shared.buttonTap()
                        purchaseBundle()
                    } label: {
                        Text("Buy Bundle")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(themeManager.primaryText)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(themeManager.primaryGradient)
                            .cornerRadius(20)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(themeManager.cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(bundle.isLimitedTime ? Color.orange : Color.white.opacity(0.1), lineWidth: 2)
        )
        .pixelAlert(isPresented: $showPurchaseAlert, title: "BUNDLE", message: purchaseMessage)
    }
    
    private func purchaseBundle() {
        if shopManager.canAffordBundle(bundle, coins: currencyManager.coins) {
            if shopManager.purchaseBundle(bundle) {
                purchaseMessage = "Bundle purchased! Check your inventory!"
                showPurchaseAlert = true
            }
        } else {
            purchaseMessage = "Not enough coins! You need \(bundle.bundlePrice - currencyManager.coins) more."
            showPurchaseAlert = true
        }
    }
}

// Coin Task Card and Earn Coins View removed as requested
