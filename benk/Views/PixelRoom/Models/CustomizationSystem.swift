//
//  CustomizationSystem.swift
//  Pixel Room Customizer
//
//  Advanced customization: Sizes and item variations
//

import SwiftUI
import Combine

// MARK: - Item Size

enum ItemSize: String, Codable, CaseIterable {
    case small = "Small"
    case medium = "Medium"
    case large = "Large"
    case extraLarge = "Extra Large"
    
    var multiplier: Double {
        switch self {
        case .small: return 0.75
        case .medium: return 1.0
        case .large: return 1.5
        case .extraLarge: return 2.0
        }
    }
    
    var priceMultiplier: Double {
        switch self {
        case .small: return 0.8
        case .medium: return 1.0
        case .large: return 1.3
        case .extraLarge: return 1.6
        }
    }
    
    var icon: String {
        switch self {
        case .small: return "s.circle"
        case .medium: return "m.circle"
        case .large: return "l.circle"
        case .extraLarge: return "xl.circle"
        }
    }
}

// MARK: - Customized Item

struct CustomizedItem: Identifiable, Codable {
    let id: String
    let baseItemId: String
    var selectedSize: ItemSize
    var customName: String?
    
    var finalPrice: Int {
        guard let baseItem = ItemCatalog.allShopItems.first(where: { $0.id == baseItemId }) else {
            return 0
        }
        
        let price = Double(baseItem.price) * selectedSize.priceMultiplier
        return Int(price)
    }
}

// MARK: - Customization Manager

class CustomizationManager: ObservableObject {
    static let shared = CustomizationManager()
    
    @Published var customizedItems: [CustomizedItem] = []
    @Published var customizableItemIds: Set<String> = []
    
    private init() {
        loadCustomizableItems()
        loadCustomizedItems()
    }
    
    // MARK: - Customizable Items
    
    func isCustomizable(_ itemId: String) -> Bool {
        return customizableItemIds.contains(itemId)
    }
    
    private func loadCustomizableItems() {
        // ALL items are customizable!
        customizableItemIds = Set(ItemCatalog.allShopItems.map { $0.id })
    }
    
    // MARK: - Customization
    
    func createCustomizedItem(baseItemId: String, size: ItemSize, customName: String?) -> CustomizedItem {
        let customItem = CustomizedItem(
            id: UUID().uuidString,
            baseItemId: baseItemId,
            selectedSize: size,
            customName: customName
        )
        
        customizedItems.append(customItem)
        saveCustomizedItems()
        
        return customItem
    }
    
    func updateCustomizedItem(_ item: CustomizedItem) {
        if let index = customizedItems.firstIndex(where: { $0.id == item.id }) {
            customizedItems[index] = item
            saveCustomizedItems()
        }
    }
    
    func deleteCustomizedItem(_ itemId: String) {
        customizedItems.removeAll { $0.id == itemId }
        saveCustomizedItems()
    }
    
    // MARK: - Persistence
    
    private func saveCustomizedItems() {
        if let data = try? JSONEncoder().encode(customizedItems) {
            UserDefaults.standard.set(data, forKey: "customizedItems")
        }
    }
    
    private func loadCustomizedItems() {
        if let data = UserDefaults.standard.data(forKey: "customizedItems"),
           let items = try? JSONDecoder().decode([CustomizedItem].self, from: data) {
            customizedItems = items
        }
    }
}
