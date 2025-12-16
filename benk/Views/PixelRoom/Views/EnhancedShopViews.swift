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
    @EnvironmentObject var parentTheme: ThemeService
    @EnvironmentObject var currencyManager: CurrencyManager
    @EnvironmentObject var inventoryManager: InventoryManager
    
    // Callback bindings for showing toast in parent view
    @Binding var showPurchaseAlert: Bool
    @Binding var purchaseMessage: String
    
    // Default initializer with no-op bindings for backward compatibility
    init(showPurchaseAlert: Binding<Bool> = .constant(false), purchaseMessage: Binding<String> = .constant("")) {
        _showPurchaseAlert = showPurchaseAlert
        _purchaseMessage = purchaseMessage
    }
    

    
    // Height fixed at 180 for slider compatibility
    var body: some View {
        Group {
            if let deal = shopManager.dailyDeal,
               deal.isToday,
               let item = ItemCatalog.allShopItems.first(where: { $0.id == deal.itemId }) {
                
                VStack(spacing: 0) {
                    dealCard(deal: deal, item: item)
                }
                .frame(height: 180)
            } else {
                // Empty state if no deal
                VStack(spacing: 8) {
                    Image(systemName: "clock")
                        .font(.system(size: 30))
                        .foregroundColor(parentTheme.currentTheme.textSecondary)
                    Text("No Daily Deal\nCheck back later!")
                        .font(.system(size: 14, weight: .medium))
                        .multilineTextAlignment(.center)
                        .foregroundColor(parentTheme.currentTheme.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 180)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(.ultraThinMaterial)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
            }
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
        .frame(maxHeight: .infinity)
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
                .foregroundColor(parentTheme.currentTheme.text)
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
                .foregroundColor(parentTheme.currentTheme.textSecondary)
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
    
    // Callback bindings for showing toast in parent view
    @Binding var showPurchaseAlert: Bool
    @Binding var purchaseMessage: String
    
    @State private var showDetails = false
    
    // Default initializer with no-op bindings for backward compatibility
    init(bundle: ItemBundle, showPurchaseAlert: Binding<Bool> = .constant(false), purchaseMessage: Binding<String> = .constant("")) {
        self.bundle = bundle
        _showPurchaseAlert = showPurchaseAlert
        _purchaseMessage = purchaseMessage
    }
    
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


// MARK: - Bundles Widget

struct BundlesWidget: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var parentTheme: ThemeService
    @Binding var showBundlesSheet: Bool
    
    var body: some View {
        Button {
            SoundManager.shared.buttonTap()
            showBundlesSheet = true
            HapticManager.shared.selection()
        } label: {
            HStack(spacing: 16) {
                // Icon/Image
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.purple.opacity(0.2), .pink.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                    
                    Text("🎁")
                        .font(.system(size: 40))
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("SPECIAL OFFERS")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.purple)
                            .tracking(1)
                        
                        Spacer()
                        
                        Text("LIMITED")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [.purple, .pink],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            )
                    }
                    
                    Text("Value Bundles")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(parentTheme.currentTheme.text)
                    
                    Text("Save up to 50% on curated sets!")
                        .font(.system(size: 13))
                        .foregroundColor(parentTheme.currentTheme.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(parentTheme.currentTheme.textSecondary.opacity(0.5))
            }
            .padding(20)
            .frame(height: 180)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        LinearGradient(
                            colors: [.purple.opacity(0.3), .pink.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: .purple.opacity(0.1), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Store Widget Slider

struct StoreWidgetSlider: View {
    @Binding var showBundlesSheet: Bool
    @Binding var showPurchaseAlert: Bool
    @Binding var purchaseMessage: String
    @State private var currentPage = 0
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 8) {
            TabView(selection: $currentPage) {
                DailyDealBanner(
                    showPurchaseAlert: $showPurchaseAlert,
                    purchaseMessage: $purchaseMessage
                )
                    .padding(.horizontal, 16)
                    .tag(0)
                
                BundlesWidget(showBundlesSheet: $showBundlesSheet)
                    .padding(.horizontal, 16)
                    .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 180)
            
            // Custom Page Indicator
            HStack(spacing: 6) {
                ForEach(0..<2) { index in
                    Circle()
                        .fill(currentPage == index ? themeManager.primaryText : themeManager.secondaryText.opacity(0.3))
                        .frame(width: 6, height: 6)
                        .scaleEffect(currentPage == index ? 1.2 : 1.0)
                        .animation(.spring(response: 0.3), value: currentPage)
                }
            }
            .padding(.top, 4)
        }
    }
}

