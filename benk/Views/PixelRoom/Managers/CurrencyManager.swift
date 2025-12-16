//
//  CurrencyManager.swift
//  benk
//
//  THE SINGLE SOURCE OF TRUTH FOR COINS IN THE ENTIRE APP.
//  Use CurrencyManager.shared.coins everywhere.
//

import Foundation
import Combine

/// THE ONLY coin variable in the app. Use this everywhere.
class CurrencyManager: ObservableObject {
    static let shared = CurrencyManager()
    
    private let coinsKey = "app_coins"
    
    /// THE universal coin balance - persisted to UserDefaults
    @Published var coins: Int {
        didSet {
            UserDefaults.standard.set(coins, forKey: coinsKey)
        }
    }
    
    private init() {
        // Load from UserDefaults, default to 10000 for new users
        let saved = UserDefaults.standard.integer(forKey: coinsKey)
        self.coins = saved > 0 ? saved : 10000
    }
    
    // MARK: - Public Methods
    
    func canAfford(_ price: Int) -> Bool {
        return coins >= price
    }
    
    func spend(_ amount: Int) -> Bool {
        guard canAfford(amount) else { return false }
        coins -= amount
        return true
    }
    
    func addCoins(_ amount: Int) {
        coins += amount
    }
}

