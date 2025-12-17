//
//  PixelRoomShopView.swift
//  benk
//
//  Shop interface with iOS 26 Liquid Glass design
//

import SwiftUI

struct PixelRoomShopView: View {
    @EnvironmentObject var currencyManager: CurrencyManager
    @EnvironmentObject var inventoryManager: InventoryManager
    @EnvironmentObject var roomManager: RoomManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var parentTheme: ThemeService
    
    @State private var selectedCategory: ShopCategory = .furniture
    @State private var showPurchaseAlert = false
    @State private var purchaseMessage = ""
    @State private var searchText = ""
    @State private var selectedPriceFilter: PriceFilter = .all
    @State private var selectedSortOption: SortOption = .name
    @State private var showFilters = false
    @State private var showBundles = false
    @State private var showCustomization = false
    @State private var itemToCustomize: Item?
    
    @StateObject private var shopManager = ShopManager.shared
    @StateObject private var customizationManager = CustomizationManager.shared
    
    enum ShopCategory: String, CaseIterable {
        case furniture = "Furniture"
        case decorations = "Decorations"
        case pets = "Pets"
        case rooms = "Rooms"
        case windows = "Windows"
    }
    
    enum PriceFilter: String, CaseIterable {
        case all = "All"
        case budget = "<100"
        case affordable = "100-200"
        case premium = "200-500"
        case luxury = "500+"
        
        func matches(price: Int) -> Bool {
            switch self {
            case .all: return true
            case .budget: return price < 100
            case .affordable: return price >= 100 && price < 200
            case .premium: return price >= 200 && price < 500
            case .luxury: return price >= 500
            }
        }
    }
    
    enum SortOption: String, CaseIterable {
        case name = "Name"
        case priceLow = "Price ↑"
        case priceHigh = "Price ↓"
        case newest = "New"
    }
    
    var body: some View {
        ZStack {
            // Themed background with effects (snow, stars, etc.)
            ThemedBackground(theme: parentTheme.currentTheme)
            
            // Main Content ScrollView (Behind headers)
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // Spacer for top headers
                    Color.clear.frame(height: 180) // Adjust based on header height
                    
                    // Store Widget Slider (Daily Deal + Bundles)
                    StoreWidgetSlider(showBundlesSheet: $showBundles, showPurchaseAlert: $showPurchaseAlert, purchaseMessage: $purchaseMessage)
                    
                    // Items
                    itemsGrid
                        .padding(.horizontal, 16)
                }
                .padding(.bottom, 100)
            }
            
            // Floating Headers
            VStack(spacing: 0) {
                // Top spacing for container top bar
                Color.clear.frame(height: 60)
                
                VStack(spacing: 0) {
                    // Header with action buttons
                    glassHeader
                        .padding(.horizontal, 16)
                    
                    // Category selector
                    glassCategoryPicker
                        .padding(.top, 12)
                    
                    // Search bar and filters
                    glassSearchBar
                        .padding(.horizontal, 16)
                        .padding(.top, 10)
                    
                    // Filter options (expandable)
                    if showFilters {
                        glassFilterSection
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
                // Background for headers to ensure text legibility while keeping transparency
                .background(
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .opacity(0.0) // Completely transparent as requested, relying on glass components
                )
                
                Spacer()
            }
        }
        .pixelAlert(isPresented: $showPurchaseAlert, title: "SHOP", message: purchaseMessage)
        // Earn Coins sheet removed
        .sheet(isPresented: $showBundles) {
            BundlesView()
        }
        .sheet(isPresented: $showCustomization) {
            if let item = itemToCustomize {
                ItemCustomizationView(item: item)
            }
        }
    }
    
    // MARK: - Glass Header
    private var glassHeader: some View {
        HStack(spacing: 12) {
            // Earn Coins button removed as requested
            
            Spacer()
            
            Spacer()
            
            // Bundles button removed (moved to slider widget)
        }
    }
    
    // MARK: - Glass Category Picker
    private var glassCategoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(ShopCategory.allCases, id: \.self) { category in
                    glassCategoryButton(for: category)
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    private func glassCategoryButton(for category: ShopCategory) -> some View {
        let isSelected = selectedCategory == category
        
        return Button(action: {
            SoundManager.shared.buttonTap()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                selectedCategory = category
            }
            HapticManager.shared.selection()
        }) {
            Text(category.rawValue)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(isSelected ? parentTheme.currentTheme.text : parentTheme.currentTheme.textSecondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(categoryButtonBackground(isSelected: isSelected))
        }
    }
    
    @ViewBuilder
    private func categoryButtonBackground(isSelected: Bool) -> some View {
        if isSelected {
            Capsule()
                .fill(parentTheme.currentTheme.accent.opacity(0.2))
                .overlay(
                    Capsule()
                        .stroke(parentTheme.currentTheme.accent.opacity(0.5), lineWidth: 1)
                )
        } else {
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        }
    }
    
    // MARK: - Glass Search Bar
    private var glassSearchBar: some View {
        HStack(spacing: 12) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(parentTheme.currentTheme.textSecondary)
                    .font(.system(size: 14))
                
                TextField("Search items...", text: $searchText)
                    .foregroundColor(parentTheme.currentTheme.text)
                    .font(.system(size: 14))
                    .autocorrectionDisabled()
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.white.opacity(0.15), lineWidth: 0.5)
                    )
            )
            
            // Filter button
            Button {
                SoundManager.shared.buttonTap()
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    showFilters.toggle()
                }
                HapticManager.shared.selection()
            } label: {
                Image(systemName: showFilters ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                    .font(.system(size: 20))
                    .foregroundColor(showFilters ? parentTheme.currentTheme.accent : parentTheme.currentTheme.textSecondary)
                    .frame(width: 40, height: 40)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        showFilters ? parentTheme.currentTheme.accent.opacity(0.4) : Color.white.opacity(0.1),
                                        lineWidth: 0.5
                                    )
                            )
                    )
            }
        }
    }
    
    // MARK: - Glass Filter Section
    private var glassFilterSection: some View {
        VStack(spacing: 12) {
            // Price filter
            VStack(alignment: .leading, spacing: 8) {
                Text("Price Range")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(parentTheme.currentTheme.textSecondary)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(PriceFilter.allCases, id: \.self) { filter in
                            glassFilterPill(
                                title: filter.rawValue,
                                isSelected: selectedPriceFilter == filter,
                                color: parentTheme.currentTheme.accent
                            ) {
                                selectedPriceFilter = filter
                            }
                        }
                    }
                }
            }
            
            // Sort option
            VStack(alignment: .leading, spacing: 8) {
                Text("Sort By")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(parentTheme.currentTheme.textSecondary)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            glassFilterPill(
                                title: option.rawValue,
                                isSelected: selectedSortOption == option,
                                color: parentTheme.currentTheme.glow
                            ) {
                                selectedSortOption = option
                            }
                        }
                    }
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                )
        )
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
    
    private func glassFilterPill(title: String, isSelected: Bool, color: Color, action: @escaping () -> Void) -> some View {
        Button {
            SoundManager.shared.buttonTap()
            action()
            HapticManager.shared.selection()
        } label: {
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(isSelected ? parentTheme.currentTheme.text : parentTheme.currentTheme.textSecondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(filterPillBackground(isSelected: isSelected, color: color))
        }
    }
    
    @ViewBuilder
    private func filterPillBackground(isSelected: Bool, color: Color) -> some View {
        if isSelected {
            Capsule()
                .fill(color.opacity(0.2))
                .overlay(
                    Capsule()
                        .stroke(color.opacity(0.5), lineWidth: 0.5)
                )
        } else {
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                )
        }
    }
    
    // MARK: - Items Grid
    @ViewBuilder
    private var itemsGrid: some View {
        if selectedCategory == .furniture {
            let filteredItems = getFilteredAndSortedItems()
            let groupedItems = groupItemsBySubCategory(filteredItems)
            let sortedKeys = getSortedSubCategories(keys: Array(groupedItems.keys))
            
            if filteredItems.isEmpty {
                emptyState
            } else {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(sortedKeys, id: \.self) { key in
                        VStack(alignment: .leading, spacing: 10) {
                            Text(key)
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(parentTheme.currentTheme.text)
                                .padding(.leading, 4)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 14) {
                                ForEach(groupedItems[key] ?? []) { item in
                                    glassItemCard(item)
                                }
                            }
                        }
                    }
                }
            }
        } else {
            let filteredItems = selectedCategory == .windows ? [] : getFilteredAndSortedItems()
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 14) {
                if selectedCategory == .windows {
                    ForEach(ItemCatalog.windowBackgrounds) { window in
                        glassWindowItemCard(window)
                    }
                } else if filteredItems.isEmpty {
                    emptyState
                } else {
                    ForEach(filteredItems) { item in
                        glassItemCard(item)
                    }
                }
            }
        }
    }
    
    // MARK: - Glass Item Card
    private func glassItemCard(_ item: Item) -> some View {
        let finalPrice = shopManager.getSalePrice(for: item) ?? item.price
        let canAfford = currencyManager.canAfford(finalPrice)
        let isOwned = inventoryManager.owns(item)
        
        return VStack(spacing: 8) {
            // Item image
            ZStack {
                Image(item.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 80)
                
                // Sale badge
                if let sale = shopManager.getSaleForItem(item.id) {
                    VStack {
                        HStack {
                            Spacer()
                            Text("\(sale.discountPercent)%")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: [.red, .orange],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                )
                                .padding(4)
                        }
                        Spacer()
                    }
                }
                
                // OWNED badge - Liquid glass style with cyan/purple theme
                if isOwned {
                    Color.black.opacity(0.4)
                    
                    Text("OWNED")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: [.cyan.opacity(0.4), .purple.opacity(0.3)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                )
                                .overlay(
                                    Capsule()
                                        .stroke(
                                            LinearGradient(
                                                colors: [.cyan.opacity(0.6), .purple.opacity(0.4)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1
                                        )
                                )
                        )
                        .shadow(color: .cyan.opacity(0.3), radius: 8, x: 0, y: 2)
                }
            }
            .frame(height: 80)
            .background(Color.white.opacity(0.05))
            .cornerRadius(10)
            
            // Item name
            Text(item.name)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(parentTheme.currentTheme.text)
                .lineLimit(1)
            
            // Price
            HStack(spacing: 4) {
                if let salePrice = shopManager.getSalePrice(for: item) {
                    Text("\(item.price)")
                        .font(.system(size: 10))
                        .foregroundColor(parentTheme.currentTheme.textSecondary)
                        .strikethrough()
                    
                    Text("\(salePrice)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.red)
                } else {
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.orange)
                    Text("\(item.price)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.orange)
                }
            }
            
            // Buy button - Liquid glass with conditional glow
            Button(action: {
                purchaseItem(item)
            }) {
                Text(isOwned ? "Owned" : "Buy")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(isOwned ? .white.opacity(0.8) : .white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        Group {
                            if isOwned {
                                // Owned: muted glass style
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.gray.opacity(0.2))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                                    )
                            } else if canAfford {
                                // Can afford: glowing green gradient
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(
                                        LinearGradient(
                                            colors: [.green, .mint],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.white.opacity(0.4), lineWidth: 0.5)
                                    )
                                    .shadow(color: .green.opacity(0.5), radius: 8, x: 0, y: 2)
                            } else {
                                // Cannot afford: muted red/gray
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.red.opacity(0.15))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.red.opacity(0.3), lineWidth: 0.5)
                                    )
                            }
                        }
                    )
            }
            .disabled(isOwned)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.2), .white.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.5
                        )
                )
        )
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Glass Window Item Card
    private func glassWindowItemCard(_ window: WindowBackground) -> some View {
        let canAfford = currencyManager.canAfford(window.price)
        let isOwned = inventoryManager.owns(window)
        
        return VStack(spacing: 8) {
            Image(window.imageName)
                .resizable()
                .scaledToFill()
                .frame(height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            Text(window.name)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(parentTheme.currentTheme.text)
                .lineLimit(1)
            
            HStack(spacing: 4) {
                Image(systemName: "dollarsign.circle.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.orange)
                Text("\(window.price)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.orange)
            }
            
            // Buy button - Liquid glass with conditional glow
            Button(action: {
                purchaseWindowBackground(window)
            }) {
                Text(isOwned ? "Owned" : "Buy")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(isOwned ? .white.opacity(0.8) : .white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        Group {
                            if isOwned {
                                // Owned: muted glass style
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.gray.opacity(0.2))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                                    )
                            } else if canAfford {
                                // Can afford: glowing green gradient
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(
                                        LinearGradient(
                                            colors: [.green, .mint],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.white.opacity(0.4), lineWidth: 0.5)
                                    )
                                    .shadow(color: .green.opacity(0.5), radius: 8, x: 0, y: 2)
                            } else {
                                // Cannot afford: muted red/gray
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.red.opacity(0.15))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.red.opacity(0.3), lineWidth: 0.5)
                                    )
                            }
                        }
                    )
            }
            .disabled(isOwned)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                )
        )
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(parentTheme.currentTheme.textSecondary)
            
            Text("No items found")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(parentTheme.currentTheme.text)
            
            Text("Try adjusting your filters")
                .font(.system(size: 13))
                .foregroundColor(parentTheme.currentTheme.textSecondary)
            
            Button {
                SoundManager.shared.buttonTap()
                searchText = ""
                selectedPriceFilter = .all
                HapticManager.shared.selection()
            } label: {
                Text("Clear Filters")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(parentTheme.currentTheme.text)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 9)
                    .background(
                        Capsule()
                            .fill(parentTheme.currentTheme.accent.opacity(0.3))
                            .overlay(
                                Capsule()
                                    .stroke(parentTheme.currentTheme.accent.opacity(0.5), lineWidth: 0.5)
                            )
                    )
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }
    
    // MARK: - Helper Methods
    private func getFilteredAndSortedItems() -> [Item] {
        var items = getItemsForCategory()
        
        if !searchText.isEmpty {
            items = items.filter { item in
                item.name.lowercased().contains(searchText.lowercased()) ||
                (item.subCategory?.lowercased().contains(searchText.lowercased()) ?? false)
            }
        }
        
        items = items.filter { selectedPriceFilter.matches(price: $0.price) }
        
        switch selectedSortOption {
        case .name:
            items.sort { $0.name < $1.name }
        case .priceLow:
            items.sort { $0.price < $1.price }
        case .priceHigh:
            items.sort { $0.price > $1.price }
        case .newest:
            break
        }
        
        return items
    }
    
    private func groupItemsBySubCategory(_ items: [Item]) -> [String: [Item]] {
        Dictionary(grouping: items) { $0.subCategory ?? "Other" }
    }
    
    private func getSortedSubCategories(keys: [String]) -> [String] {
        let order = [
            "Beds",
            "Tables", 
            "Seating",
            "Storage",
            "Clocks",
            "Decorations",
            "Pro Gaming Collection",
            "Royal Regalia Collection",
            "Other"
        ]
        return keys.sorted { (a, b) -> Bool in
            let indexA = order.firstIndex(of: a) ?? Int.max
            let indexB = order.firstIndex(of: b) ?? Int.max
            return indexA < indexB
        }
    }
    
    private func getItemsForCategory() -> [Item] {
        switch selectedCategory {
        case .furniture:
            return ItemCatalog.furnitureItems
        case .decorations:
            return ItemCatalog.decorationItems
        case .pets:
            return ItemCatalog.petItems
        case .rooms:
            return ItemCatalog.roomThemes
        case .windows:
            return []
        }
    }
    
    private func purchaseItem(_ item: Item) {
        let finalPrice = shopManager.getSalePrice(for: item) ?? item.price
        
        if currencyManager.canAfford(finalPrice) {
            if currencyManager.spend(finalPrice) {
                inventoryManager.addItem(item)
                SoundManager.shared.purchaseSuccess()
                
                if shopManager.isItemOnSale(item.id) {
                    purchaseMessage = "Sale! Purchased \(item.name) for \(finalPrice) coins!"
                } else {
                    purchaseMessage = "Purchased \(item.name)! Check your inventory."
                }
                showPurchaseAlert = true
            }
        } else {
            SoundManager.shared.purchaseFail()
            purchaseMessage = "Not enough coins! You need \(finalPrice - currencyManager.coins) more."
            showPurchaseAlert = true
        }
    }
    
    private func purchaseWindowBackground(_ window: WindowBackground) {
        if currencyManager.canAfford(window.price) {
            if currencyManager.spend(window.price) {
                inventoryManager.addWindowBackground(window)
                roomManager.setWindowBackground(window)
                SoundManager.shared.purchaseSuccess()
                purchaseMessage = "Purchased \(window.name)!"
                showPurchaseAlert = true
            }
        } else {
            SoundManager.shared.purchaseFail()
            purchaseMessage = "Not enough coins! You need \(window.price - currencyManager.coins) more."
            showPurchaseAlert = true
        }
    }
}
