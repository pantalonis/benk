//
//  CoinTransactionLogView.swift
//  benk
//
//  Transaction history log for coins - shows how coins were earned/spent
//

import SwiftUI

struct CoinTransactionLogView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeService: ThemeService
    @StateObject private var currencyManager = CurrencyManager.shared
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        ZStack {
            // Themed background
            ThemedBackground(theme: themeService.currentTheme)
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Content
                if currencyManager.transactions.isEmpty {
                    emptyState
                } else {
                    transactionList
                }
            }
        }
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(themeService.currentTheme.text)
                    .padding(12)
                    .background(
                        Circle()
                            .fill(.ultraThinMaterial)
                            .overlay(
                                Circle()
                                    .stroke(themeService.currentTheme.primary.opacity(0.3), lineWidth: 1)
                            )
                    )
            }
            
            Spacer()
            
            Text("Coin History")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(themeService.currentTheme.text)
            
            Spacer()
            
            // Balance display
            HStack(spacing: 4) {
                Image(systemName: "dollarsign.circle.fill")
                    .foregroundColor(.yellow)
                Text("\(currencyManager.coins)")
                    .fontWeight(.bold)
                    .foregroundColor(themeService.currentTheme.text)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)
                    .overlay(
                        Capsule()
                            .stroke(themeService.currentTheme.primary.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .padding()
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
        )
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(themeService.currentTheme.textSecondary.opacity(0.5))
            
            Text("No Transactions Yet")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(themeService.currentTheme.text)
            
            Text("Your coin earnings and spending\nwill appear here")
                .font(.subheadline)
                .foregroundColor(themeService.currentTheme.textSecondary)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
    }
    
    // MARK: - Transaction List
    
    private var transactionList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(currencyManager.transactions.reversed()) { transaction in
                    transactionRow(transaction)
                }
            }
            .padding()
        }
    }
    
    private func transactionRow(_ transaction: CoinTransaction) -> some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(transaction.isCredit ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Image(systemName: transaction.isCredit ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                    .font(.title2)
                    .foregroundColor(transaction.isCredit ? .green : .red)
            }
            
            // Details
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.source)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(themeService.currentTheme.text)
                
                Text(dateFormatter.string(from: transaction.timestamp))
                    .font(.caption)
                    .foregroundColor(themeService.currentTheme.textSecondary)
            }
            
            Spacer()
            
            // Amount
            Text("\(transaction.isCredit ? "+" : "-")\(transaction.amount)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(transaction.isCredit ? .green : .red)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    themeService.currentTheme.primary.opacity(0.2),
                                    themeService.currentTheme.accent.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: themeService.currentTheme.glow.opacity(0.1), radius: 6, x: 0, y: 3)
    }
}

#Preview {
    CoinTransactionLogView()
        .environmentObject(ThemeService.shared)
}
