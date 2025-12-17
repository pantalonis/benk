//
//  CurrencyManager.swift
//  benk
//
//  THE SINGLE SOURCE OF TRUTH FOR COINS IN THE ENTIRE APP.
//  Use CurrencyManager.shared.coins everywhere.
//

import Foundation
import Combine

/// Transaction record for coin history
struct CoinTransaction: Codable, Identifiable {
    let id: UUID
    let amount: Int
    let isCredit: Bool // true = earned, false = spent
    let source: String
    let timestamp: Date
    
    init(amount: Int, isCredit: Bool, source: String) {
        self.id = UUID()
        self.amount = amount
        self.isCredit = isCredit
        self.source = source
        self.timestamp = Date()
    }
}

/// THE ONLY coin variable in the app. Use this everywhere.
class CurrencyManager: ObservableObject {
    static let shared = CurrencyManager()
    
    private let coinsKey = "app_coins"
    private let transactionsKey = "app_coin_transactions"
    
    /// THE universal coin balance - persisted to UserDefaults
    @Published var coins: Int {
        didSet {
            UserDefaults.standard.set(coins, forKey: coinsKey)
        }
    }
    
    /// Transaction history
    @Published var transactions: [CoinTransaction] = []
    
    private init() {
        // Load from UserDefaults, default to 0 for new users
        self.coins = UserDefaults.standard.integer(forKey: coinsKey)
        loadTransactions()
    }
    
    // MARK: - Transaction Persistence
    
    private func loadTransactions() {
        if let data = UserDefaults.standard.data(forKey: transactionsKey),
           let decoded = try? JSONDecoder().decode([CoinTransaction].self, from: data) {
            // Keep last 100 transactions
            transactions = Array(decoded.suffix(100))
        }
    }
    
    private func saveTransactions() {
        // Keep only last 100 transactions
        let toSave = Array(transactions.suffix(100))
        if let data = try? JSONEncoder().encode(toSave) {
            UserDefaults.standard.set(data, forKey: transactionsKey)
        }
    }
    
    private func logTransaction(amount: Int, isCredit: Bool, source: String) {
        let transaction = CoinTransaction(amount: amount, isCredit: isCredit, source: source)
        transactions.append(transaction)
        saveTransactions()
    }
    
    // MARK: - Public Methods
    
    func canAfford(_ price: Int) -> Bool {
        return coins >= price
    }
    
    func spend(_ amount: Int, source: String = "Purchase") -> Bool {
        guard canAfford(amount) else { return false }
        coins -= amount
        logTransaction(amount: amount, isCredit: false, source: source)
        return true
    }
    
    func addCoins(_ amount: Int, source: String = "Reward") {
        coins += amount
        logTransaction(amount: amount, isCredit: true, source: source)
    }
    
    // MARK: - Legacy Support (backwards compatible)
    
    func spend(_ amount: Int) -> Bool {
        return spend(amount, source: "Purchase")
    }
    
    func clearTransactions() {
        transactions = []
        saveTransactions()
    }
}
