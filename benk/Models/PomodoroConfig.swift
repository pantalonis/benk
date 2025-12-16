//
//  PomodoroConfig.swift
//  benk
//
//  Created on 2025-12-11
//

import Foundation
import SwiftData

@Model
final class PomodoroConfig {
    var id: UUID
    var focusDuration: Int // in seconds
    var shortBreakDuration: Int
    var longBreakDuration: Int
    var intervalsBeforeLongBreak: Int
    
    init(
        id: UUID = UUID(),
        focusDuration: Int = 25 * 60, // 25 minutes
        shortBreakDuration: Int = 5 * 60, // 5 minutes
        longBreakDuration: Int = 15 * 60, // 15 minutes
        intervalsBeforeLongBreak: Int = 4
    ) {
        self.id = id
        self.focusDuration = focusDuration
        self.shortBreakDuration = shortBreakDuration
        self.longBreakDuration = longBreakDuration
        self.intervalsBeforeLongBreak = intervalsBeforeLongBreak
    }
    
    var focusMinutes: Int {
        get { focusDuration / 60 }
        set { focusDuration = newValue * 60 }
    }
    
    var shortBreakMinutes: Int {
        get { shortBreakDuration / 60 }
        set { shortBreakDuration = newValue * 60 }
    }
    
    var longBreakMinutes: Int {
        get { longBreakDuration / 60 }
        set { longBreakDuration = newValue * 60 }
    }
}
