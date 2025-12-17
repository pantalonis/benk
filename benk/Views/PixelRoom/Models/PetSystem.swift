//
//  PetSystem.swift
//  Pixel Room Customizer
//
//  Pet interactions, animations, moods, and behaviors
//

import SwiftUI
import Combine

// MARK: - Pet Mood

enum PetMood: String, Codable, CaseIterable {
    case happy = "Happy"
    case sleepy = "Sleepy"
    case playful = "Playful"
    case hungry = "Hungry"
    case excited = "Excited"
    
    var emoji: String {
        switch self {
        case .happy: return "😊"
        case .sleepy: return "😴"
        case .playful: return "😸"
        case .hungry: return "🍖"
        case .excited: return "🤩"
        }
    }
    
    var color: Color {
        switch self {
        case .happy: return .green
        case .sleepy: return .blue
        case .playful: return .orange
        case .hungry: return .red
        case .excited: return .yellow
        }
    }
    
    var description: String {
        switch self {
        case .happy: return "Feeling great!"
        case .sleepy: return "Needs rest..."
        case .playful: return "Wants to play!"
        case .hungry: return "Needs food!"
        case .excited: return "Super energetic!"
        }
    }
}

// MARK: - Pet Animation

enum PetAnimation: String, CaseIterable {
    case idle = "Idle"
    case walk = "Walk"
    case jump = "Jump"
    case spin = "Spin"
    case heart = "Heart"
    case sleep = "Sleep"
    case eat = "Eat"
    case play = "Play"
}

// MARK: - Pet State

struct PetState: Identifiable, Codable {
    let id: String // Same as placed item ID
    let petItemId: String
    var mood: PetMood
    var hunger: Int // 0-100
    var energy: Int // 0-100
    var happiness: Int // 0-100
    var lastFed: Date
    var lastPlayed: Date
    var position: CGPoint // Current position in room
    var targetPosition: CGPoint? // Where pet is walking to
    var currentAnimation: String // PetAnimation rawValue
    
    var needsFood: Bool {
        hunger < 30
    }
    
    var needsPlay: Bool {
        happiness < 50
    }
    
    var needsSleep: Bool {
        energy < 30
    }
}

// MARK: - Pet Manager

class PetManager: ObservableObject {
    static let shared = PetManager()
    
    @Published var petStates: [String: PetState] = [:] // itemId -> state
    @Published var showPetInteraction: Bool = false
    @Published var selectedPet: PetState?
    
    private var updateTimer: Timer?
    private var movementTimer: Timer?
    
    private init() {
        loadPetStates()
        startTimers()
    }
    
    // MARK: - Pet Creation
    
    func createPet(itemId: String, petItemId: String, position: CGPoint) {
        let petState = PetState(
            id: itemId,
            petItemId: petItemId,
            mood: .happy,
            hunger: 80,
            energy: 80,
            happiness: 80,
            lastFed: Date(),
            lastPlayed: Date(),
            position: position,
            targetPosition: nil,
            currentAnimation: PetAnimation.idle.rawValue
        )
        
        petStates[itemId] = petState
        savePetStates()
    }
    
    func removePet(itemId: String) {
        petStates.removeValue(forKey: itemId)
        savePetStates()
    }
    
    // MARK: - Pet Interactions
    
    func tapPet(_ petId: String) {
        guard var pet = petStates[petId] else { return }
        
        // Random cute animation
        let animations: [PetAnimation] = [.jump, .spin, .heart, .play]
        let randomAnimation = animations.randomElement() ?? .jump
        
        pet.currentAnimation = randomAnimation.rawValue
        pet.happiness = min(100, pet.happiness + 5)
        
        petStates[petId] = pet
        selectedPet = pet
        showPetInteraction = true
        
        // Play sound
        playPetSound()
        
        // Reset to idle after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.resetPetAnimation(petId)
        }
        
        savePetStates()
    }
    
    func feedPet(_ petId: String) {
        guard var pet = petStates[petId] else { return }
        
        pet.hunger = min(100, pet.hunger + 40)
        pet.happiness = min(100, pet.happiness + 10)
        pet.lastFed = Date()
        pet.currentAnimation = PetAnimation.eat.rawValue
        pet.mood = .happy
        
        petStates[petId] = pet
        
        // Award coins for feeding
        CurrencyManager.shared.addCoins(10, source: "Fed Pet")
        
        // Reset animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.resetPetAnimation(petId)
        }
        
        playPetSound()
        savePetStates()
    }
    
    func playWithPet(_ petId: String) {
        guard var pet = petStates[petId] else { return }
        
        pet.happiness = min(100, pet.happiness + 30)
        pet.energy = max(0, pet.energy - 10)
        pet.lastPlayed = Date()
        pet.currentAnimation = PetAnimation.play.rawValue
        pet.mood = .playful
        
        petStates[petId] = pet
        
        // Award coins for playing
        CurrencyManager.shared.addCoins(15, source: "Played with Pet")
        
        // Reset animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.resetPetAnimation(petId)
        }
        
        playPetSound()
        savePetStates()
    }
    
    private func resetPetAnimation(_ petId: String) {
        guard var pet = petStates[petId] else { return }
        pet.currentAnimation = PetAnimation.idle.rawValue
        petStates[petId] = pet
    }
    
    // MARK: - Pet Movement
    
    func startRandomWalking(for petId: String, in roomBounds: CGRect) {
        guard var pet = petStates[petId] else { return }
        
        // Random target position within room
        let randomX = CGFloat.random(in: roomBounds.minX...roomBounds.maxX)
        let randomY = CGFloat.random(in: roomBounds.minY...roomBounds.maxY)
        
        pet.targetPosition = CGPoint(x: randomX, y: randomY)
        pet.currentAnimation = PetAnimation.walk.rawValue
        
        petStates[petId] = pet
    }
    
    func updatePetPosition(_ petId: String, to position: CGPoint) {
        guard var pet = petStates[petId] else { return }
        pet.position = position
        
        // Check if reached target
        if let target = pet.targetPosition {
            let distance = hypot(position.x - target.x, position.y - target.y)
            if distance < 5 {
                pet.targetPosition = nil
                pet.currentAnimation = PetAnimation.idle.rawValue
            }
        }
        
        petStates[petId] = pet
    }
    
    // MARK: - Pet Stats Update
    
    private func startTimers() {
        // Update pet stats every minute
        updateTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.updateAllPetStats()
        }
        
        // Random movement every 5-10 seconds
        movementTimer = Timer.scheduledTimer(withTimeInterval: 7, repeats: true) { [weak self] _ in
            self?.triggerRandomMovement()
        }
    }
    
    private func updateAllPetStats() {
        for (id, var pet) in petStates {
            // Decrease stats over time
            pet.hunger = max(0, pet.hunger - 1)
            pet.energy = max(0, pet.energy - 1)
            pet.happiness = max(0, pet.happiness - 1)
            
            // Update mood based on stats
            pet.mood = determineMood(for: pet)
            
            // Auto-sleep if very tired
            if pet.energy < 20 {
                pet.currentAnimation = PetAnimation.sleep.rawValue
                pet.energy = min(100, pet.energy + 2) // Slowly recover
            }
            
            petStates[id] = pet
        }
        
        savePetStates()
    }
    
    private func determineMood(for pet: PetState) -> PetMood {
        if pet.hunger < 30 {
            return .hungry
        } else if pet.energy < 30 {
            return .sleepy
        } else if pet.happiness > 80 {
            return .excited
        } else if pet.happiness > 60 {
            return .playful
        } else {
            return .happy
        }
    }
    
    private func triggerRandomMovement() {
        // Only move pets that are idle
        for (id, pet) in petStates where pet.currentAnimation == PetAnimation.idle.rawValue {
            // 30% chance to start walking
            if Bool.random() && Double.random(in: 0...1) < 0.3 {
                let roomBounds = CGRect(x: 50, y: 100, width: 300, height: 400)
                startRandomWalking(for: id, in: roomBounds)
            }
        }
    }
    
    // MARK: - Sound
    
    private func playPetSound() {
        // Play cute pet sound
        HapticManager.shared.notification(.success)
        // TODO: Add actual sound playback using AVFoundation
    }
    
    // MARK: - Persistence
    
    private func savePetStates() {
        if let data = try? JSONEncoder().encode(petStates) {
            UserDefaults.standard.set(data, forKey: "petStates")
        }
    }
    
    private func loadPetStates() {
        if let data = UserDefaults.standard.data(forKey: "petStates"),
           let states = try? JSONDecoder().decode([String: PetState].self, from: data) {
            petStates = states
        }
    }
}
