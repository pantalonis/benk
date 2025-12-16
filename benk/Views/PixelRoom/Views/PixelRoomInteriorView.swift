
//
//  PixelRoomInteriorView.swift
//  Pixel Room Customizer
//
//  Main room view with isometric perspective and furniture placement
//

import SwiftUI


struct PixelRoomInteriorView: View {
    @EnvironmentObject var roomManager: RoomManager
    @EnvironmentObject var inventoryManager: InventoryManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var parentTheme: ThemeService
    
    @State private var draggedObjectId: UUID?
    @State private var dragOffset: CGSize = .zero
    @State private var showCustomizePopup = false
    @State private var customizingObjectId: UUID?
    @State private var customizeScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // Themed background with effects (snow, stars, etc.)
            ThemedBackground(theme: parentTheme.currentTheme)
                .onTapGesture {
                    roomManager.selectedObjectId = nil
                }
            
            // Room container (fills available space)
            GeometryReader { geometry in
                ZStack {
                    // Catch-all background for deselection - fills the entire touchable area
                    Color.white.opacity(0.001)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            roomManager.selectedObjectId = nil
                        }
                    
                    // Room background (walls and floor)
                    roomBackground
                        .frame(width: geometry.size.width, height: geometry.size.height * 0.7)
                        // Position adjusted: was 0.4, now 0.5 to move down
                        .position(x: geometry.size.width / 2, y: geometry.size.height * 0.5)
                        .onTapGesture {
                            roomManager.selectedObjectId = nil
                        }
                    
                    // Window with background view
                    if let windowBg = roomManager.currentWindowBackground {
                        windowView(windowBg)
                            .frame(width: 120, height: 100)
                            .position(
                                x: geometry.size.width * roomManager.windowPosition.x,
                                y: geometry.size.height * roomManager.windowPosition.y
                            )
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        // Calculate new normalized position
                                        let newX = value.location.x / geometry.size.width
                                        let newY = value.location.y / geometry.size.height
                                        
                                        // Constrain to "wall" area (roughly top 60% of room view)
                                        let clampedX = max(0.2, min(0.8, newX))
                                        let clampedY = max(0.1, min(0.5, newY)) // Keep it on the upper wall section
                                        
                                        roomManager.updateWindowPosition(CGPoint(x: clampedX, y: clampedY))
                                    }
                            )
                            .onTapGesture {
                                roomManager.selectedObjectId = nil
                            }
                    }
                    
                    // Placed furniture objects
                    ForEach(roomManager.placedObjects.sorted(by: { $0.zIndex < $1.zIndex })) { placedObject in
                        if let item = roomManager.getItem(for: placedObject) {
                            furnitureView(item: item, placedObject: placedObject, in: geometry)
                        }
                    }
                }
                .coordinateSpace(name: "RoomSpace")
            }
            
            // Control panel floating at bottom (above main tab bar)
            VStack {
                Spacer()
                controlPanel
            }
            
            // Customize popup overlay
            if showCustomizePopup {
                customizePopupView
            }
        }
    }
    
    // MARK: - Room Background
    
    private var roomBackground: some View {
        ZStack {
            // Room background image
            Image(roomManager.currentRoomTheme?.imageName ?? "room1")
                .resizable()
                .scaledToFit()
                .contentShape(Rectangle())
        }
    }
    
    // MARK: - Window View
    
    private func windowView(_ background: WindowBackground) -> some View {
        ZStack {
            // Window background image - Transparent with no frame
            Image(background.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 180, height: 150)
        }
    }
    
    // MARK: - Furniture View
    
    private func furnitureView(item: Item, placedObject: PlacedObject, in geometry: GeometryProxy) -> some View {
        let position = gridToScreen(
            gridX: placedObject.gridX,
            gridY: placedObject.gridY,
            in: geometry
        )
        // Base tile width multiplied by both global scale and individual item scale
        let baseTileWidth: CGFloat = 90
        let tileWidth: CGFloat = baseTileWidth * roomManager.itemSizeScale * placedObject.sizeScale
        let itemWidth = CGFloat(item.gridWidth) * tileWidth
        
        // Check if this item should be animated
        let isPet = item.category == .pet
        let shouldAnimateFurniture = shouldAnimate(item: item)
        
        return Group {
            if isPet {
                // Use animated pet view for pets
                PetAnimationView(
                    imageName: item.imageName,
                    size: CGSize(width: itemWidth, height: itemWidth)
                )
                .scaleEffect(draggedObjectId == placedObject.id ? 1.1 : (roomManager.selectedObjectId == placedObject.id ? 1.05 : 1.0))
                .shadow(
                    color: draggedObjectId == placedObject.id ? .black.opacity(0.3) : (roomManager.selectedObjectId == placedObject.id ? .white.opacity(0.8) : .clear),
                    radius: roomManager.selectedObjectId == placedObject.id ? 5 : 10,
                    x: 0,
                    y: draggedObjectId == placedObject.id ? 10 : 0
                )
                .offset(draggedObjectId == placedObject.id ? dragOffset : .zero)
                .offset(y: -20)
                .contentShape(Rectangle())
                .gesture(dragGesture(for: placedObject, at: position, in: geometry))
                .position(position)
                .zIndex(Double(placedObject.zIndex) + (draggedObjectId == placedObject.id ? 1000 : 0))
            } else if shouldAnimateFurniture {
                // Use animated furniture view for lights, plants, electronics, etc.
                FurnitureAnimationView(
                    imageName: item.imageName,
                    itemName: item.name,
                    size: CGSize(width: itemWidth, height: itemWidth)
                )
                .scaleEffect(draggedObjectId == placedObject.id ? 1.1 : (roomManager.selectedObjectId == placedObject.id ? 1.05 : 1.0))
                .shadow(
                    color: draggedObjectId == placedObject.id ? .black.opacity(0.3) : (roomManager.selectedObjectId == placedObject.id ? .white.opacity(0.8) : .clear),
                    radius: roomManager.selectedObjectId == placedObject.id ? 5 : 10,
                    x: 0,
                    y: draggedObjectId == placedObject.id ? 10 : 0
                )
                .offset(draggedObjectId == placedObject.id ? dragOffset : .zero)
                .offset(y: -20)
                .contentShape(Rectangle())
                .gesture(dragGesture(for: placedObject, at: position, in: geometry))
                .position(position)
                .zIndex(Double(placedObject.zIndex) + (draggedObjectId == placedObject.id ? 1000 : 0))
            } else {
                // Regular static image for non-animated furniture
                Image(item.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: itemWidth)
                    .scaleEffect(draggedObjectId == placedObject.id ? 1.1 : (roomManager.selectedObjectId == placedObject.id ? 1.05 : 1.0))
                    .shadow(
                        color: draggedObjectId == placedObject.id ? .black.opacity(0.3) : (roomManager.selectedObjectId == placedObject.id ? .white.opacity(0.8) : .clear),
                        radius: roomManager.selectedObjectId == placedObject.id ? 5 : 10,
                        x: 0,
                        y: draggedObjectId == placedObject.id ? 10 : 0
                    )
                    .offset(draggedObjectId == placedObject.id ? dragOffset : .zero)
                    .offset(y: -20)
                    .contentShape(Rectangle())
                    .gesture(dragGesture(for: placedObject, at: position, in: geometry))
                    .position(position)
                    .zIndex(Double(placedObject.zIndex) + (draggedObjectId == placedObject.id ? 1000 : 0))
            }
        }
    }
    
    // MARK: - Animation Detection Helper
    
    private func shouldAnimate(item: Item) -> Bool {
        let animatedKeywords = [
            "lamp", "light", "lantern", "candle",  // Lights
            "plant", "fern", "cactus", "tree", "flower",  // Plants
            "tv", "computer", "pc", "screen", "monitor", "console", "game",  // Electronics
            "clock",  // Clocks
            "balloon", "orb", "floating", "fairy"  // Floating objects
        ]
        
        let itemNameLower = item.name.lowercased()
        return animatedKeywords.contains(where: { itemNameLower.contains($0) })
    }
    
    // MARK: - Drag Gesture Helper
    
    private func dragGesture(for placedObject: PlacedObject, at position: CGPoint, in geometry: GeometryProxy) -> some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .named("RoomSpace"))
            .onChanged { value in
                // Seamlessly switch selection to this item on touch/drag
                if roomManager.selectedObjectId != placedObject.id {
                    roomManager.selectedObjectId = placedObject.id
                }
                
                if draggedObjectId == nil {
                     draggedObjectId = placedObject.id
                }
                
                dragOffset = value.translation
            }
            .onEnded { value in
                if let id = draggedObjectId {
                    // Calculate final drop position in screen coordinates
                    let dropPoint = CGPoint(
                        x: position.x + value.translation.width,
                        y: position.y + value.translation.height
                    )
                    let gridPos = screenToGrid(point: dropPoint, in: geometry)
                    roomManager.moveObject(id: id, to: gridPos.x, gridY: gridPos.y)
                }
                draggedObjectId = nil
                dragOffset = .zero
            }
    }

    // MARK: - Control Panel (Liquid Glass iOS 26 Design)
    
    private var controlPanel: some View {
        Group {
            if let selectedId = roomManager.selectedObjectId,
               let placedObject = roomManager.placedObjects.first(where: { $0.id == selectedId }),
               let item = roomManager.getItem(for: placedObject) {
                
                HStack(spacing: 16) {
                    // Store button (remove from room, return to inventory)
                    glassControlButton(
                        icon: "archivebox.fill",
                        color: .orange
                    ) {
                        SoundManager.shared.buttonTap()
                        roomManager.removeObject(id: selectedId)
                        roomManager.selectedObjectId = nil
                        HapticManager.shared.selection()
                    }
                    
                    // Customize size button
                    glassControlButton(
                        icon: "slider.horizontal.3",
                        color: .purple
                    ) {
                        SoundManager.shared.buttonTap()
                        customizingObjectId = selectedId
                        customizeScale = placedObject.sizeScale
                        showCustomizePopup = true
                        HapticManager.shared.selection()
                    }
                    
                    // Done/deselect button
                    glassControlButton(
                        icon: "checkmark.circle.fill",
                        color: .blue
                    ) {
                        SoundManager.shared.buttonTap()
                        roomManager.selectedObjectId = nil
                        HapticManager.shared.selection()
                    }
                    
                    Spacer()
                    
                    // Item name
                    Text(item.name)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    Capsule()
                                        .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                                )
                        )
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
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
                .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 4)
                .padding(.horizontal, 16)
                .padding(.bottom, 100) // Position above main tab bar
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: selectedId)
            }
        }
    }
    
    private func glassControlButton(icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 48, height: 48)
                .background(
                    Circle()
                        .fill(color.opacity(0.3))
                        .overlay(
                            Circle()
                                .stroke(color.opacity(0.6), lineWidth: 1)
                        )
                )
                .shadow(color: color.opacity(0.3), radius: 6, x: 0, y: 3)
        }
    }
    
    // MARK: - Coordinate Conversion
    
    private func gridToScreen(gridX: Double, gridY: Double, in geometry: GeometryProxy) -> CGPoint {
        let centerX = geometry.size.width / 2
        // Adjusted center Y: was 0.55, now 0.65 to move down
        let centerY = geometry.size.height * 0.65
        
        // Updated for tile size (90 width / 45 height)
        let isoX = (CGFloat(gridX) - CGFloat(gridY)) * 45
        let isoY = (CGFloat(gridX) + CGFloat(gridY)) * 22.5
        
        return CGPoint(
            x: centerX + isoX,
            y: centerY + isoY
        )
    }
    
    private func screenToGrid(point: CGPoint, in geometry: GeometryProxy) -> (x: Double, y: Double) {
        let centerX = geometry.size.width / 2
        // Adjusted center Y: was 0.55, now 0.65 to move down
        let centerY = geometry.size.height * 0.65
        
        let relX = point.x - centerX
        let relY = point.y - centerY
        
        // Inverse isometric projection for tile size 90
        let gridX = (relX / 45 + relY / 22.5) / 2
        let gridY = (relY / 22.5 - relX / 45) / 2
        
        // Relaxed bounds for gesture dragging (effectively infinite for user experience)
        let clampedX = max(-100.0, min(gridX, roomManager.gridWidth + 100.0))
        let clampedY = max(-100.0, min(gridY, roomManager.gridHeight + 100.0))
        
        return (clampedX, clampedY)
    }
    
    // MARK: - Customize Popup (Liquid Glass iOS 26 Design)
    
    private var customizePopupView: some View {
        ZStack {
            // Blurred overlay
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    applyCustomization()
                }
            
            // Glass popup card
            VStack(spacing: 20) {
                // Header
                HStack {
                    Text("🎨 Customize Size")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        SoundManager.shared.buttonTap()
                        applyCustomization()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
                
                // Preview size indicator (glass card)
                VStack(spacing: 8) {
                    Text("\(Int(customizeScale * 100))%")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.cyan, .blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Text("Item Size")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.15), lineWidth: 0.5)
                        )
                )
                
                // Size slider section
                VStack(alignment: .leading, spacing: 14) {
                    Text("Adjust Size")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 12) {
                        Text("50%")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.white.opacity(0.5))
                        
                        Slider(value: $customizeScale, in: 0.5...2.0, step: 0.1)
                            .tint(.cyan)
                            .onChange(of: customizeScale) { oldValue, newValue in
                                HapticManager.shared.light()
                            }
                        
                        Text("200%")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    
                    // Quick size buttons (glass pills)
                    HStack(spacing: 10) {
                        ForEach([("Small", 0.75), ("Normal", 1.0), ("Large", 1.5), ("XL", 2.0)], id: \.0) { label, value in
                            glassQuickSizeButton(label: label, value: value)
                        }
                    }
                }
                
                // Done button (glass style)
                Button(action: {
                    SoundManager.shared.buttonTap()
                    applyCustomization()
                }) {
                    Text("Done")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(
                                    LinearGradient(
                                        colors: [.cyan.opacity(0.4), .blue.opacity(0.4)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(
                                            LinearGradient(
                                                colors: [.cyan.opacity(0.6), .blue.opacity(0.4)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1
                                        )
                                )
                        )
                        .shadow(color: .cyan.opacity(0.3), radius: 8, x: 0, y: 4)
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
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
            .padding(.horizontal, 32)
            .shadow(color: .black.opacity(0.25), radius: 24, x: 0, y: 12)
        }
    }
    
    private func glassQuickSizeButton(label: String, value: Double) -> some View {
        let isSelected = abs(customizeScale - value) < 0.15
        
        return Button(action: {
            SoundManager.shared.buttonTap()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                customizeScale = value
            }
            HapticManager.shared.selection()
        }) {
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(isSelected ? .white : .white.opacity(0.5))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(quickSizeButtonBackground(isSelected: isSelected))
        }
    }
    
    @ViewBuilder
    private func quickSizeButtonBackground(isSelected: Bool) -> some View {
        if isSelected {
            Capsule()
                .fill(.cyan.opacity(0.3))
                .overlay(
                    Capsule()
                        .stroke(.cyan.opacity(0.6), lineWidth: 0.5)
                )
        } else {
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                )
        }
    }
    
    private func applyCustomization() {
        if let objectId = customizingObjectId {
            roomManager.updateObjectSize(id: objectId, scale: customizeScale)
        }
        showCustomizePopup = false
        customizingObjectId = nil
    }
}

// MARK: - Isometric Room Shape

struct IsometricRoomShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width * 0.6
        let height = rect.height * 0.6
        let centerX = rect.midX
        let centerY = rect.midY
        
        // Draw isometric hexagon (floor + two walls)
        path.move(to: CGPoint(x: centerX, y: centerY - height / 2))
        path.addLine(to: CGPoint(x: centerX + width / 2, y: centerY - height / 4))
        path.addLine(to: CGPoint(x: centerX + width / 2, y: centerY + height / 4))
        path.addLine(to: CGPoint(x: centerX, y: centerY + height / 2))
        path.addLine(to: CGPoint(x: centerX - width / 2, y: centerY + height / 4))
        path.addLine(to: CGPoint(x: centerX - width / 2, y: centerY - height / 4))
        path.closeSubpath()
        
        return path
    }
}
