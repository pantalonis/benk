//
//  RoomView.swift
//  benk
//
//  Room tab that embeds the Pixel Room customization feature (Project 2)
//  This view is a container that hosts the full Pixel Room experience
//

import SwiftUI

struct RoomView: View {
    @EnvironmentObject var themeService: ThemeService
    
    var body: some View {
        // Embed the Pixel Room container which contains the full Project 2 experience
        // with its own vertical side tab navigation
        PixelRoomContainerView()
            .environmentObject(themeService as ThemeService) // For parentTheme in container
    }
}

#Preview {
    RoomView()
        .environmentObject(ThemeService.shared)
}

