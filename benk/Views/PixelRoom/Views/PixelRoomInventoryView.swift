//
//  PixelRoomInventoryView.swift
//  benk
//
//  Inventory interface with iOS 26 Liquid Glass design
//

import SwiftUI

struct PixelRoomInventoryView: View {
    @EnvironmentObject var inventoryManager: InventoryManager
    @EnvironmentObject var roomManager: RoomManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var parentTheme: ThemeService
    
    @State private var selectedCategory: ItemCategory = .furniture
    @State private var showPlacementAlert = false
    @State private var placementMessage = ""
    @State private var searchText = ""
    
    var body: some View {
        ZStack {
            // Themed background with effects (snow, stars, etc.)
            ThemedBackground(theme: parentTheme.currentTheme)
            
            VStack(spacing: 0) {
                // Top spacing for container top bar
                Color.clear.frame(height: 60)
                
                // Category selector
                glassCategoryPicker
                    .padding(.top, 8)
                
                // Search bar
                glassSearchBar
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                
                // Items grid
                if inventoryManager.ownedItems.isEmpty && inventoryManager.ownedWindowBackgrounds.isEmpty {
                    emptyState
                } else {
                    ScrollView(showsIndicators: false) {
                        if selectedCategory == .furniture {
                            let groupedItems = groupItemsBySubCategory(getItemsForCategory())
                            let sortedKeys = getSortedSubCategories(keys: Array(groupedItems.keys))
                            
                            VStack(alignment: .leading, spacing: 20) {
                                ForEach(sortedKeys, id: \.self) { key in
                                    if let items = groupedItems[key], !items.isEmpty {
                                        VStack(alignment: .leading, spacing: 10) {
                                            Text(key)
                                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                                .foregroundColor(parentTheme.currentTheme.text)
                                                .padding(.leading, 4)
                                            
                                            LazyVGrid(columns: [
                                                GridItem(.flexible()),
                                                GridItem(.flexible())
                                            ], spacing: 14) {
                                                ForEach(items) { item in
                                                    glassInventoryItemCard(item)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(16)
                        } else {
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 14) {
                                if selectedCategory == .windowView {
                                    ForEach(inventoryManager.ownedWindowBackgrounds) { window in
                                        glassWindowItemCard(window)
                                    }
                                } else {
                                    ForEach(getItemsForCategory()) { item in
                                        glassInventoryItemCard(item)
                                    }
                                }
                            }
                            .padding(16)
                        }
                    }
                    .padding(.bottom, 100)
                }
            }
        }
        .pixelAlert(isPresented: $showPlacementAlert, title: "INVENTORY", message: placementMessage)
    }
    
    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "cube.box")
                .font(.system(size: 48))
                .foregroundColor(parentTheme.currentTheme.textSecondary)
            
            Text("Your inventory is empty")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(parentTheme.currentTheme.text)
            
            Text("Visit the shop to buy items!")
                .font(.system(size: 14))
                .foregroundColor(parentTheme.currentTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Glass Category Picker
    private var glassCategoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(ItemCategory.allCases, id: \.self) { category in
                    glassCategoryButton(for: category)
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    private func glassCategoryButton(for category: ItemCategory) -> some View {
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
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(parentTheme.currentTheme.textSecondary)
                .font(.system(size: 14))
            
            TextField("Search your items...", text: $searchText)
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
    }
    
    // MARK: - Glass Inventory Item Card
    private func glassInventoryItemCard(_ item: Item) -> some View {
        VStack(spacing: 8) {
            // Item image
            Image(item.imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 80)
                .background(Color.white.opacity(0.05))
                .cornerRadius(10)
            
            // Item name
            Text(item.name)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(parentTheme.currentTheme.text)
                .lineLimit(1)
            
            // Grid size info (Hide for themes)
            if item.category != .roomTheme {
                Text("\(item.gridWidth)x\(item.gridDepth)")
                    .font(.system(size: 10))
                    .foregroundColor(parentTheme.currentTheme.textSecondary)
            }
            
            // Action button
            let isActive = item.category == .roomTheme && roomManager.currentRoomTheme?.id == item.id
            
            Button(action: {
                SoundManager.shared.buttonTap()
                if item.category == .roomTheme {
                    roomManager.setRoomTheme(item)
                    placementMessage = "Room theme set to \(item.name)!"
                    showPlacementAlert = true
                } else {
                    placeItem(item)
                }
                HapticManager.shared.selection()
            }) {
                HStack(spacing: 4) {
                    Image(systemName: item.category == .roomTheme ? "paintbrush.fill" : "plus.circle")
                        .font(.system(size: 11))
                    Text(item.category == .roomTheme ? (isActive ? "Active" : "Apply") : "Place")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundColor(parentTheme.currentTheme.text)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isActive ? Color.gray.opacity(0.3) : Color.green.opacity(0.3))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(isActive ? Color.gray.opacity(0.5) : Color.green.opacity(0.5), lineWidth: 0.5)
                        )
                )
            }
            .disabled(isActive)
            
            // Reusable indicator
            if item.isReusable {
                Text("♻️ Reusable")
                    .font(.system(size: 9))
                    .foregroundColor(.green)
            }
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
        let isActive = roomManager.currentWindowBackground?.id == window.id
        
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
            
            Text("Window View")
                .font(.system(size: 10))
                .foregroundColor(parentTheme.currentTheme.textSecondary)
            
            Button(action: {
                SoundManager.shared.buttonTap()
                roomManager.setWindowBackground(window)
                placementMessage = "Window view set to \(window.name)!"
                showPlacementAlert = true
                HapticManager.shared.selection()
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .font(.system(size: 11))
                    Text(isActive ? "Active" : "Apply")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundColor(parentTheme.currentTheme.text)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isActive ? Color.gray.opacity(0.3) : parentTheme.currentTheme.glow.opacity(0.3))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(isActive ? Color.gray.opacity(0.5) : parentTheme.currentTheme.glow.opacity(0.5), lineWidth: 0.5)
                        )
                )
            }
            .disabled(isActive)
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
    
    // MARK: - Helper Methods
    private func getItemsForCategory() -> [Item] {
        var items = inventoryManager.getItemsByCategory(selectedCategory)
        
        if !searchText.isEmpty {
            items = items.filter { item in
                item.name.lowercased().contains(searchText.lowercased()) ||
                (item.subCategory?.lowercased().contains(searchText.lowercased()) ?? false)
            }
        }
        
        return items.filter { item in
            if item.isReusable {
                return true
            }
            
            let isPlaced = roomManager.placedObjects.contains { placedObj in
                placedObj.itemId == item.id
            }
            
            return !isPlaced
        }
    }
    
    private func placeItem(_ item: Item) {
        var placed = false
        
        for y in stride(from: 0.0, to: roomManager.gridHeight, by: 0.5) {
            for x in stride(from: 0.0, to: roomManager.gridWidth, by: 0.5) {
                if roomManager.canPlace(item: item, at: x, gridY: y, rotation: 0) {
                    roomManager.placeObject(item: item, at: x, gridY: y)
                    SoundManager.shared.itemPlace()
                    placementMessage = "\(item.name) placed in room!"
                    showPlacementAlert = true
                    placed = true
                    return
                }
            }
        }
        
        if !placed {
            SoundManager.shared.purchaseFail()
            placementMessage = "No space available! Remove some items first."
            showPlacementAlert = true
        }
    }
    
    private func groupItemsBySubCategory(_ items: [Item]) -> [String: [Item]] {
        Dictionary(grouping: items) { $0.subCategory ?? "Other" }
    }
    
    private func getSortedSubCategories(keys: [String]) -> [String] {
        let order = ["Beds", "Tables", "Chairs", "Storage", "Wall Mounted", "Decorations", "Other"]
        return keys.sorted { (a, b) -> Bool in
            let indexA = order.firstIndex(of: a) ?? Int.max
            let indexB = order.firstIndex(of: b) ?? Int.max
            return indexA < indexB
        }
    }
}
