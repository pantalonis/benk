//
//  SaveManager.swift
//  Pixel Room Customizer
//
//  Manages data persistence, auto-save, and iCloud sync
//

import Foundation
import Combine
import UIKit

class SaveManager: ObservableObject {
    static let shared = SaveManager()
    
    @Published var lastSaveTime: Date?
    @Published var isSaving: Bool = false
    @Published var isCloudSyncEnabled: Bool = false {
        didSet {
            UserDefaults.standard.set(isCloudSyncEnabled, forKey: "cloudSyncEnabled")
            if isCloudSyncEnabled {
                syncToCloud()
            }
        }
    }
    
    private var autoSaveTimer: Timer?
    private let autoSaveInterval: TimeInterval = 30.0 // 30 seconds
    
    // File URLs
    private var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private var saveFileURL: URL {
        documentsDirectory.appendingPathComponent("gameData.json")
    }
    
    private var cloudURL: URL? {
        FileManager.default.url(forUbiquityContainerIdentifier: nil)?
            .appendingPathComponent("Documents")
            .appendingPathComponent("gameData.json")
    }
    
    private init() {
        isCloudSyncEnabled = UserDefaults.standard.bool(forKey: "cloudSyncEnabled")
        startAutoSave()
        
        // Listen for app going to background
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }
    
    deinit {
        stopAutoSave()
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Game Data Structure
    
    struct GameData: Codable {
        var coins: Int
        var ownedItemIds: [String]
        var ownedWindowIds: [String]
        var placedObjects: [PlacedObjectData]
        var currentRoomThemeId: String?
        var currentWindowBackgroundId: String?
        var windowPosition: CGPointData
        var lastSaved: Date
        
        // Achievement data
        var achievementProgress: [String: AchievementProgress]
        var dailyTaskProgress: [String: DailyTaskProgress]
        var loginStreak: LoginStreak
        var dailyRewardClaimed: Bool
        var lastDailyRewardDate: Date?
        var currentDailyTaskIds: [String]
        var lastTaskResetDate: Date?
        var totalCoinsEarned: Int
        var totalItemsPurchased: Int
        var totalItemsPlaced: Int
        var uniqueRoomThemesUsed: [String]
        
        struct PlacedObjectData: Codable {
            let id: String
            let itemId: String
            let gridX: Double
            let gridY: Double
            let rotation: Int
            let zIndex: Int
        }
        
        struct CGPointData: Codable {
            let x: Double
            let y: Double
        }
    }
    
    // MARK: - Auto-Save
    
    func startAutoSave() {
        stopAutoSave() // Clear any existing timer
        
        autoSaveTimer = Timer.scheduledTimer(
            withTimeInterval: autoSaveInterval,
            repeats: true
        ) { [weak self] _ in
            self?.autoSave()
        }
    }
    
    func stopAutoSave() {
        autoSaveTimer?.invalidate()
        autoSaveTimer = nil
    }
    
    private func autoSave() {
        _Concurrency.Task {
            await saveGame()
        }
    }
    
    @objc private func appWillResignActive() {
        // Save immediately when app goes to background
        _Concurrency.Task {
            await saveGame()
        }
    }
    
    // MARK: - Save Game
    
    @MainActor
    func saveGame() async {
        guard !isSaving else { return }
        
        isSaving = true
        
        do {
            let achievementMgr = AchievementManager.shared
            
            // Gather data from managers
            let gameData = GameData(
                coins: CurrencyManager.shared.coins,
                ownedItemIds: InventoryManager.shared.ownedItems.map { $0.id },
                ownedWindowIds: InventoryManager.shared.ownedWindowBackgrounds.map { $0.id.uuidString },
                placedObjects: RoomManager.shared.placedObjects.map { placedObject in
                    GameData.PlacedObjectData(
                        id: placedObject.id.uuidString,
                        itemId: placedObject.itemId,
                        gridX: placedObject.gridX,
                        gridY: placedObject.gridY,
                        rotation: placedObject.rotation,
                        zIndex: placedObject.zIndex
                    )
                },
                currentRoomThemeId: RoomManager.shared.currentRoomTheme?.id,
                currentWindowBackgroundId: RoomManager.shared.currentWindowBackground?.id.uuidString,
                windowPosition: GameData.CGPointData(
                    x: RoomManager.shared.windowPosition.x,
                    y: RoomManager.shared.windowPosition.y
                ),
                lastSaved: Date(),
                // Achievement data
                achievementProgress: achievementMgr.achievementProgress,
                dailyTaskProgress: achievementMgr.dailyTaskProgress,
                loginStreak: achievementMgr.loginStreak,
                dailyRewardClaimed: achievementMgr.dailyRewardClaimed,
                lastDailyRewardDate: achievementMgr.lastDailyRewardDate,
                currentDailyTaskIds: achievementMgr.currentDailyTasks.map { $0.id },
                lastTaskResetDate: achievementMgr.lastTaskResetDate,
                totalCoinsEarned: achievementMgr.totalCoinsEarned,
                totalItemsPurchased: achievementMgr.totalItemsPurchased,
                totalItemsPlaced: achievementMgr.totalItemsPlaced,
                uniqueRoomThemesUsed: Array(achievementMgr.uniqueRoomThemesUsed)
            )
            
            // Encode to JSON
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(gameData)
            
            // Save to local file
            try data.write(to: saveFileURL)
            
            lastSaveTime = Date()
            
            // Sync to cloud if enabled
            if isCloudSyncEnabled {
                syncToCloud()
            }
            
            print("✅ Game saved successfully at \(lastSaveTime!)")
            
        } catch {
            print("❌ Error saving game: \(error)")
        }
        
        isSaving = false
    }
    
    // MARK: - Load Game
    
    @MainActor
    func loadGame() async -> Bool {
        // Try to load from cloud first if enabled
        if isCloudSyncEnabled, let cloudData = loadFromCloud() {
            return await restoreGameData(cloudData)
        }
        
        // Otherwise load from local
        guard let data = try? Data(contentsOf: saveFileURL) else {
            print("ℹ️ No save file found, starting fresh")
            return false
        }
        
        return await restoreGameData(data)
    }
    
    @MainActor
    private func restoreGameData(_ data: Data) async -> Bool {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let gameData = try decoder.decode(GameData.self, from: data)
            
            // Currency is now managed globally by CurrencyManager/UserDefaults
            // Do NOT overwrite with local save data
            // CurrencyManager.shared.coins = gameData.coins
            
            // Restore owned items
            InventoryManager.shared.ownedItems = gameData.ownedItemIds.compactMap { itemId in
                ItemCatalog.allShopItems.first { $0.id == itemId }
            }
            
            // Restore owned windows
            InventoryManager.shared.ownedWindowBackgrounds = gameData.ownedWindowIds.compactMap { windowId in
                guard let uuid = UUID(uuidString: windowId) else { return nil }
                return ItemCatalog.windowBackgrounds.first { $0.id == uuid }
            }
            
            // Restore placed objects
            RoomManager.shared.placedObjects = gameData.placedObjects.compactMap { placedData in
                guard let item = ItemCatalog.allShopItems.first(where: { $0.id == placedData.itemId }),
                      let uuid = UUID(uuidString: placedData.id) else {
                    return nil
                }
                
                return PlacedObject(
                    id: uuid,
                    itemId: item.id,
                    gridX: placedData.gridX,
                    gridY: placedData.gridY,
                    rotation: placedData.rotation,
                    zIndex: placedData.zIndex
                )
            }
            
            // Restore room theme
            if let themeId = gameData.currentRoomThemeId {
                RoomManager.shared.currentRoomTheme = ItemCatalog.roomThemes.first { $0.id == themeId }
            }
            
            // Restore window background
            if let windowId = gameData.currentWindowBackgroundId,
               let uuid = UUID(uuidString: windowId) {
                RoomManager.shared.currentWindowBackground = ItemCatalog.windowBackgrounds.first { $0.id == uuid }
            }
            
            // Restore window position
            RoomManager.shared.windowPosition = CGPoint(
                x: gameData.windowPosition.x,
                y: gameData.windowPosition.y
            )
            
            // Restore achievement data
            let achievementMgr = AchievementManager.shared
            achievementMgr.achievementProgress = gameData.achievementProgress
            achievementMgr.dailyTaskProgress = gameData.dailyTaskProgress
            achievementMgr.loginStreak = gameData.loginStreak
            achievementMgr.dailyRewardClaimed = gameData.dailyRewardClaimed
            achievementMgr.lastDailyRewardDate = gameData.lastDailyRewardDate
            achievementMgr.lastTaskResetDate = gameData.lastTaskResetDate
            achievementMgr.totalCoinsEarned = gameData.totalCoinsEarned
            achievementMgr.totalItemsPurchased = gameData.totalItemsPurchased
            achievementMgr.totalItemsPlaced = gameData.totalItemsPlaced
            achievementMgr.uniqueRoomThemesUsed = Set(gameData.uniqueRoomThemesUsed)
            
            // Restore daily tasks
            achievementMgr.currentDailyTasks = gameData.currentDailyTaskIds.compactMap { taskId in
                DailyTaskCatalog.allTasks.first { $0.id == taskId }
            }
            
            lastSaveTime = gameData.lastSaved
            
            print("✅ Game loaded successfully from \(gameData.lastSaved)")
            return true
            
        } catch {
            print("❌ Error loading game: \(error)")
            return false
        }
    }
    
    // MARK: - iCloud Sync
    
    private func syncToCloud() {
        guard isCloudSyncEnabled, let cloudURL = cloudURL else { return }
        
        // Ensure cloud directory exists
        let cloudDir = cloudURL.deletingLastPathComponent()
        try? FileManager.default.createDirectory(at: cloudDir, withIntermediateDirectories: true)
        
        // Copy local file to cloud
        if FileManager.default.fileExists(atPath: saveFileURL.path) {
            try? FileManager.default.removeItem(at: cloudURL)
            try? FileManager.default.copyItem(at: saveFileURL, to: cloudURL)
            print("☁️ Synced to iCloud")
        }
    }
    
    private func loadFromCloud() -> Data? {
        guard let cloudURL = cloudURL,
              FileManager.default.fileExists(atPath: cloudURL.path) else {
            return nil
        }
        
        return try? Data(contentsOf: cloudURL)
    }
    
    // MARK: - Export/Import
    
    func exportGameData() -> URL? {
        guard FileManager.default.fileExists(atPath: saveFileURL.path) else {
            return nil
        }
        
        // Create export file with timestamp
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let timestamp = dateFormatter.string(from: Date())
        
        let exportURL = documentsDirectory.appendingPathComponent("PixelRoom_Backup_\(timestamp).json")
        
        try? FileManager.default.copyItem(at: saveFileURL, to: exportURL)
        
        return exportURL
    }
    
    @MainActor
    func importGameData(from url: URL) async -> Bool {
        guard let data = try? Data(contentsOf: url) else {
            return false
        }
        
        // Validate the data
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        guard let _ = try? decoder.decode(GameData.self, from: data) else {
            print("❌ Invalid game data file")
            return false
        }
        
        // Copy to save location
        try? data.write(to: saveFileURL)
        
        // Load the imported data
        return await loadGame()
    }
    
    // MARK: - Reset
    
    func resetGameData() {
        try? FileManager.default.removeItem(at: saveFileURL)
        if let cloudURL = cloudURL {
            try? FileManager.default.removeItem(at: cloudURL)
        }
        lastSaveTime = nil
        print("🗑️ Game data reset")
    }
}
