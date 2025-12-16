//
//  AppTheme.swift
//  benk
//
//  Created on 2025-12-11
//

import SwiftUI

protocol AppTheme {
    var id: String { get }
    var name: String { get }
    var price: Int { get }
    var isDark: Bool { get }
    
    // Colors
    var background: LinearGradient { get }
    var surface: Color { get }
    var primary: Color { get }
    var accent: Color { get }
    var text: Color { get }
    var textSecondary: Color { get }
    var glow: Color { get }
    
    // Effects
    var hasGlow: Bool { get }
    var hasStars: Bool { get }
    var hasScanline: Bool { get }
    var hasCuteElements: Bool { get }
    var hasParticles: Bool { get }
    
    // Christmas Effects
    var hasSnow: Bool { get }
    var hasSanta: Bool { get }
    var isChristmas: Bool { get }
}

// Default implementations
extension AppTheme {
    var hasGlow: Bool { false }
    var hasStars: Bool { false }
    var hasScanline: Bool { false }
    var hasCuteElements: Bool { false }
    var hasParticles: Bool { false }
    var hasSnow: Bool { false }
    var hasSanta: Bool { false }
    var isChristmas: Bool { false }
}
