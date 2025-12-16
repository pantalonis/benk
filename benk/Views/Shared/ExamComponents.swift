//
//  ExamComponents.swift
//  benk
//
//  Created on 2025-12-15
//

import SwiftUI

// MARK: - Countdown Badge Component
struct CountdownBadge: View {
    let exam: Exam
    let size: BadgeSize
    
    enum BadgeSize {
        case small
        case medium
        case large
        
        var font: Font {
            switch self {
            case .small: return .caption2
            case .medium: return .subheadline
            case .large: return .headline
            }
        }
        
        var horizontalPadding: CGFloat {
            switch self {
            case .small: return 8
            case .medium: return 12
            case .large: return 16
            }
        }
        
        var verticalPadding: CGFloat {
            switch self {
            case .small: return 4
            case .medium: return 6
            case .large: return 8
            }
        }
    }
    
    init(exam: Exam, size: BadgeSize = .medium) {
        self.exam = exam
        self.size = size
    }
    
    var body: some View {
        Text(exam.countdownText)
            .font(size.font)
            .fontWeight(.semibold)
            .foregroundStyle(.white)
            .padding(.horizontal, size.horizontalPadding)
            .padding(.vertical, size.verticalPadding)
            .background(
                Capsule()
                    .fill(exam.urgency.color)
                    .shadow(color: exam.urgency.color.opacity(0.3), radius: 4, x: 0, y: 2)
            )
    }
}

// MARK: - Subject Color Tag Component
struct SubjectColorTag: View {
    let subject: Subject?
    let defaultColor: Color
    let defaultName: String
    let size: TagSize
    
    enum TagSize {
        case small
        case medium
        case large
        
        var fontSize: CGFloat {
            switch self {
            case .small: return 12
            case .medium: return 14
            case .large: return 16
            }
        }
        
        var circleSize: CGFloat {
            switch self {
            case .small: return 8
            case .medium: return 12
            case .large: return 16
            }
        }
        
        var spacing: CGFloat {
            switch self {
            case .small: return 6
            case .medium: return 8
            case .large: return 10
            }
        }
    }
    
    init(subject: Subject?, defaultColor: Color = .blue, defaultName: String = "Exam", size: TagSize = .medium) {
        self.subject = subject
        self.defaultColor = defaultColor
        self.defaultName = defaultName
        self.size = size
    }
    
    var displayColor: Color {
        subject?.color ?? defaultColor
    }
    
    var displayName: String {
        subject?.name ?? defaultName
    }
    
    var body: some View {
        HStack(spacing: size.spacing) {
            Circle()
                .fill(displayColor)
                .frame(width: size.circleSize, height: size.circleSize)
                .shadow(color: displayColor.opacity(0.4), radius: 2, x: 0, y: 1)
            
            Text(displayName)
                .font(.system(size: size.fontSize, weight: .semibold))
        }
    }
}

// MARK: - Subject Color Strip Component
struct SubjectColorStrip: View {
    let subject: Subject?
    let defaultColor: Color
    let width: CGFloat
    
    init(subject: Subject?, defaultColor: Color = .blue, width: CGFloat = 4) {
        self.subject = subject
        self.defaultColor = defaultColor
        self.width = width
    }
    
    var displayColor: Color {
        subject?.color ?? defaultColor
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: width / 2)
            .fill(displayColor)
            .frame(width: width)
            .shadow(color: displayColor.opacity(0.3), radius: 2, x: 0, y: 0)
    }
}

// MARK: - Alerts List View
struct AlertsListView: View {
    let alerts: [Int]
    @EnvironmentObject var themeService: ThemeService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if alerts.isEmpty {
                Text("No alerts set")
                    .font(.caption)
                    .foregroundColor(themeService.currentTheme.textSecondary)
            } else {
                ForEach(Array(alerts.enumerated()), id: \.offset) { index, minutes in
                    HStack(spacing: 8) {
                        Image(systemName: "bell.fill")
                            .font(.caption)
                            .foregroundColor(themeService.currentTheme.accent)
                        
                        Text(formatAlertTime(minutes))
                            .font(.subheadline)
                            .foregroundColor(themeService.currentTheme.text)
                    }
                }
            }
        }
    }
    
    private func formatAlertTime(_ minutes: Int) -> String {
        if minutes < 60 {
            return "\(minutes) minute\(minutes == 1 ? "" : "s") before"
        } else if minutes < 1440 {
            let hours = minutes / 60
            return "\(hours) hour\(hours == 1 ? "" : "s") before"
        } else {
            let days = minutes / 1440
            return "\(days) day\(days == 1 ? "" : "s") before"
        }
    }
}

// MARK: - Exam Info Row Component
struct ExamInfoRow: View {
    let icon: String
    let title: String
    let value: String
    @EnvironmentObject var themeService: ThemeService
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(themeService.currentTheme.accent)
                .font(.title3)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(themeService.currentTheme.textSecondary)
                
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(themeService.currentTheme.text)
            }
            
            Spacer()
        }
    }
}

// MARK: - Empty Exam State
struct EmptyExamState: View {
    let icon: String
    let title: String
    let subtitle: String
    @EnvironmentObject var themeService: ThemeService
    
    init(icon: String = "doc.text", title: String = "No Exams", subtitle: String = "You're all caught up!") {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 64))
                .foregroundColor(themeService.currentTheme.textSecondary.opacity(0.5))
                .padding(.top, 60)
            
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(themeService.currentTheme.text)
            
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(themeService.currentTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

// MARK: - Preview Support
#Preview("Countdown Badges") {
    let mockExam1 = Exam(examDate: Date().addingTimeInterval(86400), examDescription: "Tomorrow")
    let mockExam2 = Exam(examDate: Date().addingTimeInterval(259200), examDescription: "3 days")
    let mockExam3 = Exam(examDate: Date().addingTimeInterval(604800), examDescription: "1 week")
    
    return VStack(spacing: 20) {
        CountdownBadge(exam: mockExam1, size: .small)
        CountdownBadge(exam: mockExam2, size: .medium)
        CountdownBadge(exam: mockExam3, size: .large)
    }
    .padding()
    .environmentObject(ThemeService.shared)
}

#Preview("Subject Tags") {
    let mockSubject = Subject(name: "Mathematics", colorHex: "#FF6B6B", iconName: "function")
    
    return VStack(spacing: 20) {
        SubjectColorTag(subject: mockSubject, size: .small)
        SubjectColorTag(subject: mockSubject, size: .medium)
        SubjectColorTag(subject: mockSubject, size: .large)
        SubjectColorTag(subject: nil, size: .medium)
    }
    .padding()
    .environmentObject(ThemeService.shared)
}

#Preview("Alerts List") {
    AlertsListView(alerts: [60, 1440, 10080])
        .padding()
        .environmentObject(ThemeService.shared)
}
