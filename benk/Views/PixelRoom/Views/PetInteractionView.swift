//
//  PetInteractionView.swift
//  Pixel Room Customizer
//
//  UI for pet interactions, feeding, and playing
//

import SwiftUI

// MARK: - Pet Interaction Sheet

struct PetInteractionSheet: View {
    let pet: PetState
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var petManager = PetManager.shared
    @Environment(\.dismiss) var dismiss
    
    @State private var showFeedSuccess = false
    @State private var showPlaySuccess = false
    
    var petItem: Item? {
        ItemCatalog.allShopItems.first { $0.id == pet.petItemId }
    }
    
    var body: some View {
        ZStack {
            themeManager.backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                header
                
                // Pet preview
                petPreview
                
                // Stats
                petStats
                
                // Actions
                actionButtons
                
                Spacer()
            }
            .padding()
        }
    }
    
    // MARK: - Header
    
    private var header: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(themeManager.secondaryText)
            }
            
            Spacer()
            
            VStack(spacing: 4) {
                Text(petItem?.name ?? "Pet")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(themeManager.primaryText)
                
                HStack(spacing: 4) {
                    Text(pet.mood.emoji)
                    Text(pet.mood.rawValue)
                        .font(.system(size: 14))
                        .foregroundColor(pet.mood.color)
                }
            }
            
            Spacer()
            
            Color.clear.frame(width: 28)
        }
    }
    
    // MARK: - Pet Preview
    
    private var petPreview: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.1))
                .frame(height: 200)
            
            // Pet image with animation
            if let petItem = petItem {
                Image(petItem.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
                    .rotationEffect(.degrees(pet.currentAnimation == "Spin" ? 360 : 0))
                    .offset(y: pet.currentAnimation == "Jump" ? -20 : 0)
                    .animation(.spring(response: 0.5), value: pet.currentAnimation)
                
                // Heart animation
                if pet.currentAnimation == "Heart" {
                    Text("❤️")
                        .font(.system(size: 40))
                        .offset(y: -80)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            
            // Mood indicator
            VStack {
                Spacer()
                Text(pet.mood.description)
                    .font(.system(size: 12))
                    .foregroundColor(themeManager.secondaryText)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(pet.mood.color.opacity(0.3)))
            }
            .padding()
        }
    }
    
    // MARK: - Pet Stats
    
    private var petStats: some View {
        VStack(spacing: 16) {
            statBar(label: "Hunger", value: pet.hunger, color: .red, icon: "🍖")
            statBar(label: "Energy", value: pet.energy, color: .blue, icon: "⚡")
            statBar(label: "Happiness", value: pet.happiness, color: .yellow, icon: "😊")
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
        )
    }
    
    private func statBar(label: String, value: Int, color: Color, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(icon)
                Text(label)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(themeManager.primaryText)
                Spacer()
                Text("\(value)%")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(color)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.1))
                    
                    // Fill
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [color.opacity(0.8), color],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * CGFloat(value) / 100)
                }
            }
            .frame(height: 12)
        }
    }
    
    // MARK: - Action Buttons
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            // Pat button (free interaction)
            Button {
                petManager.tapPet(pet.id)
                HapticManager.shared.impact(.medium)
            } label: {
                HStack {
                    Text("👋")
                        .font(.system(size: 24))
                    Text("Pat Pet")
                        .font(.system(size: 16, weight: .bold))
                    Spacer()
                    Text("Free!")
                        .font(.system(size: 14))
                        .foregroundColor(.green)
                }
                .foregroundColor(themeManager.primaryText)
                .padding()
                .background(
                    LinearGradient(
                        colors: [themeManager.accentCyan, themeManager.accentPurple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
        }
    }
}

// MARK: - Animated Pet View (for RoomView)

struct AnimatedPetView: View {
    let pet: PetState
    let item: Item
    @StateObject private var petManager = PetManager.shared
    
    @State private var offset: CGSize = .zero
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Pet image
            Image(item.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .rotationEffect(.degrees(pet.currentAnimation == "Spin" ? 360 : 0))
                .offset(y: pet.currentAnimation == "Jump" ? -20 : 0)
                .offset(offset)
                .animation(.spring(response: 0.5), value: pet.currentAnimation)
                .animation(.linear(duration: 2), value: offset)
            
            // Mood emoji
            VStack {
                Text(pet.mood.emoji)
                    .font(.system(size: 16))
                    .offset(y: -35)
                Spacer()
            }
            
            // Heart effect
            if pet.currentAnimation == "Heart" {
                Text("❤️")
                    .font(.system(size: 30))
                    .offset(y: -50)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .onTapGesture {
            petManager.tapPet(pet.id)
        }
        .onAppear {
            startWalking()
        }
    }
    
    private func startWalking() {
        // Simulate walking to target position
        if let target = pet.targetPosition {
            let dx = target.x - pet.position.x
            let dy = target.y - pet.position.y
            
            withAnimation(.linear(duration: 2)) {
                offset = CGSize(width: dx, height: dy)
            }
            
            // Update position after animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                petManager.updatePetPosition(pet.id, to: target)
                offset = .zero
            }
        }
    }
}

#Preview {
    PetInteractionSheet(
        pet: PetState(
            id: "test",
            petItemId: "cat_1",
            mood: .happy,
            hunger: 60,
            energy: 70,
            happiness: 80,
            lastFed: Date(),
            lastPlayed: Date(),
            position: .zero,
            targetPosition: nil,
            currentAnimation: "Idle"
        )
    )
    .environmentObject(ThemeManager())
}
