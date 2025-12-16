//
//  SoundManager.swift
//  Pixel Room Customizer
//
//  Manages sound effects and background music
//

import AVFoundation
import SwiftUI
import Combine

class SoundManager: ObservableObject {
    static let shared = SoundManager()
    
    @Published var isSoundEnabled: Bool = true {
        didSet {
            UserDefaults.standard.set(isSoundEnabled, forKey: "soundEnabled")
        }
    }
    
    @Published var isMusicEnabled: Bool = true {
        didSet {
            UserDefaults.standard.set(isMusicEnabled, forKey: "musicEnabled")
            if isMusicEnabled {
                playBackgroundMusic()
            } else {
                stopBackgroundMusic()
            }
        }
    }
    
    @Published var soundVolume: Float = 0.7 {
        didSet {
            UserDefaults.standard.set(soundVolume, forKey: "soundVolume")
        }
    }
    
    @Published var musicVolume: Float = 0.3 {
        didSet {
            UserDefaults.standard.set(musicVolume, forKey: "musicVolume")
            backgroundMusicPlayer?.volume = musicVolume
        }
    }
    
    private var soundPlayers: [String: AVAudioPlayer] = [:]
    private var backgroundMusicPlayer: AVAudioPlayer?
    
    private init() {
        // Load saved preferences
        isSoundEnabled = UserDefaults.standard.bool(forKey: "soundEnabled")
        isMusicEnabled = UserDefaults.standard.bool(forKey: "musicEnabled")
        soundVolume = UserDefaults.standard.float(forKey: "soundVolume")
        musicVolume = UserDefaults.standard.float(forKey: "musicVolume")
        
        // Set defaults if first launch
        if UserDefaults.standard.object(forKey: "soundEnabled") == nil {
            isSoundEnabled = true
            isMusicEnabled = true
            soundVolume = 0.7
            musicVolume = 0.3
        }
        
        setupAudioSession()
        preloadSounds()
    }
    
    // MARK: - Audio Session Setup
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    // MARK: - Preload Sounds
    
    private func preloadSounds() {
        let soundNames = [
            "coin_collect",
            "purchase_success",
            "purchase_fail",
            "item_place",
            "item_remove",
            "button_tap",
            "tab_switch",
            "achievement",
            "level_up",
            "pet_interact"
        ]
        
        for _ in soundNames {
            // We'll use system sounds for now, but you can replace with custom sounds
            // For now, we'll create placeholder players
        }
    }
    
    // MARK: - Play Sound Effects
    
    func playSound(_ soundName: String) {
        guard isSoundEnabled else { return }
        
        // Map sound names to system sounds or custom sounds
        switch soundName {
        case "coin_collect":
            playSystemSound(1104) // Tink
        case "purchase_success":
            playSystemSound(1103) // Tock - satisfying "ka-ching" sound
        case "purchase_fail":
            playSystemSound(1053) // Tink (lower)
        case "item_place":
            playSystemSound(1306) // Anticipate - satisfying "dun" sound
        case "item_remove":
            playSystemSound(1106) // Swoosh
        case "button_tap":
            playSystemSound(1104) // Tink
        case "tab_switch":
            playSystemSound(1105) // Pop
        case "achievement":
            playSystemSound(1025) // Fanfare
        case "level_up":
            playSystemSound(1025) // Fanfare
        case "pet_interact":
            playSystemSound(1109) // Purr
        default:
            playSystemSound(1104)
        }
    }
    
    private func playSystemSound(_ soundID: SystemSoundID) {
        AudioServicesPlaySystemSound(soundID)
    }
    
    // MARK: - Background Music
    
    func playBackgroundMusic() {
        guard isMusicEnabled else { return }
        
        // For now, we'll use a gentle system sound loop
        // In production, you'd load an actual music file
        
        // Create a timer to play ambient sounds
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            guard let self = self, self.isMusicEnabled else { return }
            // Play subtle ambient sound
            AudioServicesPlaySystemSound(1070) // Very subtle
        }
    }
    
    func stopBackgroundMusic() {
        backgroundMusicPlayer?.stop()
    }
    
    func pauseBackgroundMusic() {
        backgroundMusicPlayer?.pause()
    }
    
    func resumeBackgroundMusic() {
        guard isMusicEnabled else { return }
        backgroundMusicPlayer?.play()
    }
    
    // MARK: - Convenience Methods
    
    func coinCollect() {
        playSound("coin_collect")
        HapticManager.shared.light()
    }
    
    func purchaseSuccess() {
        playSound("purchase_success")
        HapticManager.shared.success()
    }
    
    func purchaseFail() {
        playSound("purchase_fail")
        HapticManager.shared.error()
    }
    
    func itemPlace() {
        playSound("item_place")
        HapticManager.shared.medium()
    }
    
    func itemRemove() {
        playSound("item_remove")
        HapticManager.shared.light()
    }
    
    func buttonTap() {
        playSound("button_tap")
        HapticManager.shared.light()
    }
    
    func tabSwitch() {
        playSound("tab_switch")
        HapticManager.shared.selection()
    }
    
    func achievement() {
        playSound("achievement")
        HapticManager.shared.success()
    }
    
    func petInteract() {
        playSound("pet_interact")
        HapticManager.shared.light()
    }
}

// MARK: - Sound Names Reference

/*
 Available Sounds:
 
 - coin_collect: When earning coins
 - purchase_success: When buying an item successfully
 - purchase_fail: When purchase fails (not enough coins)
 - item_place: When placing furniture in room
 - item_remove: When removing furniture from room
 - button_tap: General button press
 - tab_switch: When switching tabs
 - achievement: When unlocking achievement
 - level_up: When leveling up
 - pet_interact: When tapping a pet
 
 Usage:
 SoundManager.shared.coinCollect()
 SoundManager.shared.purchaseSuccess()
 SoundManager.shared.itemPlace()
 */
