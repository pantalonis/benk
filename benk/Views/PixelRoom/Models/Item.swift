//
//  Item.swift
//  Pixel Room Customizer
//
//  Core data models for items, furniture, and room objects
//

import Foundation
import SwiftUI

// MARK: - Item Category
enum ItemCategory: String, Codable, CaseIterable {
    case furniture = "Furniture"
    case decoration = "Decorations"
    case pet = "Pets"
    case windowView = "Window Views"
    case roomTheme = "Room Themes"
}

// MARK: - Item Model
struct Item: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let imageName: String
    let category: ItemCategory
    let price: Int
    let gridWidth: Int  // Width in grid cells
    let gridDepth: Int  // Depth in grid cells
    let canRotate: Bool
    let isReusable: Bool  // Can be placed multiple times
    let subCategory: String? // Optional sub-category for grouping
    
    init(
        id: String,
        name: String,
        imageName: String,
        category: ItemCategory,
        price: Int,
        gridWidth: Int = 1,
        gridDepth: Int = 1,
        canRotate: Bool = true,
        isReusable: Bool = false,
        subCategory: String? = nil
    ) {
        self.id = id
        self.name = name
        self.imageName = imageName
        self.category = category
        self.price = price
        self.gridWidth = gridWidth
        self.gridDepth = gridDepth
        self.canRotate = canRotate
        self.isReusable = isReusable
        self.subCategory = subCategory
    }
}

// MARK: - Placed Object (Instance of item in room)
struct PlacedObject: Identifiable, Codable, Equatable {
    let id: UUID
    let itemId: String
    var gridX: Double // Changed to Double for fine positioning
    var gridY: Double
    var rotation: Int  // 0, 90, 180, 270 degrees
    var zIndex: Int  // For depth sorting
    var sizeScale: CGFloat  // Individual size scale (0.5 to 2.0)
    
    init(
        id: UUID = UUID(),
        itemId: String,
        gridX: Double,
        gridY: Double,
        rotation: Int = 0,
        zIndex: Int = 0,
        sizeScale: CGFloat = 1.0
    ) {
        self.id = id
        self.itemId = itemId
        self.gridX = gridX
        self.gridY = gridY
        self.rotation = rotation
        self.zIndex = zIndex
        self.sizeScale = sizeScale
    }
}

// MARK: - Window Background
struct WindowBackground: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let imageName: String
    let price: Int
    
    init(
        id: UUID = UUID(),
        name: String,
        imageName: String,
        price: Int
    ) {
        self.id = id
        self.name = name
        self.imageName = imageName
        self.price = price
    }
}

// MARK: - Sample Data Catalog
struct ItemCatalog {
    
    // MARK: - Furniture Items
    static let furnitureItems: [Item] = [
        // ═══════════════════════════════════════════════════════════════
        // BEDS
        // ═══════════════════════════════════════════════════════════════
        
        // BASIC BEDS (Affordable starters)
        Item(id: "bed_extra_3", name: "Simple Bed", imageName: "bed_extra_3", category: .furniture, price: 50, gridWidth: 2, gridDepth: 2, subCategory: "Beds"),
        Item(id: "bed_extra_4", name: "Basic Bed", imageName: "bed_extra_4", category: .furniture, price: 60, gridWidth: 2, gridDepth: 2, subCategory: "Beds"),
        
        // COMMON BEDS
        Item(id: "bed_a", name: "Standard Bed", imageName: "bed_a", category: .furniture, price: 100, gridWidth: 2, gridDepth: 2, subCategory: "Beds"),
        Item(id: "bed_b", name: "Cozy Bed", imageName: "bed_b", category: .furniture, price: 120, gridWidth: 2, gridDepth: 2, subCategory: "Beds"),
        Item(id: "bed_extra_2", name: "Baby Bed", imageName: "bed_extra_2", category: .furniture, price: 90, gridWidth: 2, gridDepth: 2, subCategory: "Beds"),
        
        // UNCOMMON BEDS
        Item(id: "bed_c", name: "Luxury Bed", imageName: "bed_c", category: .furniture, price: 180, gridWidth: 2, gridDepth: 2, subCategory: "Beds"),
        Item(id: "bed_extra_1", name: "Modern Bed", imageName: "bed_extra_1", category: .furniture, price: 200, gridWidth: 2, gridDepth: 1, subCategory: "Beds"),
        
        // RARE BEDS (Premium)
        Item(id: "bed_extra_5", name: "Designer Bed", imageName: "bed_extra_5", category: .furniture, price: 350, gridWidth: 2, gridDepth: 2, subCategory: "Beds"),
        Item(id: "bed_extra_6", name: "Royal Bed", imageName: "bed_extra_6", category: .furniture, price: 400, gridWidth: 2, gridDepth: 2, subCategory: "Beds"),
        Item(id: "bed_extra_7", name: "Premium Bed", imageName: "bed_extra_7", category: .furniture, price: 380, gridWidth: 2, gridDepth: 2, subCategory: "Beds"),
        Item(id: "bed_extra_8", name: "Elite Bed", imageName: "bed_extra_8", category: .furniture, price: 420, gridWidth: 2, gridDepth: 2, subCategory: "Beds"),
        
        // LEGENDARY BED - Royal Regalia Collection
        Item(id: "fur_extra_4", name: "Royal Amethyst Bed", imageName: "fur_extra_4", category: .furniture, price: 1500, gridWidth: 2, gridDepth: 2, subCategory: "Beds"),
        
        // ═══════════════════════════════════════════════════════════════
        // TABLES
        // ═══════════════════════════════════════════════════════════════
        
        // BASIC TABLES
        Item(id: "table_1", name: "Dark Oak Dining Table", imageName: "fur_table4", category: .furniture, price: 180, gridWidth: 2, gridDepth: 2, subCategory: "Tables"),
        Item(id: "kitchen_cart_1", name: "Kitchen Cart", imageName: "fur_kitchen_car", category: .furniture, price: 65, gridWidth: 2, gridDepth: 2, subCategory: "Tables"),
        
        // COMMON TABLES
        Item(id: "desk_1", name: "Study Desk", imageName: "fur_desk", category: .furniture, price: 90, gridWidth: 1, gridDepth: 1, subCategory: "Tables"),
        Item(id: "fur_extra_14", name: "Kitchen Shelf Unit", imageName: "fur_extra_14", category: .furniture, price: 120, gridWidth: 2, gridDepth: 2, subCategory: "Tables"),
        Item(id: "fur_extra_7", name: "Reading Nightstand", imageName: "fur_extra_7", category: .furniture, price: 95, gridWidth: 2, gridDepth: 2, subCategory: "Tables"),
        
        // RARE TABLES
        Item(id: "fur_extra_19", name: "Oak Dining Set", imageName: "fur_extra_19", category: .furniture, price: 420, gridWidth: 2, gridDepth: 2, subCategory: "Tables"),
        Item(id: "fur_extra_33", name: "Terrarium Workspace", imageName: "fur_extra_33", category: .furniture, price: 380, gridWidth: 2, gridDepth: 2, subCategory: "Tables"),
        
        // PRO GAMING COLLECTION - Tables
        Item(id: "fur_extra_1", name: "Futuristic Gaming Setup", imageName: "fur_extra_1", category: .furniture, price: 450, gridWidth: 2, gridDepth: 2, subCategory: "Pro Gaming Collection"),
        Item(id: "fur_extra_2", name: "Elite Gaming Station", imageName: "fur_extra_2", category: .furniture, price: 650, gridWidth: 2, gridDepth: 2, subCategory: "Pro Gaming Collection"),
        Item(id: "fur_extra_31", name: "Modern Gaming Desk", imageName: "fur_extra_31", category: .furniture, price: 350, gridWidth: 2, gridDepth: 2, subCategory: "Pro Gaming Collection"),
        Item(id: "PC", name: "Gaming PC Setup", imageName: "PC", category: .furniture, price: 750, gridWidth: 2, gridDepth: 1, subCategory: "Pro Gaming Collection"),
        
        // ═══════════════════════════════════════════════════════════════
        // SEATING
        // ═══════════════════════════════════════════════════════════════
        
        // BASIC SEATING
        Item(id: "chair_1", name: "Comfort Sofa", imageName: "fur_chair", category: .furniture, price: 120, gridWidth: 1, gridDepth: 1, subCategory: "Seating"),
        
        // UNCOMMON SEATING
        Item(id: "fur_extra_20", name: "Yellow Reading Nook", imageName: "fur_extra_20", category: .furniture, price: 280, gridWidth: 2, gridDepth: 2, subCategory: "Seating"),
        
        // RARE SEATING
        Item(id: "fur_extra_8", name: "Family Sofa", imageName: "fur_extra_8", category: .furniture, price: 380, gridWidth: 2, gridDepth: 2, subCategory: "Seating"),
        
        // EPIC SEATING - Living Room Set
        Item(id: "photo_1", name: "Living Room Collection", imageName: "fur_fam", category: .furniture, price: 850, gridWidth: 3, gridDepth: 3, canRotate: false, subCategory: "Seating"),
        
        // LEGENDARY SEATING - Royal Regalia Collection
        Item(id: "fur_extra_3", name: "Royal Throne", imageName: "fur_extra_3", category: .furniture, price: 1200, gridWidth: 2, gridDepth: 2, subCategory: "Royal Regalia Collection"),
        
        // ═══════════════════════════════════════════════════════════════
        // STORAGE
        // ═══════════════════════════════════════════════════════════════
        
        // BASIC STORAGE
        Item(id: "bookshelf_1", name: "Bookshelf", imageName: "fur_big_book", category: .furniture, price: 95, gridWidth: 2, gridDepth: 2, subCategory: "Storage"),
        
        // UNCOMMON STORAGE
        Item(id: "dresser_1", name: "Mirrored Wardrobe", imageName: "fur_dress_shelve", category: .furniture, price: 180, gridWidth: 2, gridDepth: 2, subCategory: "Storage"),
        Item(id: "mirror_1", name: "Oak Vanity Dresser", imageName: "fur_mirror", category: .furniture, price: 220, gridWidth: 2, gridDepth: 2, canRotate: false, subCategory: "Storage"),
        
        // RARE STORAGE
        Item(id: "fur_extra_30", name: "Corner Library Bookshelf", imageName: "fur_extra_30", category: .furniture, price: 350, gridWidth: 2, gridDepth: 2, subCategory: "Storage"),
        
        // EPIC STORAGE - Royal Regalia Collection
        Item(id: "fur_extra_38", name: "Royal Vanity Mirror", imageName: "fur_extra_38", category: .furniture, price: 680, gridWidth: 2, gridDepth: 2, subCategory: "Royal Regalia Collection"),
        
        // ═══════════════════════════════════════════════════════════════
        // CLOCKS
        // ═══════════════════════════════════════════════════════════════
        
        // BASIC CLOCKS
        Item(id: "fur_extra_12", name: "Analog Clock", imageName: "fur_extra_12", category: .furniture, price: 65, gridWidth: 1, gridDepth: 1, subCategory: "Clocks"),
        Item(id: "fur_extra_15", name: "Classic Alarm Clock", imageName: "fur_extra_15", category: .furniture, price: 75, gridWidth: 1, gridDepth: 1, subCategory: "Clocks"),
        
        // UNCOMMON CLOCKS
        Item(id: "fur_extra_25", name: "Futuristic Floating Clock", imageName: "fur_extra_25", category: .furniture, price: 280, gridWidth: 1, gridDepth: 1, subCategory: "Clocks"),
        
        // RARE CLOCKS
        Item(id: "clock_1", name: "Dark Oak Grandfather Clock", imageName: "fur_clock", category: .furniture, price: 320, gridWidth: 2, gridDepth: 2, canRotate: false, subCategory: "Clocks"),
        Item(id: "fur_extra_17", name: "Neon Cube Clock", imageName: "fur_extra_17", category: .furniture, price: 380, gridWidth: 1, gridDepth: 1, subCategory: "Clocks"),
        
        // EPIC CLOCKS
        Item(id: "fur_extra_6", name: "Mystical Grandfather Clock", imageName: "fur_extra_6", category: .furniture, price: 480, gridWidth: 2, gridDepth: 2, subCategory: "Clocks"),
        
        // ═══════════════════════════════════════════════════════════════
        // DECORATIONS
        // ═══════════════════════════════════════════════════════════════
        
        // BASIC DECORATIONS
        Item(id: "simple plant", name: "Simple Plant", imageName: "simple plant", category: .furniture, price: 25, gridWidth: 1, gridDepth: 1, subCategory: "Decorations"),
        Item(id: "flying baloon", name: "Flying Balloon", imageName: "flying baloon", category: .furniture, price: 55, gridWidth: 1, gridDepth: 2, subCategory: "Decorations"),
        Item(id: "adventures rouge", name: "Adventure Scroll Stand", imageName: "adventures rouge", category: .furniture, price: 85, gridWidth: 1, gridDepth: 1, subCategory: "Decorations"),
        
        // COMMON DECORATIONS
        Item(id: "console_1", name: "Retro Console", imageName: "fur_game", category: .furniture, price: 95, gridWidth: 1, gridDepth: 1, isReusable: true, subCategory: "Decorations"),
        Item(id: "gamers land", name: "Game in a Bottle", imageName: "gamers land", category: .furniture, price: 150, gridWidth: 1, gridDepth: 1, subCategory: "Decorations"),
        
        // UNCOMMON DECORATIONS
        Item(id: "fur_extra_11", name: "Record Player", imageName: "fur_extra_11", category: .furniture, price: 160, gridWidth: 2, gridDepth: 2, subCategory: "Decorations"),
        Item(id: "fur_extra_16", name: "Victory Trophy", imageName: "fur_extra_16", category: .furniture, price: 200, gridWidth: 1, gridDepth: 1, subCategory: "Decorations"),
        
        // RARE DECORATIONS
        Item(id: "cat with PC", name: "Cat with PC", imageName: "cat with PC", category: .furniture, price: 320, gridWidth: 2, gridDepth: 1, subCategory: "Decorations"),
        
        // EPIC DECORATIONS (Premium items - must save!)
        Item(id: "saber", name: "Light Saber", imageName: "saber", category: .furniture, price: 500, gridWidth: 1, gridDepth: 1, subCategory: "Decorations"),
        Item(id: "Legend katana", name: "Legendary Katana", imageName: "Legend katana", category: .furniture, price: 600, gridWidth: 2, gridDepth: 1, subCategory: "Decorations"),
        Item(id: "secret orb", name: "Mystical Orb", imageName: "secret orb", category: .furniture, price: 750, gridWidth: 1, gridDepth: 1, subCategory: "Decorations"),
    ]
    
    // MARK: - Decoration Items (Rugs)
    static let decorationItems: [Item] = [
        // BASIC RUGS (Affordable)
        Item(id: "rug_3", name: "Simple Round Mat", imageName: "rug_3", category: .decoration, price: 30, gridWidth: 2, gridDepth: 2, canRotate: false, isReusable: true),
        Item(id: "rug 28", name: "Basic Rug", imageName: "rug 28", category: .decoration, price: 35, gridWidth: 2, gridDepth: 2, canRotate: false, isReusable: true),
        Item(id: "rug 29", name: "Simple Mat", imageName: "rug 29", category: .decoration, price: 35, gridWidth: 2, gridDepth: 2, canRotate: false, isReusable: true),
        
        // COMMON RUGS
        Item(id: "rug_2", name: "Wool Rug", imageName: "rug2", category: .decoration, price: 50, gridWidth: 2, gridDepth: 2, canRotate: false, isReusable: true),
        Item(id: "rug23", name: "Cozy Rug", imageName: "rug23", category: .decoration, price: 55, gridWidth: 2, gridDepth: 2, canRotate: false, isReusable: true),
        Item(id: "rug25", name: "Comfort Rug", imageName: "rug25", category: .decoration, price: 55, gridWidth: 2, gridDepth: 2, canRotate: false, isReusable: true),
        Item(id: "rug 30", name: "3D Forest Rug", imageName: "rug 30", category: .decoration, price: 280, gridWidth: 2, gridDepth: 2, canRotate: false, isReusable: true),
        Item(id: "rug 31", name: "Classic Rug", imageName: "rug 31", category: .decoration, price: 60, gridWidth: 2, gridDepth: 2, canRotate: false, isReusable: true),
        
        // UNCOMMON RUGS (Nice quality)
        Item(id: "rug 27", name: "Designer Rug", imageName: "rug 27", category: .decoration, price: 80, gridWidth: 2, gridDepth: 2, canRotate: false, isReusable: true),
        Item(id: "rug 40", name: "Premium Rug", imageName: "rug 40", category: .decoration, price: 90, gridWidth: 2, gridDepth: 2, canRotate: false, isReusable: true),
        Item(id: "rug 41", name: "Luxury Mat", imageName: "rug 41", category: .decoration, price: 95, gridWidth: 2, gridDepth: 2, canRotate: false, isReusable: true),
        
        // RARE RUGS (Premium)
        Item(id: "rug_1", name: "Persian Rug", imageName: "rug1", category: .decoration, price: 120, gridWidth: 2, gridDepth: 2, canRotate: false, isReusable: true),
    ]
    
    // MARK: - Pet Items
    static let petItems: [Item] = [
        // COMMON PETS (Affordable companions)
        Item(id: "chicat", name: "Chicat", imageName: "chicat", category: .pet, price: 80, gridWidth: 1, gridDepth: 1, canRotate: false),
        Item(id: "ocat", name: "Ocat", imageName: "ocat", category: .pet, price: 85, gridWidth: 1, gridDepth: 1, canRotate: false),
        Item(id: "blaite", name: "Blaite", imageName: "blaite", category: .pet, price: 90, gridWidth: 1, gridDepth: 1, canRotate: false),
        Item(id: "quark", name: "Quark", imageName: "quark", category: .pet, price: 95, gridWidth: 1, gridDepth: 1, canRotate: false),
        Item(id: "donuham", name: "Donuham", imageName: "donuham", category: .pet, price: 100, gridWidth: 1, gridDepth: 1, canRotate: false),
        
        // UNCOMMON PETS (Nice companions)
        Item(id: "racone", name: "Racone", imageName: "racone", category: .pet, price: 120, gridWidth: 1, gridDepth: 1, canRotate: false),
        Item(id: "tanuki", name: "Tanuki", imageName: "tanuki", category: .pet, price: 130, gridWidth: 1, gridDepth: 1, canRotate: false),
        Item(id: "lightcam", name: "Lightcam", imageName: "lightcam", category: .pet, price: 140, gridWidth: 1, gridDepth: 1, canRotate: false),
        Item(id: "luparc", name: "Luparc", imageName: "luparc", category: .pet, price: 150, gridWidth: 1, gridDepth: 1, canRotate: false),
        Item(id: "gyumei", name: "Gyumei", imageName: "gyumei", category: .pet, price: 160, gridWidth: 1, gridDepth: 1, canRotate: false),
        
        // RARE PETS (Premium companions)
        Item(id: "cat_1", name: "Tabby Cat", imageName: "pet_1", category: .pet, price: 200, gridWidth: 1, gridDepth: 1, canRotate: false),
        Item(id: "dog_1", name: "Golden Retriever", imageName: "pet_2", category: .pet, price: 220, gridWidth: 1, gridDepth: 1, canRotate: false),
        Item(id: "pet_extra_1", name: "Siamese Cat", imageName: "pet_extra_1", category: .pet, price: 240, gridWidth: 1, gridDepth: 1, canRotate: false),
        Item(id: "pet_extra_2", name: "Bulldog", imageName: "pet_extra_2", category: .pet, price: 260, gridWidth: 1, gridDepth: 1, canRotate: false),
        Item(id: "pet_extra_4", name: "Exotic Pet", imageName: "pet_extra_4", category: .pet, price: 280, gridWidth: 1, gridDepth: 1, canRotate: false),
        Item(id: "pet_extra_5", name: "Rare Companion", imageName: "pet_extra_5", category: .pet, price: 300, gridWidth: 1, gridDepth: 1, canRotate: false),
        
        // EPIC PETS (Special companions)
        Item(id: "alisbear", name: "Alisbear", imageName: "alisbear", category: .pet, price: 350, gridWidth: 1, gridDepth: 1, canRotate: false),
        Item(id: "unisheep", name: "Unisheep", imageName: "unisheep", category: .pet, price: 380, gridWidth: 1, gridDepth: 1, canRotate: false),
        Item(id: "pet_extra_6", name: "Elite Pet", imageName: "pet_extra_6", category: .pet, price: 400, gridWidth: 1, gridDepth: 1, canRotate: false),
        
        // LEGENDARY PETS (Ultra rare!)
        Item(id: "pet_extra_3", name: "Mystical Parrot", imageName: "pet_extra_3", category: .pet, price: 500, gridWidth: 1, gridDepth: 1, canRotate: false),
        Item(id: "fairy owl", name: "Fairy Owl", imageName: "fairy owl", category: .pet, price: 600, gridWidth: 1, gridDepth: 1, canRotate: false),
    ]
    
    // MARK: - Room Themes
    static let roomThemes: [Item] = [
        Item(id: "room_theme_1", name: "Room Theme 1", imageName: "room_theme_1", category: .roomTheme, price: 500, gridWidth: 0, gridDepth: 0, canRotate: false, isReusable: true),
        Item(id: "room_theme_2", name: "Room Theme 2", imageName: "room_theme_2", category: .roomTheme, price: 500, gridWidth: 0, gridDepth: 0, canRotate: false, isReusable: true),
        Item(id: "room_theme_3", name: "Room Theme 3", imageName: "room_theme_3", category: .roomTheme, price: 500, gridWidth: 0, gridDepth: 0, canRotate: false, isReusable: true),
        Item(id: "room_theme_4", name: "Room Theme 4", imageName: "room_theme_4", category: .roomTheme, price: 500, gridWidth: 0, gridDepth: 0, canRotate: false, isReusable: true),
        Item(id: "room_theme_5", name: "Room Theme 5", imageName: "room_theme_5", category: .roomTheme, price: 500, gridWidth: 0, gridDepth: 0, canRotate: false, isReusable: true),
        
        // New Room Themes
        Item(id: "room_theme_6", name: "Room Theme 6", imageName: "room_theme_6", category: .roomTheme, price: 500, gridWidth: 0, gridDepth: 0, canRotate: false, isReusable: true),
        Item(id: "room_theme_7", name: "Room Theme 7", imageName: "room_theme_7", category: .roomTheme, price: 500, gridWidth: 0, gridDepth: 0, canRotate: false, isReusable: true),
        Item(id: "room_theme_8", name: "Room Theme 8", imageName: "room_theme_8", category: .roomTheme, price: 500, gridWidth: 0, gridDepth: 0, canRotate: false, isReusable: true),
        Item(id: "room_theme_9", name: "Room Theme 9", imageName: "room_theme_9", category: .roomTheme, price: 500, gridWidth: 0, gridDepth: 0, canRotate: false, isReusable: true),
        Item(id: "room_theme_10", name: "Room Theme 10", imageName: "room_theme_10", category: .roomTheme, price: 500, gridWidth: 0, gridDepth: 0, canRotate: false, isReusable: true),
        
        Item(id: "autumn vibe", name: "Autumn Vibe", imageName: "autumn vibe", category: .roomTheme, price: 500, gridWidth: 0, gridDepth: 0, canRotate: false, isReusable: true),
        Item(id: "candy island", name: "Candy Island", imageName: "candy island", category: .roomTheme, price: 500, gridWidth: 0, gridDepth: 0, canRotate: false, isReusable: true),
        Item(id: "christmas pallet", name: "Christmas Pallet", imageName: "christmas pallet", category: .roomTheme, price: 500, gridWidth: 0, gridDepth: 0, canRotate: false, isReusable: true),
        Item(id: "dark fantasy", name: "Dark Fantasy", imageName: "dark fantasy", category: .roomTheme, price: 500, gridWidth: 0, gridDepth: 0, canRotate: false, isReusable: true),
        Item(id: "dark knight", name: "Dark Knight", imageName: "dark knight", category: .roomTheme, price: 500, gridWidth: 0, gridDepth: 0, canRotate: false, isReusable: true),
        Item(id: "green rock", name: "Green Rock", imageName: "green rock", category: .roomTheme, price: 500, gridWidth: 0, gridDepth: 0, canRotate: false, isReusable: true),
        Item(id: "happy days", name: "Happy Days", imageName: "happy days", category: .roomTheme, price: 500, gridWidth: 0, gridDepth: 0, canRotate: false, isReusable: true),
        Item(id: "japan sakura", name: "Japan Sakura", imageName: "japan sakura", category: .roomTheme, price: 500, gridWidth: 0, gridDepth: 0, canRotate: false, isReusable: true),
        Item(id: "magical fan", name: "Magical Fan", imageName: "magical fan", category: .roomTheme, price: 500, gridWidth: 0, gridDepth: 0, canRotate: false, isReusable: true),
        Item(id: "moon purple", name: "Moon Purple", imageName: "moon purple", category: .roomTheme, price: 500, gridWidth: 0, gridDepth: 0, canRotate: false, isReusable: true),
        Item(id: "seals", name: "Seals", imageName: "seals", category: .roomTheme, price: 500, gridWidth: 0, gridDepth: 0, canRotate: false, isReusable: true),
        Item(id: "simple wabisabi", name: "Simple Wabisabi", imageName: "simple wabisabi", category: .roomTheme, price: 500, gridWidth: 0, gridDepth: 0, canRotate: false, isReusable: true),
    ]
    
    // MARK: - Window Backgrounds
    static let windowBackgrounds: [WindowBackground] = [
        WindowBackground(name: "City Day", imageName: "win1", price: 50),
        WindowBackground(name: "City Night", imageName: "win2", price: 50),
        WindowBackground(name: "Forest", imageName: "win_3", price: 50),
        
        // New Window Views
        WindowBackground(name: "Aquantis", imageName: "aquantis", price: 100),
        WindowBackground(name: "Cyber City", imageName: "cyber city", price: 100),
        WindowBackground(name: "Fairy Tale", imageName: "fairy tale", price: 100),
        WindowBackground(name: "Fantasy Mushroom", imageName: "fantacy mushroom", price: 100),
        WindowBackground(name: "Floating Village", imageName: "floating village", price: 100),
        WindowBackground(name: "Neon Japan", imageName: "neon japan", price: 100),
        WindowBackground(name: "Pirates Sea", imageName: "pirates sea", price: 100),
        WindowBackground(name: "Snowy Town", imageName: "snowy town", price: 100),
    ]
    
    // MARK: - All Shop Items
    static var allShopItems: [Item] {
        return furnitureItems + decorationItems + petItems + roomThemes
    }

}
