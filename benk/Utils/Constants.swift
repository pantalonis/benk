//
//  Constants.swift
//  benk
//
//  Created on 2025-12-11
//

import Foundation

struct Constants {
    // Smart Tips
    static let smartTips = [
        "💡 Take breaks every 25-30 minutes to stay fresh",
        "🎯 Set specific goals before each study session",
        "🧠 Use active recall to test your understanding",
        "⏰ Study at your peak energy times",
        "📝 Write down key concepts in your own words",
        "🔄 Review material within 24 hours for better retention",
        "🎵 Try different study environments and sounds",
        "💪 Exercise before studying to boost focus",
        "🌙 Get 7-8 hours of sleep for better memory",
        "🥗 Stay hydrated and eat brain-healthy foods",
        "🎨 Use colors and diagrams to visualize concepts",
        "👥 Teach others what you've learned",
        "🚫 Eliminate distractions before starting",
        "📱 Use the pomodoro technique for better focus",
        "✨ Celebrate small wins to stay motivated"
    ]
    
    // Motivational placeholders for task input
    static let taskPlaceholders = [
        "What's your next challenge?",
        "One task at a time!",
        "What will you conquer today?",
        "Add your next victory...",
        "What's on your mind?",
        "Let's make progress!",
        "Your next achievement...",
        "What needs tackling?",
        "Build your success story..."
    ]
    
    // XP Constants
    static let baseXPPerMinute = 10
    static let taskCompletionXP = 50
    
    // Default Durations (in minutes)
    static let defaultStudyDuration = 25
    static let defaultPomodoroFocus = 25
    static let defaultPomodoroShortBreak = 5
    static let defaultPomodoroLongBreak = 15
    static let defaultPomodoroIntervals = 4
    
    // Animation Durations
    static let animationFast = 0.2
    static let animationNormal = 0.3
    static let animationSlow = 0.5
    static let animationSpring = 0.6
}
