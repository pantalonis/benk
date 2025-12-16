//
//  TimelineLayoutHelper.swift
//  benk
//
//  Created on 2025-12-16
//
//  Provides reusable layout calculations for the day timeline.
//  All functions are pure and stateless for testability.
//

import Foundation
import SwiftUI

// MARK: - Timeline Item Protocol
/// Unified protocol for all items that can appear on the timeline
protocol TimelineItemProtocol: Identifiable {
    var id: UUID { get }
    var timelineStartTime: Date { get }
    var timelineEndTime: Date { get }
    var timelineColor: Color { get }
    var timelineTitle: String { get }
}

// MARK: - Layout Info
/// Contains calculated layout information for a timeline item
struct TimelineLayoutInfo: Identifiable {
    let id: UUID
    let x: CGFloat           // X position from left edge of event area
    let width: CGFloat       // Width of the event block
    let y: CGFloat           // Y position from top (minutes since midnight × pixelsPerMinute)
    let height: CGFloat      // Height (duration × pixelsPerMinute)
    let column: Int          // Column index for overlapping events
    let totalColumns: Int    // Total columns in overlap group
}

// MARK: - Overlap Group
/// Represents a group of overlapping timeline items
struct OverlapGroup {
    var items: [any TimelineItemProtocol]
    var startTime: Date
    var endTime: Date
    
    /// Check if an item overlaps with this group
    func overlaps(with item: any TimelineItemProtocol) -> Bool {
        // Two items overlap if one starts before the other ends
        return item.timelineStartTime < endTime && item.timelineEndTime > startTime
    }
    
    /// Add an item to the group and extend time range
    mutating func add(_ item: any TimelineItemProtocol) {
        items.append(item)
        // Extend group time range
        if item.timelineStartTime < startTime {
            startTime = item.timelineStartTime
        }
        if item.timelineEndTime > endTime {
            endTime = item.timelineEndTime
        }
    }
}

// MARK: - Timeline Layout Helper
/// Pure helper functions for timeline layout calculations
enum TimelineLayoutHelper {
    
    // MARK: - Time Calculations
    
    /// Calculate minutes since midnight for a given date
    /// - Parameter date: The date to calculate from
    /// - Returns: Number of minutes since 00:00 of that day
    static func minutesSinceMidnight(for date: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: date)
        return (components.hour ?? 0) * 60 + (components.minute ?? 0)
    }
    
    /// Calculate Y position for a given time
    /// - Parameters:
    ///   - date: The time to position
    ///   - pixelsPerMinute: Scale factor (hourHeight / 60)
    /// - Returns: Y offset from top of timeline
    static func yPosition(for date: Date, pixelsPerMinute: CGFloat) -> CGFloat {
        let minutes = minutesSinceMidnight(for: date)
        return CGFloat(minutes) * pixelsPerMinute
    }
    
    /// Calculate block height for an event
    /// - Parameters:
    ///   - startTime: Event start time
    ///   - endTime: Event end time
    ///   - pixelsPerMinute: Scale factor
    /// - Returns: Height in points
    static func blockHeight(startTime: Date, endTime: Date, pixelsPerMinute: CGFloat) -> CGFloat {
        let durationSeconds = endTime.timeIntervalSince(startTime)
        let durationMinutes = durationSeconds / 60.0
        // Minimum height of 20pt for very short events
        return max(20, CGFloat(durationMinutes) * pixelsPerMinute)
    }
    
    // MARK: - Overlap Detection
    
    /// Detect overlapping events and group them
    /// - Parameter items: Array of timeline items to analyze
    /// - Returns: Array of overlap groups
    static func detectOverlapGroups<T: TimelineItemProtocol>(_ items: [T]) -> [[T]] {
        guard !items.isEmpty else { return [] }
        
        // Sort items by start time
        let sorted = items.sorted { $0.timelineStartTime < $1.timelineStartTime }
        
        var groups: [[T]] = []
        var currentGroup: [T] = []
        var currentGroupEnd: Date = .distantPast
        
        for item in sorted {
            if item.timelineStartTime < currentGroupEnd {
                // Overlaps with current group
                currentGroup.append(item)
                // Extend group end if this item ends later
                if item.timelineEndTime > currentGroupEnd {
                    currentGroupEnd = item.timelineEndTime
                }
            } else {
                // No overlap - start new group
                if !currentGroup.isEmpty {
                    groups.append(currentGroup)
                }
                currentGroup = [item]
                currentGroupEnd = item.timelineEndTime
            }
        }
        
        // Don't forget the last group
        if !currentGroup.isEmpty {
            groups.append(currentGroup)
        }
        
        return groups
    }
    
    /// Assign columns to overlapping events within a group
    /// - Parameter group: Array of overlapping items
    /// - Returns: Dictionary mapping item IDs to (column, totalColumns)
    static func assignColumns<T: TimelineItemProtocol>(_ group: [T]) -> [UUID: (column: Int, totalColumns: Int)] {
        guard !group.isEmpty else { return [:] }
        
        // Sort by start time for consistent column assignment
        let sorted = group.sorted { $0.timelineStartTime < $1.timelineStartTime }
        
        // Track end times for each column
        var columnEndTimes: [Date] = []
        var assignments: [UUID: (column: Int, totalColumns: Int)] = [:]
        
        for item in sorted {
            // Find first available column (where previous item has ended)
            var assignedColumn = 0
            var foundColumn = false
            
            for (columnIndex, endTime) in columnEndTimes.enumerated() {
                if item.timelineStartTime >= endTime {
                    // This column is free
                    assignedColumn = columnIndex
                    columnEndTimes[columnIndex] = item.timelineEndTime
                    foundColumn = true
                    break
                }
            }
            
            if !foundColumn {
                // Need a new column
                assignedColumn = columnEndTimes.count
                columnEndTimes.append(item.timelineEndTime)
            }
            
            assignments[item.id] = (column: assignedColumn, totalColumns: 0) // Will update totalColumns after
        }
        
        // Now update totalColumns for all items in the group
        let totalColumns = columnEndTimes.count
        for (id, assignment) in assignments {
            assignments[id] = (column: assignment.column, totalColumns: totalColumns)
        }
        
        return assignments
    }
    
    // MARK: - Full Layout Calculation
    
    /// Calculate complete layout for all timeline items
    /// - Parameters:
    ///   - items: All timeline items for the day
    ///   - pixelsPerMinute: Scale factor
    ///   - availableWidth: Width available for event blocks (after hour labels)
    ///   - horizontalPadding: Padding between events
    /// - Returns: Array of layout info for each item
    static func calculateLayout<T: TimelineItemProtocol>(
        items: [T],
        pixelsPerMinute: CGFloat,
        availableWidth: CGFloat,
        horizontalPadding: CGFloat = 2
    ) -> [TimelineLayoutInfo] {
        guard !items.isEmpty else { return [] }
        
        // Group overlapping items
        let groups = detectOverlapGroups(items)
        
        var layouts: [TimelineLayoutInfo] = []
        
        for group in groups {
            // Assign columns within this group
            let columnAssignments = assignColumns(group)
            
            for item in group {
                guard let assignment = columnAssignments[item.id] else { continue }
                
                // Calculate position and size
                let y = yPosition(for: item.timelineStartTime, pixelsPerMinute: pixelsPerMinute)
                let height = blockHeight(
                    startTime: item.timelineStartTime,
                    endTime: item.timelineEndTime,
                    pixelsPerMinute: pixelsPerMinute
                )
                
                // Calculate width based on number of columns
                let columnWidth = (availableWidth - CGFloat(assignment.totalColumns - 1) * horizontalPadding) / CGFloat(assignment.totalColumns)
                let x = CGFloat(assignment.column) * (columnWidth + horizontalPadding)
                
                layouts.append(TimelineLayoutInfo(
                    id: item.id,
                    x: x,
                    width: columnWidth,
                    y: y,
                    height: height,
                    column: assignment.column,
                    totalColumns: assignment.totalColumns
                ))
            }
        }
        
        return layouts
    }
    
    // MARK: - Time Snapping
    
    /// Snap a time to the nearest interval (for cleaner drag results)
    /// - Parameters:
    ///   - date: The date to snap
    ///   - intervalMinutes: Snap interval (default 5 minutes)
    /// - Returns: Snapped date
    static func snapToInterval(_ date: Date, intervalMinutes: Int = 5) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        
        guard let minute = components.minute else { return date }
        
        // Round to nearest interval
        let snappedMinute = (minute / intervalMinutes) * intervalMinutes
        
        var newComponents = components
        newComponents.minute = snappedMinute
        newComponents.second = 0
        
        return calendar.date(from: newComponents) ?? date
    }
    
    /// Convert Y offset back to time
    /// - Parameters:
    ///   - yOffset: Y position in timeline
    ///   - baseDate: The day being viewed
    ///   - pixelsPerMinute: Scale factor
    /// - Returns: The time corresponding to that Y position
    static func timeFromYOffset(_ yOffset: CGFloat, baseDate: Date, pixelsPerMinute: CGFloat) -> Date {
        let minutes = Int(yOffset / pixelsPerMinute)
        let clampedMinutes = max(0, min(minutes, 24 * 60 - 1)) // Clamp to valid day range
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: baseDate)
        
        return calendar.date(byAdding: .minute, value: clampedMinutes, to: startOfDay) ?? baseDate
    }
}
