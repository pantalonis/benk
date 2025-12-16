//
//  AmbienceManager.swift
//  Pixel Room Customizer
//
//  Manages time of day and seasonal themes with dynamic lighting
//

import SwiftUI
import Combine

class AmbienceManager: ObservableObject {
    static let shared = AmbienceManager()
    
    @Published var currentTimeOfDay: TimeOfDay = .afternoon
    @Published var currentSeason: Season = .spring
    @Published var isAutoTimeEnabled: Bool = true {
        didSet {
            UserDefaults.standard.set(isAutoTimeEnabled, forKey: "autoTimeEnabled")
            if isAutoTimeEnabled {
                updateTimeOfDay()
            }
        }
    }
    @Published var isAutoSeasonEnabled: Bool = true {
        didSet {
            UserDefaults.standard.set(isAutoSeasonEnabled, forKey: "autoSeasonEnabled")
            if isAutoSeasonEnabled {
                updateSeason()
            }
        }
    }
    
    private var timer: Timer?
    
    // MARK: - Time of Day
    
    enum TimeOfDay: String, CaseIterable, Codable {
        case morning = "Morning"
        case afternoon = "Afternoon"
        case evening = "Evening"
        case night = "Night"
        
        var icon: String {
            switch self {
            case .morning: return "sunrise.fill"
            case .afternoon: return "sun.max.fill"
            case .evening: return "sunset.fill"
            case .night: return "moon.stars.fill"
            }
        }
        
        var description: String {
            switch self {
            case .morning: return "Bright and fresh"
            case .afternoon: return "Warm and vibrant"
            case .evening: return "Soft and cozy"
            case .night: return "Dark and peaceful"
            }
        }
        
        // Color overlay for the room
        var overlayColor: Color {
            switch self {
            case .morning: return Color.orange.opacity(0.1)
            case .afternoon: return Color.clear
            case .evening: return Color.orange.opacity(0.15)
            case .night: return Color.blue.opacity(0.3)
            }
        }
        
        // Brightness adjustment
        var brightness: Double {
            switch self {
            case .morning: return 0.05
            case .afternoon: return 0.1
            case .evening: return -0.05
            case .night: return -0.2
            }
        }
        
        // Saturation adjustment
        var saturation: Double {
            switch self {
            case .morning: return 1.1
            case .afternoon: return 1.2
            case .evening: return 0.9
            case .night: return 0.7
            }
        }
    }
    
    // MARK: - Seasons
    
    enum Season: String, CaseIterable, Codable {
        case spring = "Spring"
        case summer = "Summer"
        case autumn = "Autumn"
        case winter = "Winter"
        
        var icon: String {
            switch self {
            case .spring: return "leaf.fill"
            case .summer: return "sun.max.fill"
            case .autumn: return "leaf.fill"
            case .winter: return "snowflake"
            }
        }
        
        var description: String {
            switch self {
            case .spring: return "Fresh and blooming"
            case .summer: return "Bright and warm"
            case .autumn: return "Cozy and warm"
            case .winter: return "Cool and serene"
            }
        }
        
        var colors: [Color] {
            switch self {
            case .spring: return [Color.green, Color.pink]
            case .summer: return [Color.yellow, Color.orange]
            case .autumn: return [Color.orange, Color.red]
            case .winter: return [Color.blue, Color.white]
            }
        }
        
        var accentColor: Color {
            switch self {
            case .spring: return Color.green
            case .summer: return Color.yellow
            case .autumn: return Color.orange
            case .winter: return Color.blue
            }
        }
        
        // Particle effect (optional)
        var particleEffect: ParticleEffect? {
            switch self {
            case .spring: return .petals
            case .summer: return nil
            case .autumn: return .leaves
            case .winter: return .snow
            }
        }
    }
    
    enum ParticleEffect {
        case petals
        case leaves
        case snow
    }
    
    private init() {
        // Load saved preferences
        isAutoTimeEnabled = UserDefaults.standard.object(forKey: "autoTimeEnabled") as? Bool ?? true
        isAutoSeasonEnabled = UserDefaults.standard.object(forKey: "autoSeasonEnabled") as? Bool ?? true
        
        // Initialize based on current date/time
        updateTimeOfDay()
        updateSeason()
        
        // Start timer for time updates
        startTimer()
    }
    
    // MARK: - Timer
    
    private func startTimer() {
        // Update every minute
        timer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in
            self?.updateTimeOfDay()
        }
    }
    
    // MARK: - Update Time of Day
    
    func updateTimeOfDay() {
        guard isAutoTimeEnabled else { return }
        
        let hour = Calendar.current.component(.hour, from: Date())
        
        let newTime: TimeOfDay
        switch hour {
        case 6..<12:
            newTime = .morning
        case 12..<17:
            newTime = .afternoon
        case 17..<20:
            newTime = .evening
        default:
            newTime = .night
        }
        
        if newTime != currentTimeOfDay {
            withAnimation(.easeInOut(duration: 2.0)) {
                currentTimeOfDay = newTime
            }
        }
    }
    
    // MARK: - Update Season
    
    func updateSeason() {
        guard isAutoSeasonEnabled else { return }
        
        let month = Calendar.current.component(.month, from: Date())
        
        let newSeason: Season
        switch month {
        case 3, 4, 5:
            newSeason = .spring
        case 6, 7, 8:
            newSeason = .summer
        case 9, 10, 11:
            newSeason = .autumn
        default:
            newSeason = .winter
        }
        
        if newSeason != currentSeason {
            withAnimation(.easeInOut(duration: 1.0)) {
                currentSeason = newSeason
            }
        }
    }
    
    // MARK: - Manual Override
    
    func setTimeOfDay(_ time: TimeOfDay) {
        isAutoTimeEnabled = false
        withAnimation(.easeInOut(duration: 1.0)) {
            currentTimeOfDay = time
        }
    }
    
    func setSeason(_ season: Season) {
        isAutoSeasonEnabled = false
        withAnimation(.easeInOut(duration: 1.0)) {
            currentSeason = season
        }
    }
    
    // MARK: - Combined Ambience
    
    var ambienceDescription: String {
        "\(currentSeason.rawValue) \(currentTimeOfDay.rawValue)"
    }
    
    var ambienceEmoji: String {
        switch (currentSeason, currentTimeOfDay) {
        case (.spring, .morning): return "🌸☀️"
        case (.spring, .afternoon): return "🌸🌞"
        case (.spring, .evening): return "🌸🌅"
        case (.spring, .night): return "🌸🌙"
        case (.summer, .morning): return "☀️🌊"
        case (.summer, .afternoon): return "🌞🏖️"
        case (.summer, .evening): return "🌅🌴"
        case (.summer, .night): return "🌙⭐"
        case (.autumn, .morning): return "🍂☀️"
        case (.autumn, .afternoon): return "🍂🍁"
        case (.autumn, .evening): return "🍂🌅"
        case (.autumn, .night): return "🍂🌙"
        case (.winter, .morning): return "❄️☀️"
        case (.winter, .afternoon): return "❄️☃️"
        case (.winter, .evening): return "❄️🌅"
        case (.winter, .night): return "❄️🌙"
        }
    }
}

// MARK: - View Modifier for Ambience

struct AmbienceModifier: ViewModifier {
    @ObservedObject var ambienceManager: AmbienceManager
    
    func body(content: Content) -> some View {
        content
            .overlay(
                ambienceManager.currentTimeOfDay.overlayColor
                    .allowsHitTesting(false)
                    .ignoresSafeArea()
            )
            .brightness(ambienceManager.currentTimeOfDay.brightness)
            .saturation(ambienceManager.currentTimeOfDay.saturation)
    }
}

extension View {
    func ambience(_ manager: AmbienceManager = .shared) -> some View {
        self.modifier(AmbienceModifier(ambienceManager: manager))
    }
}
