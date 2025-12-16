//
//  InteractiveEventBlock.swift
//  benk
//
//  Created on 2025-12-16
//
//  Interactive event block with drag-to-move and resize capabilities.
//
//  GESTURE BEHAVIOR:
//  - Scroll: Passes through to parent ScrollView
//  - Tap: Show event details (when not in edit mode)
//  - Long-press (0.3s): Enter edit mode (persists until tap outside)
//  - In edit mode: drag handles to resize, drag middle to move
//  - Movement snaps to 10-minute intervals on release (smooth during drag)
//

import SwiftUI

// MARK: - Interactive Event Block
struct InteractiveEventBlock: View {
    let title: String
    let subtitle: String?
    let color: Color
    let icon: String?
    let isDashed: Bool
    
    let layoutInfo: TimelineLayoutInfo
    let pixelsPerMinute: CGFloat
    let selectedDate: Date
    
    // Edit mode is controlled by parent
    @Binding var isEditing: Bool
    
    let onTimeChange: ((Date, Date) -> Void)?
    let onTap: (() -> Void)?
    
    // MARK: - State
    // Using @State for smooth visual updates during drag
    @State private var dragOffset: CGFloat = 0
    @State private var resizeTopOffset: CGFloat = 0
    @State private var resizeBottomOffset: CGFloat = 0
    @State private var activeGesture: ActiveGesture = .none
    
    enum ActiveGesture {
        case none
        case dragging
        case resizingTop
        case resizingBottom
    }
    
    @EnvironmentObject var themeService: ThemeService
    
    // MARK: - Constants
    private let handleHeight: CGFloat = 28
    private let minHeightForInternalHandles: CGFloat = 80
    private let longPressDuration: Double = 0.3
    private let snapIntervalMinutes: Int = 10
    
    // MARK: - Computed Properties
    
    private var handlesOutside: Bool {
        layoutInfo.height < minHeightForInternalHandles
    }
    
    private var currentY: CGFloat {
        switch activeGesture {
        case .dragging:
            return layoutInfo.y + dragOffset
        case .resizingTop:
            return layoutInfo.y + resizeTopOffset
        default:
            return layoutInfo.y
        }
    }
    
    private var currentHeight: CGFloat {
        switch activeGesture {
        case .resizingTop:
            return max(20, layoutInfo.height - resizeTopOffset)
        case .resizingBottom:
            return max(20, layoutInfo.height + resizeBottomOffset)
        default:
            return layoutInfo.height
        }
    }
    
    private var isActivelyGesturing: Bool {
        activeGesture != .none
    }
    
    // MARK: - Body
    var body: some View {
        blockWithHandles
            .frame(width: max(0, layoutInfo.width))
            .position(
                x: layoutInfo.x + layoutInfo.width / 2,
                y: currentY + currentHeight / 2
            )
            .zIndex(isEditing ? 100 : 0)
    }
    
    // MARK: - Block with Handles
    @ViewBuilder
    private var blockWithHandles: some View {
        VStack(spacing: 0) {
            if isEditing {
                topHandle
            }
            
            mainBlock
                .frame(height: max(0, currentHeight))
            
            if isEditing {
                bottomHandle
            }
        }
    }
    
    // MARK: - Top Handle
    private var topHandle: some View {
        ZStack {
            if handlesOutside {
                RoundedRectangle(cornerRadius: 8)
                    .fill(themeService.currentTheme.surface)
                    .shadow(color: .black.opacity(0.15), radius: 4, y: -2)
            }
            
            Capsule()
                .fill(color)
                .frame(width: 50, height: 6)
        }
        .frame(width: max(0, layoutInfo.width), height: handleHeight)
        .contentShape(Rectangle())
        .highPriorityGesture(
            DragGesture(minimumDistance: 1)
                .onChanged { value in
                    activeGesture = .resizingTop
                    resizeTopOffset = value.translation.height
                }
                .onEnded { value in
                    commitResize(isTop: true, offset: value.translation.height)
                }
        )
    }
    
    // MARK: - Bottom Handle
    private var bottomHandle: some View {
        ZStack {
            if handlesOutside {
                RoundedRectangle(cornerRadius: 8)
                    .fill(themeService.currentTheme.surface)
                    .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
            }
            
            Capsule()
                .fill(color)
                .frame(width: 50, height: 6)
        }
        .frame(width: max(0, layoutInfo.width), height: handleHeight)
        .contentShape(Rectangle())
        .highPriorityGesture(
            DragGesture(minimumDistance: 1)
                .onChanged { value in
                    activeGesture = .resizingBottom
                    resizeBottomOffset = value.translation.height
                }
                .onEnded { value in
                    commitResize(isTop: false, offset: value.translation.height)
                }
        )
    }
    
    // MARK: - Main Block
    private var mainBlock: some View {
        blockContent
            .shadow(
                color: isEditing ? color.opacity(0.35) : .clear,
                radius: isEditing ? 6 : 0
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .strokeBorder(color, lineWidth: isEditing ? 2 : 0)
            )
            .contentShape(Rectangle())
            .onTapGesture {
                if !isEditing {
                    onTap?()
                    HapticManager.shared.selection()
                }
            }
            .simultaneousGesture(
                LongPressGesture(minimumDuration: longPressDuration)
                    .onEnded { _ in
                        if !isEditing {
                            isEditing = true
                            HapticManager.shared.medium()
                        }
                    }
            )
            .highPriorityGesture(
                isEditing ?
                    DragGesture(minimumDistance: 5)
                        .onChanged { value in
                            activeGesture = .dragging
                            dragOffset = value.translation.height
                        }
                        .onEnded { value in
                            commitMove(offset: value.translation.height)
                        }
                    : nil
            )
    }
    
    // MARK: - Block Content
    @ViewBuilder
    private var blockContent: some View {
        if isDashed {
            dashedBlockContent
        } else {
            regularBlockContent
        }
    }
    
    private var regularBlockContent: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(color)
                .frame(width: 4)
            
            VStack(alignment: .leading, spacing: 2) {
                if currentHeight >= 28 {
                    eventContent
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                }
                Spacer(minLength: 0)
            }
            
            Spacer(minLength: 0)
        }
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(color.opacity(isEditing ? 0.25 : 0.15))
        )
        .cornerRadius(6)
    }
    
    private var dashedBlockContent: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(color.opacity(0.4))
                .frame(width: 4)
            
            VStack(alignment: .leading, spacing: 2) {
                if currentHeight >= 28 {
                    eventContent
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                }
                Spacer(minLength: 0)
            }
            
            Spacer(minLength: 0)
        }
        .background(
            RoundedRectangle(cornerRadius: 6)
                .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
                .foregroundColor(color.opacity(0.3))
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(color.opacity(0.05))
                )
        )
    }
    
    private var eventContent: some View {
        VStack(alignment: .leading, spacing: 1) {
            HStack(spacing: 4) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 10))
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(themeService.currentTheme.text)
                    .lineLimit(1)
            }
            
            if let subtitle = subtitle, currentHeight >= 45 {
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(themeService.currentTheme.textSecondary)
                    .lineLimit(1)
            }
        }
    }
    
    // MARK: - Commit Actions
    
    private func resetGestureState() {
        activeGesture = .none
        dragOffset = 0
        resizeTopOffset = 0
        resizeBottomOffset = 0
    }
    
    private func commitMove(offset: CGFloat) {
        defer { resetGestureState() }
        
        guard let onTimeChange = onTimeChange, abs(offset) > 5 else { return }
        
        let newStartY = layoutInfo.y + offset
        let newStartTime = TimelineLayoutHelper.timeFromYOffset(
            newStartY, baseDate: selectedDate, pixelsPerMinute: pixelsPerMinute
        )
        // Snap to 10-minute intervals
        let snappedStart = TimelineLayoutHelper.snapToInterval(newStartTime, intervalMinutes: snapIntervalMinutes)
        
        let originalDuration = layoutInfo.height / pixelsPerMinute
        let newEndTime = Calendar.current.date(
            byAdding: .minute, value: Int(originalDuration), to: snappedStart
        ) ?? snappedStart
        
        onTimeChange(snappedStart, newEndTime)
        HapticManager.shared.success()
    }
    
    private func commitResize(isTop: Bool, offset: CGFloat) {
        defer { resetGestureState() }
        
        guard let onTimeChange = onTimeChange, abs(offset) > 5 else { return }
        
        if isTop {
            let newStartY = layoutInfo.y + offset
            let newStartTime = TimelineLayoutHelper.timeFromYOffset(
                newStartY, baseDate: selectedDate, pixelsPerMinute: pixelsPerMinute
            )
            let snappedStart = TimelineLayoutHelper.snapToInterval(newStartTime, intervalMinutes: snapIntervalMinutes)
            
            let originalEndY = layoutInfo.y + layoutInfo.height
            let originalEndTime = TimelineLayoutHelper.timeFromYOffset(
                originalEndY, baseDate: selectedDate, pixelsPerMinute: pixelsPerMinute
            )
            
            if snappedStart < originalEndTime {
                onTimeChange(snappedStart, originalEndTime)
                HapticManager.shared.success()
            }
        } else {
            let newEndY = layoutInfo.y + layoutInfo.height + offset
            let newEndTime = TimelineLayoutHelper.timeFromYOffset(
                newEndY, baseDate: selectedDate, pixelsPerMinute: pixelsPerMinute
            )
            let snappedEnd = TimelineLayoutHelper.snapToInterval(newEndTime, intervalMinutes: snapIntervalMinutes)
            
            let originalStartTime = TimelineLayoutHelper.timeFromYOffset(
                layoutInfo.y, baseDate: selectedDate, pixelsPerMinute: pixelsPerMinute
            )
            
            if snappedEnd > originalStartTime {
                onTimeChange(originalStartTime, snappedEnd)
                HapticManager.shared.success()
            }
        }
    }
}

// MARK: - Preview
#Preview {
    struct PreviewWrapper: View {
        @State private var isEditing = false
        
        var body: some View {
            ZStack {
                Color.black.ignoresSafeArea()
                
                InteractiveEventBlock(
                    title: "Study Session",
                    subtitle: "Mathematics",
                    color: .blue,
                    icon: "book.fill",
                    isDashed: false,
                    layoutInfo: TimelineLayoutInfo(
                        id: UUID(), x: 60, width: 200, y: 100, height: 80, column: 0, totalColumns: 1
                    ),
                    pixelsPerMinute: 1.0,
                    selectedDate: Date(),
                    isEditing: $isEditing,
                    onTimeChange: { _, _ in },
                    onTap: { }
                )
                .environmentObject(ThemeService.shared)
            }
        }
    }
    
    return PreviewWrapper()
}
