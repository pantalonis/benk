//
//  CustomizationView.swift
//  Pixel Room Customizer
//
//  UI for customizing items with colors and sizes
//

import SwiftUI

struct ItemCustomizationView: View {
    let item: Item
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var currencyManager: CurrencyManager
    @EnvironmentObject var inventoryManager: InventoryManager
    @StateObject private var customizationManager = CustomizationManager.shared
    
    @State private var selectedSize: ItemSize = .medium
    @State private var customName: String = ""
    @State private var showPurchaseAlert = false
    @State private var purchaseMessage = ""
    @State private var sizeSliderValue: Double = 1.0 // 0.75 to 2.0
    
    var finalPrice: Int {
        let price = Double(item.price) * selectedSize.priceMultiplier
        return Int(price)
    }
    
    var body: some View {
        ZStack {
            themeManager.backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                header
                
                // Content
                ScrollView {
                    VStack(spacing: 24) {
                        // Item preview
                        itemPreview
                        
                        // Size slider
                        sizeSlider
                        
                        // Custom name
                        customNameField
                        
                        // Price summary
                        priceSummary
                        
                        // Purchase button
                        purchaseButton
                    }
                    .padding()
                }
            }
        }
        .pixelAlert(isPresented: $showPurchaseAlert, title: "CUSTOMIZE", message: purchaseMessage)
    }
    
    // MARK: - Header
    
    private var header: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(themeManager.secondaryText)
            }
            
            Spacer()
            
            VStack(spacing: 4) {
                Text("🎨 Customize")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(themeManager.primaryText)
                
                Text(item.name)
                    .font(.system(size: 14))
                    .foregroundColor(themeManager.secondaryText)
            }
            
            Spacer()
            
            // Balance
            HStack(spacing: 4) {
                Text("\(currencyManager.coins)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.yellow)
                Text("💰")
            }
        }
        .padding()
    }
    
    // MARK: - Item Preview
    
    private var itemPreview: some View {
        VStack(spacing: 12) {
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.1))
                
                // Item image with size preview
                Image(item.imageName)
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(sizeSliderValue)
                    .frame(height: 200)
                    .animation(.spring(response: 0.3), value: sizeSliderValue)
            }
            .frame(height: 250)
            
            Text("Preview")
                .font(.system(size: 12))
                .foregroundColor(themeManager.secondaryText)
        }
    }
    
    // MARK: - Size Slider
    
    private var sizeSlider: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Size")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(themeManager.primaryText)
                
                Spacer()
                
                Text(selectedSize.rawValue)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(themeManager.accentCyan)
            }
            
            // Slider
            VStack(spacing: 8) {
                Slider(value: $sizeSliderValue, in: 0.75...2.0, step: 0.01)
                    .accentColor(themeManager.accentCyan)
                    .onChange(of: sizeSliderValue) { oldValue, newValue in
                        updateSizeFromSlider(newValue)
                        HapticManager.shared.impact(.light)
                    }
                
                // Size markers
                HStack {
                    ForEach([("S", 0.75), ("M", 1.0), ("L", 1.5), ("XL", 2.0)], id: \.0) { label, value in
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                sizeSliderValue = value
                            }
                            HapticManager.shared.impact(.medium)
                        } label: {
                            VStack(spacing: 4) {
                                Text(label)
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(abs(sizeSliderValue - value) < 0.1 ? themeManager.accentCyan : .white.opacity(0.5))
                                
                                Circle()
                                    .fill(abs(sizeSliderValue - value) < 0.1 ? themeManager.accentCyan : Color.white.opacity(0.3))
                                    .frame(width: 8, height: 8)
                            }
                        }
                        
                        if label != "XL" {
                            Spacer()
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.05))
            )
            
            // Size info
            HStack {
                Text("Scale: \(Int(sizeSliderValue * 100))%")
                    .font(.system(size: 14))
                    .foregroundColor(themeManager.secondaryText)
                
                Spacer()
                
                let priceChange = Int((selectedSize.priceMultiplier - 1.0) * 100)
                Text(priceChange >= 0 ? "+\(priceChange)%" : "\(priceChange)%")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(priceChange >= 0 ? .orange : .green)
            }
        }
    }
    
    // MARK: - Custom Name Field
    
    private var customNameField: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Custom Name (Optional)")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(themeManager.primaryText)
            
            TextField("Enter custom name...", text: $customName)
                .foregroundColor(themeManager.primaryText)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.1))
                )
        }
    }
    
    // MARK: - Price Summary
    
    private var priceSummary: some View {
        VStack(spacing: 12) {
            Divider()
                .background(Color.white.opacity(0.2))
            
            HStack {
                Text("Base Price:")
                    .foregroundColor(themeManager.secondaryText)
                Spacer()
                Text("\(item.price) 💰")
                    .foregroundColor(themeManager.primaryText)
            }
            
            if selectedSize != .medium {
                HStack {
                    Text("Size Adjustment:")
                        .foregroundColor(themeManager.secondaryText)
                    Spacer()
                    Text("\(selectedSize.rawValue) (\(Int((selectedSize.priceMultiplier - 1.0) * 100))%)")
                        .foregroundColor(selectedSize.priceMultiplier > 1.0 ? .orange : .green)
                }
            }
            
            Divider()
                .background(Color.white.opacity(0.2))
            
            HStack {
                Text("Total Price:")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(themeManager.primaryText)
                Spacer()
                Text("\(finalPrice) 💰")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.yellow)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }
    
    // MARK: - Purchase Button
    
    private var purchaseButton: some View {
        Button {
            purchaseCustomizedItem()
        } label: {
            Text("Purchase Customized Item")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(themeManager.primaryText)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [themeManager.accentCyan, themeManager.accentPurple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
        }
        .disabled(!currencyManager.canAfford(finalPrice))
        .opacity(currencyManager.canAfford(finalPrice) ? 1.0 : 0.5)
    }
    
    // MARK: - Actions
    
    private func updateSizeFromSlider(_ value: Double) {
        // Convert slider value to ItemSize
        if value < 0.875 {
            selectedSize = .small
        } else if value < 1.25 {
            selectedSize = .medium
        } else if value < 1.75 {
            selectedSize = .large
        } else {
            selectedSize = .extraLarge
        }
    }
    
    private func purchaseCustomizedItem() {
        if currencyManager.spend(finalPrice) {
            let _ = customizationManager.createCustomizedItem(
                baseItemId: item.id,
                size: selectedSize,
                customName: customName.isEmpty ? nil : customName
            )
            
            // Add to inventory (you'll need to update InventoryManager to handle customized items)
            inventoryManager.addItem(item)
            
            purchaseMessage = "Customized \(item.name) purchased!"
            showPurchaseAlert = true
            HapticManager.shared.success()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                dismiss()
            }
        } else {
            purchaseMessage = "Not enough coins! You need \(finalPrice - currencyManager.coins) more."
            showPurchaseAlert = true
        }
    }
}

#Preview("ItemCustomizationView") {
    ItemCustomizationView(item: ItemCatalog.furnitureItems[0])
        .environmentObject(ThemeManager())
        .environmentObject(CurrencyManager.shared)
        .environmentObject(InventoryManager.shared)
}
