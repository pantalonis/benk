//
//  ShopEnhancements.swift
//  Pixel Room Customizer
//
//  Shop features: Sales, Bundles, Daily Deals, and Coin Earning
//

import Foundation
import SwiftUI
import Combine

// MARK: - Sale Item

struct SaleItem: Identifiable, Codable {
    let id: String
    let itemId: String
    let discountPercent: Int // 10-50%
    let endDate: Date
    
    var isActive: Bool {
        Date() < endDate
    }
    
    var discountedPrice: Int {
        guard let item = ItemCatalog.allShopItems.first(where: { $0.id == itemId }) else {
            return 0
        }
        let discount = Double(discountPercent) / 100.0
        return Int(Double(item.price) * (1.0 - discount))
    }
}

// MARK: - Bundle

struct ItemBundle: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let itemIds: [String]
    let bundlePrice: Int
    let regularPrice: Int
    let icon: String
    let isLimitedTime: Bool
    let endDate: Date?
    
    var savings: Int {
        regularPrice - bundlePrice
    }
    
    var discountPercent: Int {
        Int((Double(savings) / Double(regularPrice)) * 100)
    }
    
    var isActive: Bool {
        if isLimitedTime, let endDate = endDate {
            return Date() < endDate
        }
        return true
    }
}

// MARK: - Daily Deal

struct DailyDeal: Identifiable, Codable {
    let id: String
    let itemId: String
    let dealPrice: Int
    let date: Date
    
    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
}

// Coin Task Removed

// MARK: - Shop Manager

class ShopManager: ObservableObject {
    static let shared = ShopManager()
    
    @Published var activeSales: [SaleItem] = []
    @Published var availableBundles: [ItemBundle] = []
    @Published var dailyDeal: DailyDeal?
    
    private init() {
        loadShopData()
        generateDailyContent()
    }
    
    // MARK: - Sales
    
    func isItemOnSale(_ itemId: String) -> Bool {
        activeSales.contains { $0.itemId == itemId && $0.isActive }
    }
    
    func getSaleForItem(_ itemId: String) -> SaleItem? {
        activeSales.first { $0.itemId == itemId && $0.isActive }
    }
    
    func getSalePrice(for item: Item) -> Int? {
        guard let sale = getSaleForItem(item.id) else { return nil }
        return sale.discountedPrice
    }
    
    // MARK: - Bundles
    
    func canAffordBundle(_ bundle: ItemBundle, coins: Int) -> Bool {
        return coins >= bundle.bundlePrice
    }
    
    func purchaseBundle(_ bundle: ItemBundle) -> Bool {
        guard CurrencyManager.shared.spend(bundle.bundlePrice) else {
            return false
        }
        
        // Add all items in bundle to inventory
        for itemId in bundle.itemIds {
            if let item = ItemCatalog.allShopItems.first(where: { $0.id == itemId }) {
                InventoryManager.shared.addItem(item)
            }
        }
        
        HapticManager.shared.success()
        return true
    }
    
    // MARK: - Daily Deal
    
    func generateDailyDeal() {
        let allItems = ItemCatalog.allShopItems
        guard let randomItem = allItems.randomElement() else { return }
        
        let dealPrice = Int(Double(randomItem.price) * 0.6) // 40% off
        
        dailyDeal = DailyDeal(
            id: UUID().uuidString,
            itemId: randomItem.id,
            dealPrice: dealPrice,
            date: Date()
        )
    }
    
    // MARK: - Generate Content
    
    private func generateDailyContent() {
        generateDailySales()
        generateDailyDeal()
    }
    
    private func generateDailySales() {
        // Generate 3-5 random sales
        let saleCount = Int.random(in: 3...5)
        let allItems = ItemCatalog.allShopItems
        
        activeSales = (0..<saleCount).compactMap { _ in
            guard let item = allItems.randomElement() else { return nil }
            
            let discount = [10, 15, 20, 25, 30, 40, 50].randomElement() ?? 20
            let endDate = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
            
            return SaleItem(
                id: UUID().uuidString,
                itemId: item.id,
                discountPercent: discount,
                endDate: endDate
            )
        }
    }
    
    // MARK: - Bundles Catalog
    
    func loadPredefinedBundles() {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        
        availableBundles = [
            // Starter Pack: Simple Bed (50) + Comfort Sofa (120) + Study Desk (90) + Simple Plant (25) = 285
            ItemBundle(
                id: "starter_pack",
                name: "Starter Pack",
                description: "Everything you need to begin!",
                itemIds: ["bed_extra_3", "chair_1", "desk_1", "simple plant"],
                bundlePrice: 200,
                regularPrice: 285,
                icon: "🎁",
                isLimitedTime: false,
                endDate: nil
            ),
            
            // Pet Lovers: Chicat (80) + Ocat (85) + Blaite (90) = 255
            ItemBundle(
                id: "pet_lovers",
                name: "Pet Lovers Bundle",
                description: "Adopt 3 adorable companions!",
                itemIds: ["chicat", "ocat", "blaite"],
                bundlePrice: 180,
                regularPrice: 255,
                icon: "🐾",
                isLimitedTime: false,
                endDate: nil
            ),
            
            // Cozy Corner: Yellow Reading Nook (280) + Bookshelf (95) + Wool Rug (50) + Simple Plant (25) = 450
            ItemBundle(
                id: "cozy_corner",
                name: "Cozy Corner",
                description: "Create a relaxing reading space",
                itemIds: ["fur_extra_20", "bookshelf_1", "rug_2", "simple plant"],
                bundlePrice: 320,
                regularPrice: 450,
                icon: "☕",
                isLimitedTime: false,
                endDate: nil
            ),
            
            // Pro Gaming Collection: All 4 gaming items
            // Futuristic Gaming Setup (450) + Elite Gaming Station (650) + Modern Gaming Desk (350) + Gaming PC Setup (750) = 2200
            ItemBundle(
                id: "pro_gaming",
                name: "Pro Gaming Collection",
                description: "The ultimate gaming setup bundle!",
                itemIds: ["fur_extra_1", "fur_extra_2", "fur_extra_31", "PC"],
                bundlePrice: 1500,
                regularPrice: 2200,
                icon: "🎮",
                isLimitedTime: false,
                endDate: nil
            ),
            
            // Royal Regalia Collection: Royal Throne (1200) + Royal Amethyst Bed (1500) + Royal Vanity Mirror (680) = 3380
            ItemBundle(
                id: "royal_regalia",
                name: "Royal Regalia Collection",
                description: "Rule your room like royalty!",
                itemIds: ["fur_extra_3", "fur_extra_4", "fur_extra_38"],
                bundlePrice: 2400,
                regularPrice: 3380,
                icon: "👑",
                isLimitedTime: true,
                endDate: tomorrow
            ),
            
            // Clock Collector: Analog Clock (65) + Classic Alarm Clock (75) + Dark Oak Grandfather Clock (320) = 460
            ItemBundle(
                id: "clock_collector",
                name: "Clock Collector",
                description: "Time is on your side!",
                itemIds: ["fur_extra_12", "fur_extra_15", "clock_1"],
                bundlePrice: 330,
                regularPrice: 460,
                icon: "⏰",
                isLimitedTime: false,
                endDate: nil
            ),
            
            // Luxury Bedroom: Royal Bed (400) + Mirrored Wardrobe (180) + Oak Vanity Dresser (220) + Persian Rug (120) = 920
            ItemBundle(
                id: "luxury_bedroom",
                name: "Luxury Bedroom",
                description: "Sleep in style!",
                itemIds: ["bed_extra_6", "dresser_1", "mirror_1", "rug_1"],
                bundlePrice: 650,
                regularPrice: 920,
                icon: "✨",
                isLimitedTime: false,
                endDate: nil
            )
        ]
    }
    
    // MARK: - Persistence
    
    private func loadShopData() {
        loadPredefinedBundles()
    }
}
