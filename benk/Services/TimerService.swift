//
//  TimerService.swift
//  benk
//
//  Created on 2025-12-11
//

import Foundation
import Combine
import UserNotifications

enum TimerMode {
    case normal
    case pomodoro
}

enum PomodoroPhase {
    case focus
    case shortBreak
    case longBreak
}

@MainActor
class TimerService: ObservableObject {
    static let shared = TimerService()
    
    @Published var remainingTime: Int = 0
    @Published var isRunning: Bool = false
    @Published var isPaused: Bool = false
    @Published var mode: TimerMode = .normal
    @Published var pomodoroPhase: PomodoroPhase = .focus
    @Published var completedIntervals: Int = 0
    @Published var elapsedTime: Int = 0  // For stopwatch mode - total cumulative time (for display)
    @Published var segmentElapsedTime: Int = 0  // Time since last resume (for logging)
    
    // Break Timer persistence
    @Published var breakDuration: Int = 0
    @Published var isBreakActive: Bool = false
    private var breakTimer: Timer?
    
    private var timer: Timer?
    private var startTime: Date?
    private var totalDuration: Int = 0
    private var isStopwatchMode: Bool = false
    
    var progress: Double {
        guard totalDuration > 0 else { return 0 }
        return 1.0 - (Double(remainingTime) / Double(totalDuration))
    }
    
    var timeString: String {
        let hours = remainingTime / 3600
        let minutes = (remainingTime % 3600) / 60
        let seconds = remainingTime % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    var stopwatchTimeString: String {
        let hours = elapsedTime / 3600
        let minutes = (elapsedTime % 3600) / 60
        let seconds = elapsedTime % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    private init() {}
    
    /// Start timer in normal mode
    func startNormal(durationMinutes: Int) {
        mode = .normal
        totalDuration = durationMinutes * 60
        remainingTime = totalDuration
        startTimer()
    }
    
    /// Start timer in pomodoro mode
    func startPomodoro(config: PomodoroConfig) {
        mode = .pomodoro
        pomodoroPhase = .focus
        completedIntervals = 0
        startPomodoroPhase(config: config)
    }
    
    private func startPomodoroPhase(config: PomodoroConfig) {
        switch pomodoroPhase {
        case .focus:
            totalDuration = config.focusDuration
        case .shortBreak:
            totalDuration = config.shortBreakDuration
        case .longBreak:
            totalDuration = config.longBreakDuration
        }
        
        remainingTime = totalDuration
        startTimer()
    }
    
    /// Start timer in stopwatch mode
    func startStopwatch() {
        isStopwatchMode = true
        elapsedTime = 0
        startTimer()
    }
    
    // MARK: - Break Timer Logic
    func startBreak() {
        isBreakActive = true
        breakDuration = 0
        
        breakTimer?.invalidate()
        breakTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            _Concurrency.Task { @MainActor [weak self] in
                self?.breakDuration += 1
            }
        }
        RunLoop.current.add(breakTimer!, forMode: .common)
    }
    
    func stopBreak() -> Int {
        breakTimer?.invalidate()
        breakTimer = nil
        isBreakActive = false
        
        let duration = breakDuration
        breakDuration = 0
        return duration
    }
    
    private func startTimer() {
        isRunning = true
        isPaused = false
        startTime = Date()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            _Concurrency.Task { @MainActor [weak self] in
                self?.tick()
            }
        }
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    private func tick() {
        if isStopwatchMode {
            // Count up for stopwatch - both total and segment
            elapsedTime += 1
            segmentElapsedTime += 1
        } else {
            // Count down for regular timer
            guard remainingTime > 0 else {
                completeTimer()
                return
            }
            
            remainingTime -= 1
        }
    }
    
    /// Pause the timer
    func pause() {
        isPaused = true
        timer?.invalidate()
        timer = nil
    }
    
    /// Resume the timer
    func resume() {
        guard isPaused else { return }
        isPaused = false
        segmentElapsedTime = 0  // Reset segment tracker for new session segment
        startTimer()
    }
    
    /// Stop the timer
    func stop() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        isPaused = false
        remainingTime = 0
        totalDuration = 0
        elapsedTime = 0
        segmentElapsedTime = 0
        isStopwatchMode = false
    }
    
    /// Reset elapsed time for next session segment (used for incremental logging)
    func resetElapsedTime() {
        elapsedTime = 0
    }
    
    private func completeTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        
        HapticManager.shared.success()
        
        // Send notification
        if mode == .pomodoro {
            switch pomodoroPhase {
            case .focus:
                NotificationManager.shared.sendTimerComplete(title: "Focus Session Complete!", body: "Great work! Time for a break.")
            case .shortBreak, .longBreak:
                NotificationManager.shared.sendTimerComplete(title: "Break Over!", body: "Ready to focus again?")
            }
        } else {
            NotificationManager.shared.sendTimerComplete(title: "Study Session Complete!", body: "You earned XP! Keep it up.")
        }
    }
    
    /// Complete pomodoro phase and transition to next
    func completePhase(config: PomodoroConfig) {
        guard mode == .pomodoro else { return }
        
        switch pomodoroPhase {
        case .focus:
            completedIntervals += 1
            
            if completedIntervals >= config.intervalsBeforeLongBreak {
                pomodoroPhase = .longBreak
                completedIntervals = 0
            } else {
                pomodoroPhase = .shortBreak
            }
            
        case .shortBreak, .longBreak:
            pomodoroPhase = .focus
        }
        
        startPomodoroPhase(config: config)
    }
    
    /// Skip current pomodoro phase
    func skipPhase(config: PomodoroConfig) {
        stop()
        completePhase(config: config)
    }
}
