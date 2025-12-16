//
//  InventoryManager.swift
//  Pixel Room Customizer
//
//  Manages purchased items in player's inventory
//

import Foundation
import Combine

class InventoryManager: ObservableObject {
    static let shared = InventoryManager()
    
    @Published var ownedItems: [Item] = []
    @Published var ownedWindowBackgrounds: [WindowBackground] = []
    
    private let itemsKey = "owned_items"
    private let windowsKey = "owned_windows"
    
    init() {
        // loadInventory() // Disabled to reset inventory as requested
    }
    
    // MARK: - Public Methods
    
    func owns(_ item: Item) -> Bool {
        return ownedItems.contains(where: { $0.id == item.id })
    }
    
    func owns(_ windowBackground: WindowBackground) -> Bool {
        return ownedWindowBackgrounds.contains(where: { $0.id == windowBackground.id })
    }
    
    func addItem(_ item: Item) {
        if !owns(item) {
            ownedItems.append(item)
            saveInventory()
            AchievementManager.shared.onItemPurchased(item)
        }
    }
    
    func addWindowBackground(_ windowBackground: WindowBackground) {
        if !owns(windowBackground) {
            ownedWindowBackgrounds.append(windowBackground)
            saveInventory()
        }
    }
    
    func getItemsByCategory(_ category: ItemCategory) -> [Item] {
        return ownedItems.filter { $0.category == category }
    }
    
    // MARK: - Persistence
    
    private func saveInventory() {
        if let itemsData = try? JSONEncoder().encode(ownedItems) {
            UserDefaults.standard.set(itemsData, forKey: itemsKey)
        }
        if let windowsData = try? JSONEncoder().encode(ownedWindowBackgrounds) {
            UserDefaults.standard.set(windowsData, forKey: windowsKey)
        }
    }
    
    private func loadInventory() {
        if let itemsData = UserDefaults.standard.data(forKey: itemsKey),
           let items = try? JSONDecoder().decode([Item].self, from: itemsData) {
            
            // Deduplicate items based on ID
            var seenIds = Set<String>()
            var uniqueItems: [Item] = []
            
            for item in items {
                if !seenIds.contains(item.id) {
                    uniqueItems.append(item)
                    seenIds.insert(item.id)
                }
            }
            
            ownedItems = uniqueItems
        }
        
        if let windowsData = UserDefaults.standard.data(forKey: windowsKey),
           let windows = try? JSONDecoder().decode([WindowBackground].self, from: windowsData) {
            ownedWindowBackgrounds = windows
        }
    }
}
