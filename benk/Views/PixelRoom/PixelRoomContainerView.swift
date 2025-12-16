//
//  PixelRoomContainerView.swift
//  benk
//
//  Container view that embeds Pixel Room (Project 2) into the main app
//  with a floating vertical side tab switcher matching the iOS 26 Liquid Glass design
//

import SwiftUI

/// Enum representing the pages available in the Pixel Room feature (no home page)
enum PixelRoomPage: String, CaseIterable, Identifiable {
    case room = "Room"
    case shop = "Shop"
    case inventory = "Inventory"
    case quests = "Quests"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .room: return "bed.double.fill"
        case .shop: return "cart.fill"
        case .inventory: return "shippingbox.fill"
        case .quests: return "scroll.fill"
        }
    }
}

/// Main container view that hosts Project 2 (Pixel Room) functionality
struct PixelRoomContainerView: View {
    // MARK: - Environment
    @EnvironmentObject var parentTheme: ThemeService
    
    // MARK: - Project 2 Managers
    @StateObject private var currencyManager = CurrencyManager.shared
    @StateObject private var inventoryManager = InventoryManager.shared
    @StateObject private var themeManager = ThemeManager()
    @ObservedObject private var roomManager = RoomManager.shared
    
    // MARK: - Local State
    @State private var selectedPage: PixelRoomPage = .room
    @State private var isTabBarVisible = true
    @Namespace private var animation
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // Themed background with effects (snow, stars, etc.)
            ThemedBackground(theme: parentTheme.currentTheme)
            
            // Main Content Area (full width)
            contentView
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .simultaneousGesture(
                    DragGesture(minimumDistance: 5)
                        .onChanged { _ in
                            if isTabBarVisible {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    isTabBarVisible = false
                                }
                            }
                        }
                )
                .simultaneousGesture(
                    TapGesture()
                        .onEnded {
                            if isTabBarVisible {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    isTabBarVisible = false
                                }
                            }
                        }
                )
            
            // Floating elements overlay (hide for Quests page which has its own header)
            if selectedPage != .quests {
                VStack {
                    // Top bar with glass styling
                    topBar
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                    
                    Spacer()
                }
            }
            
            // Floating Vertical Side Tab Bar (left side) with hide/show
            VStack {
                Spacer() // Push to bottom
                
                HStack(alignment: .bottom) {
                    if isTabBarVisible {
                        floatingVerticalTabBar
                            .transition(.asymmetric(
                                insertion: .move(edge: .leading).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                    }
                    
                    // Hide/Show toggle button (always visible)
                    hideShowButton
                        .padding(.leading, isTabBarVisible ? 4 : 12)
                    
                    Spacer()
                }
                .padding(.leading, 12) // Gap from left edge
                .padding(.bottom, 80) // 116 (absolute) - 34 (safe area) = 80. Gap (24) + Bar (66) + Pad (24) = 114.
            }
        }
        .environmentObject(currencyManager)
        .environmentObject(inventoryManager)
        .environmentObject(roomManager)
        .environmentObject(themeManager)
        // parentTheme (ThemeService) is already inherited from parent RoomView
        .onAppear {
            roomManager.setInventoryManager(inventoryManager)
            _Concurrency.Task {
                await SaveManager.shared.loadGame()
            }
        }
    }
    
    // MARK: - Hide/Show Button
    private var hideShowButton: some View {
        Button(action: {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                isTabBarVisible.toggle()
            }
            HapticManager.shared.selection()
        }) {
            Image(systemName: isTabBarVisible ? "chevron.left" : "line.3.horizontal")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(parentTheme.currentTheme.textSecondary)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Circle()
                                .stroke(
                                    parentTheme.currentTheme.accent.opacity(0.2),
                                    lineWidth: 0.5
                                )
                        )
                )
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .contentShape(Circle())
    }
    
    // MARK: - Floating Vertical Tab Bar (Compact, Icons Only)
    private var floatingVerticalTabBar: some View {
        VStack(spacing: 6) {
            ForEach(PixelRoomPage.allCases) { page in
                compactTabButton(for: page)
            }
        }
        .padding(8)
        .background(liquidGlassTabBarBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: parentTheme.currentTheme.glow.opacity(0.15), radius: 12, x: 3, y: 0)
    }
    
    private var liquidGlassTabBarBackground: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(parentTheme.currentTheme.surface.opacity(0.2))
                )
            
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            parentTheme.currentTheme.glow.opacity(0.12),
                            parentTheme.currentTheme.accent.opacity(0.15)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 1
                )
        }
    }
    
    private func compactTabButton(for page: PixelRoomPage) -> some View {
        Button(action: {
            SoundManager.shared.tabSwitch()
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                selectedPage = page
            }
            HapticManager.shared.selection()
        }) {
            ZStack {
                // Selected pill background
                if selectedPage == page {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    parentTheme.currentTheme.accent.opacity(0.25),
                                    parentTheme.currentTheme.accent.opacity(0.12)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            Circle()
                                .strokeBorder(
                                    parentTheme.currentTheme.accent.opacity(0.5),
                                    lineWidth: 1
                                )
                        )
                        .shadow(color: parentTheme.currentTheme.accent.opacity(0.25), radius: 6, x: 0, y: 2)
                        .matchedGeometryEffect(id: "selectedPill", in: animation)
                }
                
                // Icon
                Image(systemName: page.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(
                        selectedPage == page ?
                        LinearGradient(
                            colors: [parentTheme.currentTheme.accent, parentTheme.currentTheme.glow],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            colors: [
                                parentTheme.currentTheme.primary.opacity(0.5),
                                parentTheme.currentTheme.primary.opacity(0.4)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(selectedPage == page ? 1.05 : 0.95)
            }
            .frame(width: 36, height: 36)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Content View
    @ViewBuilder
    private var contentView: some View {
        switch selectedPage {
        case .room:
            PixelRoomInteriorView()
        case .shop:
            PixelRoomShopView()
        case .inventory:
            PixelRoomInventoryView()
        case .quests:
            QuestsView()
        }
    }
    
    // MARK: - Top Bar (Glass styled)
    private var topBar: some View {
        HStack {
            Spacer()
            
            // Coins display
            coinsDisplay
        }
    }
    
    private var coinsDisplay: some View {
        HStack(spacing: 8) {
            Image(systemName: "dollarsign.circle.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.yellow, .orange],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text("\(currencyManager.coins)")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(parentTheme.currentTheme.text)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay(
                    Capsule()
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.3), .white.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.5
                        )
                )
        )
        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
    }
}

#Preview("PixelRoomContainerView") {
    PixelRoomContainerView()
        .environmentObject(ThemeService.shared)
}
