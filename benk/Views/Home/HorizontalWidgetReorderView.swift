import SwiftUI

// MARK: - Preference Key for Frame Tracking

struct WidgetFrameKey: PreferenceKey {
    static var defaultValue: [Int: CGRect] = [:]
    static func reduce(value: inout [Int: CGRect], nextValue: () -> [Int: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

// MARK: - Frame Store (Performance)
// Helps avoid "View Body Re-evaluation Loop" during Scroll
class FrameStore: ObservableObject {
    // NOT @Published. We do NOT want updates to trigger a view redraw.
    var frames: [Int: CGRect] = [:]
}

// MARK: - Reorderable Widget Stack

/// A horizontal widget stack with:
/// - Paging behavior (swipe to change widgets)
/// - iOS-style drag-to-reorder (long press in edit mode)
/// - Uses Overlay + Placeholder approach for smooth "detached" dragging
/// - Edge auto-scrolling
/// - Wiggle animation in edit mode
/// - Robust Multitouch support
struct HorizontalWidgetReorderView<Content: View>: View {
    
    // MARK: - Properties
    
    @Binding var widgetOrder: [Int]
    let widgetCount: Int
    let widgetContent: (Int) -> Content
    var onOrderChanged: (() -> Void)?
    @Binding var visibleWidgetIndex: Int
    
    // MARK: - State
    
    @State private var isEditing = false
    @State private var isWiggling = false // Wiggle state
    
    /// The index of the item currently being dragged (original index)
    @State private var draggingItem: Int?
    
    /// The index of the item currently being long-pressed (visual selection only)
    @State private var holdingItem: Int?
    
    /// The current window-space location of the drag gesture
    @State private var dragLocation: CGPoint = .zero
    
    /// Collected frames for all widgets in GLOBAL (screen) coordinate space
    // Performance: Use StateObject with non-published frames to avoid render loop
    @StateObject private var frameStore = FrameStore()
    
    /// Timer for auto-scrolling when dragging near edges
    @State private var autoScrollTimer: Timer?
    
    /// Throttling reorders to prevent jitter
    @State private var lastReorderTime = Date.distantPast
    
    // MARK: - Theme
    @EnvironmentObject var themeService: ThemeService
    
    // MARK: - Constants
    private let edgeScrollThreshold: CGFloat = 100.0
    
    // MARK: - Init
    
    init(
        widgetOrder: Binding<[Int]>,
        widgetCount: Int,
        visibleWidgetIndex: Binding<Int>,
        onOrderChanged: (() -> Void)? = nil,
        @ViewBuilder widgetContent: @escaping (Int) -> Content
    ) {
        self._widgetOrder = widgetOrder
        self.widgetCount = widgetCount
        self._visibleWidgetIndex = visibleWidgetIndex
        self.onOrderChanged = onOrderChanged
        self.widgetContent = widgetContent
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            // Checkmark button to exit edit mode
            if isEditing {
                exitEditModeButton
            }
            
            // Widget scroll area
            ZStack(alignment: .topLeading) {
                // 1. Main List Layer
                widgetScrollView
                    .opacity(draggingItem != nil ? 1 : 1) // Keep visible
                
                // 2. Dragged Overlay Layer
                if let draggingItem = draggingItem {
                    // Render the dragged item freely on top
                    widgetContent(draggingItem)
                        .frame(height: 180)
                        .frame(width: UIScreen.main.bounds.width - 32)
                        // Visual Tweak: No enlargement as requested
                        .scaleEffect(1.0)
                        .opacity(0.9)
                        .shadow(color: Color.black.opacity(0.2), radius: 15, x: 0, y: 10)
                        // User Request: Disable interaction on the dragged widget entirely
                        .allowsHitTesting(false)
                        .position(dragLocation)
                        .ignoresSafeArea()
                        .zIndex(100)
                        // Stop wiggle while dragging for cleaner look
                        .rotationEffect(.degrees(0)) 
                        .transition(.identity)
                }
            }
            .frame(height: 180)
            .coordinateSpace(name: "SCROLL_CONTAINER")
            
            // Page Indicator Dots
            pageIndicatorDots
                .padding(.top, 16)
                .padding(.bottom, 16)
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: isEditing)
        .onDisappear {
            stopAutoScroll()
            isWiggling = false
        }
        .onChange(of: isEditing) { _, newValue in
            if newValue {
                // Start wiggle
                withAnimation(.easeInOut(duration: 0.15).repeatForever(autoreverses: true)) {
                    isWiggling = true
                }
            } else {
                // Stop wiggle
                withAnimation(.default) {
                    isWiggling = false
                }
            }
        }
    }
    
    // MARK: - Exit Edit Mode Button
    
    private var exitEditModeButton: some View {
        HStack {
            Spacer()
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    isEditing = false
                    draggingItem = nil
                    holdingItem = nil
                    stopAutoScroll()
                }
                HapticManager.shared.selection()
            } label: {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.green)
            }
            .padding(.trailing, 20)
        }
        .padding(.bottom, 8)
        .transition(.opacity.combined(with: .move(edge: .top)))
    }
    
    // MARK: - Widget ScrollView with Paging
    
    private var widgetScrollView: some View {
        GeometryReader { geometry in
            ScrollViewReader { scrollProxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        ForEach(Array(widgetOrder.enumerated()), id: \.element) { params in
                            let (arrayIndex, widgetIndex) = params
                            
                            let isBeingDragged = (widgetIndex == draggingItem)
                            // "Holding" means selected/enlarged, but not yet lifted to overlay
                            let isBeingHeld = (widgetIndex == holdingItem)
                            
                            ZStack {
                                if isBeingDragged {
                                    Color.clear
                                        .frame(height: 180)
                                } else {
                                    widgetContent(widgetIndex)
                                        .frame(height: 180)
                                        // User Request: Disable interaction (buttons, taps) inside widget when in Edit Mode
                                        .allowsHitTesting(!isEditing)
                                }
                            }
                            // Ensure container captures gestures even if content is disabled
                            .contentShape(Rectangle()) 
                            .padding(.horizontal, 12)
                            .containerRelativeFrame(.horizontal)
                            .id(widgetIndex)
                            // Scale effect
                            // Scale: 1.0 if selected (held or dragged), 0.85 otherwise in edit mode
                            .scaleEffect(isEditing ? ((isBeingDragged || isBeingHeld) ? 1.0 : 0.85) : 1.0)
                            // ZIndex: Bring held item to top so it pops over neighbors
                            .zIndex(isBeingHeld ? 10 : 0)
                            // Wiggle Effect (Robust Modifier)
                            .modifier(WiggleModifier(isWiggling: isWiggling && isEditing && !isBeingDragged && !isBeingHeld)) 
                            
                            .opacity(isBeingDragged ? 0 : 1)
                            .background(
                                GeometryReader { geo in
                                    Color.clear
                                        .onAppear {
                                            let frame = geo.frame(in: .named("SCROLL_CONTAINER"))
                                            DispatchQueue.main.async {
                                                frameStore.frames[widgetIndex] = frame
                                            }
                                        }
                                        .customOnChange(of: geo.frame(in: .named("SCROLL_CONTAINER"))) { newFrame in
                                            frameStore.frames[widgetIndex] = newFrame
                                        }
                                }
                            )
                            // Gesture handling
                            // User Fix: Use highPriorityGesture to mask tap events (prevents opening link on long press)
                            .highPriorityGesture(longPressGesture(widgetIndex: widgetIndex, arrayIndex: arrayIndex))
                            // Multitouch Fix: Use conditional modifier logic
                            .modifier(DragGestureModifier(
                                isEditing: isEditing,
                                isDraggingItem: isBeingDragged,
                                anyDraggingActive: draggingItem != nil, // Check if *any* drag is active
                                gesture: dragGesture(widgetIndex: widgetIndex, arrayIndex: arrayIndex, geometry: geometry, scrollProxy: scrollProxy)
                            ))
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.paging)
                .onScrollGeometryChange(for: Int.self) { geo in
                    let pageWidth = geo.containerSize.width
                    guard pageWidth > 0 else { return 0 }
                    let page = Int(round(geo.contentOffset.x / pageWidth))
                    return max(0, min(widgetOrder.count - 1, page))
                } action: { oldValue, newValue in
                    if oldValue != newValue && !isEditing {
                        HapticManager.shared.selection()
                    }
                    visibleWidgetIndex = newValue
                }
            }
        }
    }
    
    // MARK: - Page Indicator Dots
    
    private var pageIndicatorDots: some View {
        HStack(spacing: 6) {
            ForEach(0..<widgetOrder.count, id: \.self) { index in
                Circle()
                    .fill(visibleWidgetIndex == index 
                          ? themeService.currentTheme.accent 
                          : themeService.currentTheme.textSecondary.opacity(0.3))
                    .frame(width: 6, height: 6)
                    .scaleEffect(visibleWidgetIndex == index ? 1.2 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: visibleWidgetIndex)
            }
        }
    }
    
    // MARK: - Gestures
    
    private func longPressGesture(widgetIndex: Int, arrayIndex: Int) -> some Gesture {
        LongPressGesture(minimumDuration: 0.4)
            .onEnded { _ in
                HapticManager.shared.medium()
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    isEditing = true
                }
            }
    }
    
    private func dragGesture(widgetIndex: Int, arrayIndex: Int, geometry: GeometryProxy, scrollProxy: ScrollViewProxy) -> some Gesture {
        // Responsiveness Fix: Fail fast on swipes > 30pt so list can scroll
        LongPressGesture(minimumDuration: 0.15, maximumDistance: 30)
            .sequenced(before: DragGesture(coordinateSpace: .named("SCROLL_CONTAINER")))
            .onChanged { value in
                switch value {
                case .second(true, let drag):
                    // 1. Holding State (Long Press Complete, Drag might be nil)
                    if holdingItem == nil {
                        holdingItem = widgetIndex
                        HapticManager.shared.light() // Feedback for "Selected"
                    }
                    
                    // 2. Dragging State (Movement Detected)
                    if let drag = drag {
                        // Lift to Overlay if not already
                        if draggingItem == nil {
                            draggingItem = widgetIndex
                            // Initialize drag location to smooth out the pickup
                            if let frame = frameStore.frames[widgetIndex] {
                                 let center = CGPoint(x: frame.midX, y: frame.midY)
                                 dragLocation = center
                            }
                        }
                        
                        // Move
                        withAnimation(.interactiveSpring) {
                            dragLocation = CGPoint(x: drag.location.x, y: 90)
                        }
                        
                        checkAutoScroll(dragX: drag.location.x, geometry: geometry, scrollProxy: scrollProxy)
                        checkForReorder(dragLocation: drag.location)
                    }
                    
                default:
                    break
                }
            }
            .onEnded { _ in
                draggingItem = nil
                holdingItem = nil
                stopAutoScroll()
                HapticManager.shared.light()
                onOrderChanged?()
                // Removed: "Flash Hack" (forcing isWiggling false->true) is no longer needed with WiggleModifier
            }
    }
    
    // MARK: - Auto Scroll Logic
    
    private func checkAutoScroll(dragX: CGFloat, geometry: GeometryProxy, scrollProxy: ScrollViewProxy) {
        let width = geometry.size.width
        
        if dragX > edgeScrollThreshold && dragX < (width - edgeScrollThreshold) {
            stopAutoScroll()
            return
        }
        
        guard autoScrollTimer == nil else { return }
        
        startAutoScroll(dragX: dragX, width: width, scrollProxy: scrollProxy)
    }
    
    private func startAutoScroll(dragX: CGFloat, width: CGFloat, scrollProxy: ScrollViewProxy) {
        // Wrapper to fix "Non-Sendable" capture error in Timer closure
        let proxyWrapper = UncheckedSendable(scrollProxy)
        
        // Smoother auto-scroll: 1.6s interval + Spring animation
        // Spring handles continuous movement better than easeInOut
        autoScrollTimer = Timer.scheduledTimer(withTimeInterval: 1.6, repeats: true) { _ in
            let proxy = proxyWrapper.value // Unwrap inside closure
            let isLeftEdge = dragX < edgeScrollThreshold
            let isRightEdge = dragX > (width - edgeScrollThreshold)
            
            guard isLeftEdge || isRightEdge else {
                stopAutoScroll()
                return
            }
            
            if isLeftEdge {
                if visibleWidgetIndex > 0 {
                    let prevIndex = visibleWidgetIndex - 1
                    // Spring animation for smoothness
                    withAnimation(.spring(response: 1.6, dampingFraction: 1.0)) {
                         if prevIndex >= 0 && prevIndex < widgetOrder.count {
                             let widgetId = widgetOrder[prevIndex]
                             proxy.scrollTo(widgetId, anchor: .center)
                         }
                    }
                }
            } else if isRightEdge {
                 if visibleWidgetIndex < widgetOrder.count - 1 {
                    let nextIndex = visibleWidgetIndex + 1
                    // Spring animation for smoothness
                    withAnimation(.spring(response: 1.6, dampingFraction: 1.0)) {
                         if nextIndex >= 0 && nextIndex < widgetOrder.count {
                             let widgetId = widgetOrder[nextIndex]
                             proxy.scrollTo(widgetId, anchor: .center)
                         }
                    }
                }
            }
        }
    }
    
    private func stopAutoScroll() {
        autoScrollTimer?.invalidate()
        autoScrollTimer = nil
    }
    
    // MARK: - Reorder Logic
    
    private func checkForReorder(dragLocation: CGPoint) {
        let dragX = dragLocation.x
        
        // Throttling: Prevent rapid-fire reordering (Jitter Fix)
        guard Date().timeIntervalSince(lastReorderTime) > 0.2 else { return }
        
        for (index, frame) in frameStore.frames {
             guard index != draggingItem else { continue }
            
            if dragX > frame.minX && dragX < frame.maxX {
                if let fromIndex = widgetOrder.firstIndex(of: draggingItem ?? -1),
                   let toIndex = widgetOrder.firstIndex(of: index) {
                    
                    if fromIndex != toIndex {
                         withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                             widgetOrder.move(fromOffsets: IndexSet(integer: fromIndex), 
                                            toOffset: toIndex > fromIndex ? toIndex + 1 : toIndex)
                         }
                          HapticManager.shared.selection()
                          lastReorderTime = Date() // Added: Update last reorder time
                     }
                }
                break 
            }
        }
    }

    // MARK: - Wiggle Animation
    
    private func startWiggleAnimation() {
        guard !isWiggling else { return }
        isWiggling = true
        withAnimation(.easeInOut(duration: 0.15).repeatForever(autoreverses: true)) {
            // This empty animation block is needed to trigger the animation on the rotationEffect
        }
    }
    
    private func stopWiggleAnimation() {
        isWiggling = false
    }
}

// MARK: - Robust Wiggle Modifier
/// Encapsulates wiggle logic to ensure animation persists independent of parent transactions.
/// Solves "Tilted Widget" issue during auto-scroll.
struct WiggleModifier: ViewModifier {
    let isWiggling: Bool
    @State private var isRotating = false
    
    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(isWiggling ? (isRotating ? -1.5 : 1.5) : 0))
            .animation(.easeInOut(duration: 0.15).repeatForever(autoreverses: true), value: isRotating)
            .customOnChange(of: isWiggling) { shouldWiggle in
                if shouldWiggle {
                    isRotating = true
                } else {
                    isRotating = false
                }
            }
            .onAppear {
                if isWiggling { isRotating = true }
            }
    }
}

// MARK: - Gesture Modifier Logic
/// Helper to conditionally apply the HighPriority gesture only when relevant
struct DragGestureModifier<G: Gesture>: ViewModifier {
    let isEditing: Bool
    let isDraggingItem: Bool
    let anyDraggingActive: Bool
    let gesture: G
    
    func body(content: Content) -> some View {
        if isEditing {
            // Logic:
            // 1. If NO item is being dragged: EVERY widget listens for the drag start.
            // 2. If ANY item IS being dragged:
            //    - The dragged item keeps listening (to update drag).
            //    - Other items STOP listening.
            //    This allows the second finger to fall through to the ScrollView.
            
            if !anyDraggingActive || isDraggingItem {
                // User Fix: Use simultaneousGesture for dragging to allow ScrollView to be responsive
                content.simultaneousGesture(gesture)
            } else {
                content // No gesture attached
            }
        } else {
            content
        }
    }
}

// MARK: - Helper for iOS 16 backport
extension View {
    @ViewBuilder
    func customOnChange<V: Equatable>(of value: V, perform action: @escaping (V) -> Void) -> some View {
        if #available(iOS 17.0, *) {
            self.onChange(of: value) { _, newValue in
                action(newValue)
            }
        } else {
            self.onChange(of: value, perform: action)
        }
    }
}

// MARK: - Concurrency Helpers
/// Helper to silence "Non-Sendable" warnings for UI objects captured in closures
struct UncheckedSendable<T>: @unchecked Sendable {
    let value: T
    init(_ value: T) { self.value = value }
}

// MARK: - Preview

#Preview {
    struct PreviewWrapper: View {
        @State private var order = [0, 1, 2, 3, 4]
        @State private var visibleIndex = 0
        
        var body: some View {
            HorizontalWidgetReorderView(
                widgetOrder: $order,
                widgetCount: 5,
                visibleWidgetIndex: $visibleIndex
            ) { index in
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.blue.opacity(0.2))
                    .overlay(
                        Text("Widget \(index)")
                            .font(.headline)
                    )
            }
            .environmentObject(ThemeService.shared)
        }
    }
    return PreviewWrapper()
}
