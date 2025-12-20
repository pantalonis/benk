//
//  benk.swift
//  benk
//
//  Created on 2025-12-11
//

import SwiftUI
import SwiftData

@main
struct benk: App {
    @StateObject private var themeService = ThemeService.shared
    @StateObject private var timerService = TimerService.shared
    @StateObject private var badgeService = BadgeService.shared
    @StateObject private var xpService = XPService.shared
    @Environment(\.scenePhase) private var scenePhase
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            StudySession.self,
            Task.self,
            Quest.self,
            CustomReward.self,
            Badge.self,
            Subject.self,
            Technique.self,
            BreakSession.self,
            UserProfile.self,
            Event.self,
            Exam.self,
            Assignment.self
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )
        
        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            return container
        } catch {
            // If migration fails, try to delete and recreate
            print("ModelContainer creation failed: \(error)")
            print("Attempting to reset database...")
            
            // Delete existing database files
            if let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
                let defaultStorePath = appSupport.appendingPathComponent("default.store")
                try? FileManager.default.removeItem(at: defaultStorePath)
                
                // Try again after deletion
                do {
                    let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
                    print("Database reset successful")
                    return container
                } catch {
                    fatalError("Could not create ModelContainer even after reset: \(error)")
                }
            }
            
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    init() {
        // Request notification permissions
        NotificationManager.shared.requestAuthorization()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(sharedModelContainer)
                .environmentObject(themeService)
                .environmentObject(timerService)
                .environmentObject(badgeService)
                .environmentObject(xpService)
                .preferredColorScheme(themeService.currentTheme.isDark ? .dark : .light)
                .onChange(of: scenePhase) { _, newPhase in
                    switch newPhase {
                    case .background:
                        _Concurrency.Task { @MainActor in
                            timerService.handleAppDidEnterBackground()
                        }
                    case .active:
                        _Concurrency.Task { @MainActor in
                            timerService.handleAppWillEnterForeground()
                        }
                    default:
                        break
                    }
                }
        }
    }
}
