//
//  NotificationManager.swift
//  benk
//
//  Created on 2025-12-11
//

import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }
    
    func sendTimerComplete(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil // Send immediately
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func scheduleDailyQuestReminder() {
        let content = UNMutableNotificationContent()
        content.title = "New Quests Available!"
        content.body = "Check out today's quests and earn rewards"
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = 9 // 9 AM
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "dailyQuestReminder",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
}
