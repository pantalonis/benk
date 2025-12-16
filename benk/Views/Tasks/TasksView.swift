//
//  TasksView.swift
//  benk
//
//  Created on 2025-12-11
//

import SwiftUI
import SwiftData

struct TasksView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeService: ThemeService
    
    @Query(sort: \Task.createdAt, order: .reverse) private var tasks: [Task]
    @Query private var userProfiles: [UserProfile]
    @Query private var subjects: [Subject]
    
    @State private var newTaskTitle = ""
    @State private var currentPlaceholderIndex = 0
    @State private var showCongratulation = false
    @State private var selectedSubject: Subject? = nil
    
    let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    
    var userProfile: UserProfile {
        userProfiles.first ?? UserProfile()
    }
    
    var completedTasks: [Task] {
        tasks.filter { $0.isCompleted }
    }
    
    var incompleteTasks: [Task] {
        tasks.filter { !$0.isCompleted }
    }
    
    // XP Calculation removed
    var totalXPEarned: Int { 0 }

    
    var body: some View {
        ZStack {
            ThemedBackground(theme: themeService.currentTheme)
            
            VStack(spacing: 0) {
                // Custom Header with back button
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.left")
                            .font(.title2.weight(.semibold))
                            .foregroundColor(themeService.currentTheme.text)
                            .frame(width: 44, height: 44)
                            .background(themeService.currentTheme.surface.opacity(0.5))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text("Tasks")
                        .font(.title.weight(.bold))
                        .foregroundColor(themeService.currentTheme.text)
                    
                    Spacer()
                    
                    // Placeholder for symmetry
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Stats card
                VStack(spacing: 16) {
                    GlassCard {
                        HStack(spacing: 20) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(completedTasks.count)/\(tasks.count)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(themeService.currentTheme.text)
                                Text("Completed")
                                    .font(.caption)
                                    .foregroundColor(themeService.currentTheme.textSecondary)
                            }
                            
                            Spacer()
                            // XP Display Removed
                        }
                    }
                }
                .padding()
                
                // Add Task Input
                HStack(spacing: 12) {
                    TextField(Constants.taskPlaceholders[currentPlaceholderIndex], text: $newTaskTitle)
                        .textFieldStyle(.plain)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial)
                        )
                        .foregroundColor(themeService.currentTheme.text)
                    
                    // Subject Picker
                    Menu {
                        Button(action: { selectedSubject = nil }) {
                            Label("None", systemImage: "circle.slash")
                        }
                        
                        ForEach(subjects) { subject in
                            Button(action: { selectedSubject = subject }) {
                                Label(subject.name, systemImage: subject.iconName)
                            }
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .fill(selectedSubject?.color.opacity(0.2) ?? themeService.currentTheme.surface.opacity(0.5))
                                .frame(width: 44, height: 44)
                            
                            Image(systemName: selectedSubject?.iconName ?? "tag.fill")
                                .foregroundColor(selectedSubject?.color ?? themeService.currentTheme.textSecondary)
                                .font(.headline)
                        }
                    }
                    
                    Button(action: addTask) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title)
                            .foregroundColor(themeService.currentTheme.accent)
                    }
                    .disabled(newTaskTitle.isEmpty)
                }
                .padding(.horizontal)
                .onReceive(timer) { _ in
                    withAnimation {
                        currentPlaceholderIndex = (currentPlaceholderIndex + 1) % Constants.taskPlaceholders.count
                    }
                }
                
                // Task List
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        // Incomplete Tasks - Categorized
                        
                        // 1. General (No Subject)
                        let generalTasks = incompleteTasks.filter { $0.subjectId == nil }
                        if !generalTasks.isEmpty {
                            Text("General")
                                .font(.headline)
                                .foregroundColor(themeService.currentTheme.textSecondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                            
                            ForEach(Array(generalTasks.enumerated()), id: \.element.id) { index, task in
                                TaskRow(task: task, onDelete: {
                                    deleteTask(task)
                                }, onComplete: {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                        showCongratulation = true
                                    }
                                }, index: index)
                            }
                        }
                        
                        // 2. By Subject
                        ForEach(subjects) { subject in
                            let subjectTasks = incompleteTasks.filter { $0.subjectId == subject.id }
                            if !subjectTasks.isEmpty {
                                HStack(spacing: 8) {
                                    Image(systemName: subject.iconName)
                                    Text(subject.name)
                                }
                                .font(.headline)
                                .foregroundColor(subject.color)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                                .padding(.top, 8)
                                
                                ForEach(Array(subjectTasks.enumerated()), id: \.element.id) { index, task in
                                    TaskRow(task: task, onDelete: {
                                        deleteTask(task)
                                    }, onComplete: {
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                            showCongratulation = true
                                        }
                                    }, index: index)
                                }
                            }
                        }
                        
                        // Completed Tasks
                        if !completedTasks.isEmpty {
                            Divider()
                                .padding(.vertical)
                            
                            Text("Completed")
                                .font(.headline)
                                .foregroundColor(themeService.currentTheme.textSecondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                            
                            ForEach(Array(completedTasks.enumerated()), id: \.element.id) { index, task in
                                TaskRow(task: task, onDelete: {
                                    deleteTask(task)
                                }, onComplete: {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                        showCongratulation = true
                                    }
                                }, index: index)
                            }
                        }
                        
                        Spacer(minLength: 20)
                    }
                    .padding()
                }
                
                // Smart Tips
                SmartTipsView()
                    .padding()
            }
            
            if showCongratulation {
                CongratulationPopup()
                    .transition(.scale.combined(with: .opacity))
                    .zIndex(100)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation {
                                showCongratulation = false
                            }
                        }
                    }
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
    
    private func addTask() {
        guard !newTaskTitle.isEmpty else { return }
        
        let task = Task(title: newTaskTitle, subjectId: selectedSubject?.id)
        modelContext.insert(task)
        
        newTaskTitle = ""
        // Keep selected subject for batch entry? Let's reset for now to avoid confusion.
        // selectedSubject = nil 
        HapticManager.shared.light()
    }
    
    private func deleteTask(_ task: Task) {
        withAnimation {
            modelContext.delete(task)
        }
        HapticManager.shared.light()
    }
}

struct TaskRow: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var themeService: ThemeService
    @Query private var userProfiles: [UserProfile]
    @Query private var subjects: [Subject]
    
    let task: Task
    let onDelete: () -> Void
    let onComplete: () -> Void
    let index: Int
    
    @State private var isChecked: Bool
    @State private var isVisible = false
    @State private var isDeleting = false
    
    init(task: Task, onDelete: @escaping () -> Void, onComplete: @escaping () -> Void, index: Int = 0) {
        self.task = task
        self.onDelete = onDelete
        self.onComplete = onComplete
        self.index = index
        self._isChecked = State(initialValue: task.isCompleted)
    }
    
    var userProfile: UserProfile {
        userProfiles.first ?? UserProfile()
    }
    
    var taskSubject: Subject? {
        subjects.first { $0.id == task.subjectId }
    }
    
    var body: some View {
        GlassCard {
            HStack(spacing: 12) {
                AnimatedCheckbox(isChecked: Binding(
                    get: { task.isCompleted },
                    set: { newValue in
                        toggleTask(newValue)
                    }
                )) {
                    // No additional action needed
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .font(.body)
                        .foregroundColor(themeService.currentTheme.text)
                        .strikethrough(task.isCompleted)
                    
                    if let subject = taskSubject {
                        Text(subject.name)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(subject.color.opacity(0.2))
                            .foregroundColor(subject.color)
                            .clipShape(Capsule())
                    }
                }
                
                Spacer()
                
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isDeleting = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        onDelete()
                    }
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red.opacity(0.7))
                        .font(.system(size: 16))
                }
            }
        }
        .opacity(task.isCompleted ? 0.6 : 1.0)
        .opacity(isVisible ? 1.0 : 0.0)
        .offset(y: isVisible ? 0 : 10)
        .scaleEffect(isDeleting ? 0.8 : 1.0)
        .opacity(isDeleting ? 0 : 1.0)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.75).delay(Double(index) * 0.05)) {
                isVisible = true
            }
        }
    }
    
    private func toggleTask(_ newValue: Bool) {
        task.isCompleted = newValue
        
        if newValue {
            task.completedAt = Date()
            
            // Log completion in analytics (no XP for tasks)
            let session = StudySession(
                duration: 0,
                xpEarned: 0,
                timestamp: Date(),
                subjectId: task.subjectId,
                isCompleted: true
            )
            modelContext.insert(session)
            
            // Update quest progress
            updateQuestProgress()
            
            onComplete()
            HapticManager.shared.success()
        } else {
            task.completedAt = nil
        }
        
        try? modelContext.save()
    }
    
    private func updateQuestProgress() {
        // Record task completion in persistent stats (survives task deletion)
        QuestStats.shared.recordTaskCompletion()
        
        // Update quest progress with new stats
        QuestService.shared.updateAllProgress()
    }
}

#Preview {
    TasksView()
        .modelContainer(for: [Task.self, UserProfile.self])
        .environmentObject(ThemeService.shared)
}
