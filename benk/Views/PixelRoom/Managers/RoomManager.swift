//
//  RoomManager.swift
//  Pixel Room Customizer
//
//  Manages room state, furniture placement, and grid system
//

import Foundation
import Combine
import SwiftUI

class RoomManager: ObservableObject {
    // MARK: - Shared Instance
    static let shared = RoomManager()
    
    // MARK: - Published Properties
    @Published var placedObjects: [PlacedObject] = []
    @Published var currentWindowBackground: WindowBackground?
    @Published var selectedObjectId: UUID?
    @Published var currentRoomTheme: Item?
    @Published var windowPosition: CGPoint = CGPoint(x: 0.5, y: 0.25) // Normalized position (0-1)
    @Published var itemSizeScale: CGFloat = 1.0 // Scale factor for item sizes (0.5 to 2.0)
    
    // MARK: - Grid Configuration
    let gridWidth: Double = 8.0   // Use double for consistency
    let gridHeight: Double = 8.0
    let cellSize: CGFloat = 40  // Size of each grid cell in points
    
    // Changed key to v2 to avoid conflicts with old Int-based data
    private let placedObjectsKey = "placed_objects_v2"
    private let windowBackgroundKey = "current_window_background"
    private let roomThemeKey = "current_room_theme"
    private let windowPositionKey = "window_position"
    private let itemSizeScaleKey = "item_size_scale"
    
    // Reference to inventory to look up item details
    private var inventoryManager: InventoryManager?
    
    init() {
        loadItemSizeScale()
        // loadRoomState() // Disabled to reset room as requested
    }
    
    func setInventoryManager(_ manager: InventoryManager) {
        self.inventoryManager = manager
    }
    
    func updateWindowPosition(_ position: CGPoint) {
        windowPosition = position
        saveRoomState()
    }
    
    func updateItemSizeScale(_ scale: CGFloat) {
        itemSizeScale = max(0.5, min(2.0, scale)) // Clamp between 0.5 and 2.0
        UserDefaults.standard.set(Double(itemSizeScale), forKey: itemSizeScaleKey)
    }

    // ...


    
    // MARK: - Object Placement
    
    func canPlace(item: Item, at gridX: Double, gridY: Double, rotation: Int, excluding excludedId: UUID? = nil) -> Bool {
        // Check bounds (using a small buffer to avoid floating point issues at edges)
        let (width, depth) = getRotatedDimensions(item: item, rotation: rotation)
        let itemWidth = Double(width)
        let itemDepth = Double(depth)
        
        // Allow placement slightly outside for "bleed" or strict containment?
        // Let's enforce strict containment within the 8x8 area logic
        guard gridX >= -1, gridY >= -1, // Allow slight edge bleed
              gridX + itemWidth <= gridWidth + 1,
              gridY + itemDepth <= gridHeight + 1 else {
            return false
        }
        
        // Check collision with other objects
        let newRect = CGRect(x: gridX, y: gridY, width: itemWidth, height: itemDepth)
        
        for placedObject in placedObjects {
            if let excludedId = excludedId, placedObject.id == excludedId {
                continue
            }
            
            if let placedItem = getItem(for: placedObject) {
                let (pWidth, pDepth) = getRotatedDimensions(item: placedItem, rotation: placedObject.rotation)
                let existingRect = CGRect(
                    x: placedObject.gridX,
                    y: placedObject.gridY,
                    width: Double(pWidth),
                    height: Double(pDepth)
                )
                
                // Allow a tiny bit of overlap (0.1) for smoother feel, or strict?
                // Using intersection with a small epsilon can help
                if newRect.intersects(existingRect.insetBy(dx: 0.1, dy: 0.1)) {
                    return false
                }
            }
        }
        
        return true
    }
    
    func placeObject(item: Item, at gridX: Double, gridY: Double) {
        let zIndex = calculateZIndex(gridX: gridX, gridY: gridY)
        let placedObject = PlacedObject(
            itemId: item.id,
            gridX: gridX,
            gridY: gridY,
            rotation: 0,
            zIndex: zIndex
        )
        
        if canPlace(item: item, at: gridX, gridY: gridY, rotation: 0) {
            placedObjects.append(placedObject)
            saveRoomState()
            AchievementManager.shared.onItemPlaced()
        }
    }
    
    func moveObject(id: UUID, to gridX: Double, gridY: Double) {
        guard let index = placedObjects.firstIndex(where: { $0.id == id }),
              let _ = getItem(for: placedObjects[index]) else {
            return
        }
        
        // Dimensions not needed for free movement
        // let (width, depth) = getRotatedDimensions(item: item, rotation: placedObjects[index].rotation)
        
        // Very Relaxed Clamping: Allow placing essentially anywhere (-100 to +100 buffer)
        let clampedX = max(-100.0, min(gridWidth + 100.0, gridX))
        let clampedY = max(-100.0, min(gridHeight + 100.0, gridY))
        
        placedObjects[index].gridX = clampedX
        placedObjects[index].gridY = clampedY
        placedObjects[index].zIndex = calculateZIndex(gridX: clampedX, gridY: clampedY)
        saveRoomState()
    }
    
    func rotateObject(id: UUID) {
        guard let index = placedObjects.firstIndex(where: { $0.id == id }),
              let item = getItem(for: placedObjects[index]),
              item.canRotate else {
            return
        }
        
        let newRotation = (placedObjects[index].rotation + 90) % 360
        placedObjects[index].rotation = newRotation
        
        // Also relax clamping for rotation
        let currentX = placedObjects[index].gridX
        let currentY = placedObjects[index].gridY
        
        let clampedX = max(-100.0, min(gridWidth + 100.0, currentX))
        let clampedY = max(-100.0, min(gridHeight + 100.0, currentY))
        
        placedObjects[index].gridX = clampedX
        placedObjects[index].gridY = clampedY
        
        saveRoomState()
    }
    
    func removeObject(id: UUID) {
        placedObjects.removeAll { $0.id == id }
        saveRoomState()
    }
    
    func updateObjectSize(id: UUID, scale: CGFloat) {
        guard let index = placedObjects.firstIndex(where: { $0.id == id }) else {
            return
        }
        placedObjects[index].sizeScale = max(0.5, min(2.0, scale))
        saveRoomState()
    }
    
    // MARK: - Window Background
    
    func setWindowBackground(_ background: WindowBackground) {
        currentWindowBackground = background
        saveRoomState()
    }
    
    func setRoomTheme(_ theme: Item) {
        currentRoomTheme = theme
        saveRoomState()
        AchievementManager.shared.onRoomThemeChanged(theme.id)
    }
    
    // MARK: - Helper Methods
    
    private func getRotatedDimensions(item: Item, rotation: Int) -> (width: Int, depth: Int) {
        if rotation == 90 || rotation == 270 {
            return (item.gridDepth, item.gridWidth)
        }
        return (item.gridWidth, item.gridDepth)
    }
    
    private func calculateZIndex(gridX: Double, gridY: Double) -> Int {
        // Isometric depth relies on the sum of X and Y (distance from "back" corner)
        // Multiply by 100 to handle fractional positioning
        // Add 50000 offset to ensure even items at negative coordinates (e.g. -100, -100) 
        // have a positive Z-index and stay above the background (Z=0)
        return Int((gridX + gridY) * 100) + 50000
    }
    
    func getItem(for placedObject: PlacedObject) -> Item? {
        // Search in all catalog items
        return ItemCatalog.allShopItems.first { $0.id == placedObject.itemId }
    }
    
    // MARK: - Persistence
    
    private func saveRoomState() {
        if let objectsData = try? JSONEncoder().encode(placedObjects) {
            UserDefaults.standard.set(objectsData, forKey: placedObjectsKey)
        }
        if let windowData = try? JSONEncoder().encode(currentWindowBackground) {
            UserDefaults.standard.set(windowData, forKey: windowBackgroundKey)
        }
        if let themeData = try? JSONEncoder().encode(currentRoomTheme) {
            UserDefaults.standard.set(themeData, forKey: roomThemeKey)
        }
        if let positionData = try? JSONEncoder().encode(windowPosition) {
            UserDefaults.standard.set(positionData, forKey: windowPositionKey)
        }
    }
    
    private func loadRoomState() {
        if let objectsData = UserDefaults.standard.data(forKey: placedObjectsKey),
           let objects = try? JSONDecoder().decode([PlacedObject].self, from: objectsData) {
            placedObjects = objects
            refreshZIndices() // Fix any incorrect Z-indices from previous versions
        }
        
        if let windowData = UserDefaults.standard.data(forKey: windowBackgroundKey),
           let window = try? JSONDecoder().decode(WindowBackground.self, from: windowData) {
            currentWindowBackground = window
        }
        
        if let themeData = UserDefaults.standard.data(forKey: roomThemeKey),
           let theme = try? JSONDecoder().decode(Item.self, from: themeData) {
            currentRoomTheme = theme
        }
        
        if let positionData = UserDefaults.standard.data(forKey: windowPositionKey),
           let position = try? JSONDecoder().decode(CGPoint.self, from: positionData) {
            windowPosition = position
        }
    }
    
    
    private func refreshZIndices() {
        for index in placedObjects.indices {
            placedObjects[index].zIndex = calculateZIndex(gridX: placedObjects[index].gridX, gridY: placedObjects[index].gridY)
        }
    }
    
    private func loadItemSizeScale() {
        let savedScale = UserDefaults.standard.double(forKey: itemSizeScaleKey)
        if savedScale > 0 {
            itemSizeScale = CGFloat(savedScale)
        } else {
            itemSizeScale = 1.0 // Default value
        }
    }
}
