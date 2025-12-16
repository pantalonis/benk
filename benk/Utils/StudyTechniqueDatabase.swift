//
//  StudyTechniqueDatabase.swift
//  benk
//
//  Created on 2025-12-13
//

import Foundation
import SwiftData

struct StudyTechniqueDatabase {
    
    static func seedTechniques(context: ModelContext) {
        // Check if techniques already exist
        let descriptor = FetchDescriptor<Technique>()
        if let existingCount = try? context.fetchCount(descriptor), existingCount > 0 {
            return // Already seeded
        }
        
        // Create all techniques
        let techniques = getAllTechniques()
        
        for technique in techniques {
            context.insert(technique)
        }
        
        try? context.save()
    }
    
    private static func getAllTechniques() -> [Technique] {
        var techniques: [Technique] = []
        
        // ⭐ 1. Cognitive Techniques
        // 1.1 Memory & Retrieval
        techniques.append(Technique(
            name: "Active Recall",
            techniqueDescription: "Recall info without notes.",
            iconName: "brain.head.profile",
            xpMultiplier: 1.0,
            category: "Cognitive Techniques",
            subcategory: "Memory & Retrieval",
            effectivenessRating: 10
        ))
        
        techniques.append(Technique(
            name: "Retrieval Practice",
            techniqueDescription: "Repeated self-testing.",
            iconName: "arrow.clockwise",
            xpMultiplier: 1.0,
            category: "Cognitive Techniques",
            subcategory: "Memory & Retrieval",
            effectivenessRating: 10
        ))
        
        techniques.append(Technique(
            name: "Spaced Repetition",
            techniqueDescription: "Review at spaced intervals.",
            iconName: "calendar.badge.clock",
            xpMultiplier: 1.0,
            category: "Cognitive Techniques",
            subcategory: "Memory & Retrieval",
            effectivenessRating: 10
        ))
        
        techniques.append(Technique(
            name: "Interleaving",
            techniqueDescription: "Mix topics while studying.",
            iconName: "shuffle",
            xpMultiplier: 0.95,
            category: "Cognitive Techniques",
            subcategory: "Memory & Retrieval",
            effectivenessRating: 9
        ))
        
        techniques.append(Technique(
            name: "Mnemonics",
            techniqueDescription: "Memory aids like acronyms.",
            iconName: "textformat.abc",
            xpMultiplier: 0.75,
            category: "Cognitive Techniques",
            subcategory: "Memory & Retrieval",
            effectivenessRating: 7
        ))
        
        techniques.append(Technique(
            name: "Chunking",
            techniqueDescription: "Group info into smaller units.",
            iconName: "square.3.layers.3d",
            xpMultiplier: 0.95,
            category: "Cognitive Techniques",
            subcategory: "Memory & Retrieval",
            effectivenessRating: 9
        ))
        
        techniques.append(Technique(
            name: "Keyword Method",
            techniqueDescription: "Link new words to familiar ones.",
            iconName: "link",
            xpMultiplier: 0.75,
            category: "Cognitive Techniques",
            subcategory: "Memory & Retrieval",
            effectivenessRating: 7
        ))
        
        techniques.append(Technique(
            name: "Peg System",
            techniqueDescription: "Attach items to number \"pegs.\"",
            iconName: "number",
            xpMultiplier: 0.75,
            category: "Cognitive Techniques",
            subcategory: "Memory & Retrieval",
            effectivenessRating: 7
        ))
        
        techniques.append(Technique(
            name: "Loci Method",
            techniqueDescription: "Place info in imagined locations.",
            iconName: "map",
            xpMultiplier: 0.75,
            category: "Cognitive Techniques",
            subcategory: "Memory & Retrieval",
            effectivenessRating: 7
        ))
        
        techniques.append(Technique(
            name: "Story Linking",
            techniqueDescription: "Turn facts into a short story.",
            iconName: "text.book.closed",
            xpMultiplier: 0.75,
            category: "Cognitive Techniques",
            subcategory: "Memory & Retrieval",
            effectivenessRating: 7
        ))
        
        techniques.append(Technique(
            name: "Flashcards",
            techniqueDescription: "Use cards for active recall practice.",
            iconName: "rectangle.stack",
            xpMultiplier: 0.95,
            category: "Cognitive Techniques",
            subcategory: "Memory & Retrieval",
            effectivenessRating: 9
        ))
        
        // 1.2 Understanding & Reasoning
        techniques.append(Technique(
            name: "Elaboration",
            techniqueDescription: "Ask \"why\" to deepen learning.",
            iconName: "questionmark.circle",
            xpMultiplier: 0.95,
            category: "Cognitive Techniques",
            subcategory: "Understanding & Reasoning",
            effectivenessRating: 9
        ))
        
        techniques.append(Technique(
            name: "Feynman Technique",
            techniqueDescription: "Explain simply to test understanding.",
            iconName: "bubble.left.and.bubble.right",
            xpMultiplier: 0.95,
            category: "Cognitive Techniques",
            subcategory: "Understanding & Reasoning",
            effectivenessRating: 9
        ))
        
        techniques.append(Technique(
            name: "Self-Explanation",
            techniqueDescription: "Explain steps as you work.",
            iconName: "person.crop.circle.badge.questionmark",
            xpMultiplier: 0.95,
            category: "Cognitive Techniques",
            subcategory: "Understanding & Reasoning",
            effectivenessRating: 9
        ))
        
        techniques.append(Technique(
            name: "Visualization",
            techniqueDescription: "Picture concepts mentally.",
            iconName: "eye",
            xpMultiplier: 0.75,
            category: "Cognitive Techniques",
            subcategory: "Understanding & Reasoning",
            effectivenessRating: 7
        ))
        
        techniques.append(Technique(
            name: "Dual Coding",
            techniqueDescription: "Combine text and visuals.",
            iconName: "photo.on.rectangle.angled",
            xpMultiplier: 0.95,
            category: "Cognitive Techniques",
            subcategory: "Understanding & Reasoning",
            effectivenessRating: 9
        ))
        
        techniques.append(Technique(
            name: "Mind Mapping",
            techniqueDescription: "Connect ideas visually.",
            iconName: "point.3.connected.trianglepath.dotted",
            xpMultiplier: 0.75,
            category: "Cognitive Techniques",
            subcategory: "Understanding & Reasoning",
            effectivenessRating: 7
        ))
        
        techniques.append(Technique(
            name: "Concept Mapping",
            techniqueDescription: "Show labeled relationships.",
            iconName: "network",
            xpMultiplier: 0.75,
            category: "Cognitive Techniques",
            subcategory: "Understanding & Reasoning",
            effectivenessRating: 7
        ))
        
        // ⭐ 2. Note-Taking Techniques
        // 2.1 Structured Notes
        techniques.append(Technique(
            name: "Cornell Notes",
            techniqueDescription: "Notes with cues and summary.",
            iconName: "note.text",
            xpMultiplier: 0.75,
            category: "Note-Taking Techniques",
            subcategory: "Structured Notes",
            effectivenessRating: 7
        ))
        
        techniques.append(Technique(
            name: "Outline Method",
            techniqueDescription: "Organized bullet hierarchy.",
            iconName: "list.bullet.indent",
            xpMultiplier: 0.75,
            category: "Note-Taking Techniques",
            subcategory: "Structured Notes",
            effectivenessRating: 7
        ))
        
        techniques.append(Technique(
            name: "Charting Method",
            techniqueDescription: "Use tables to compare info.",
            iconName: "tablecells",
            xpMultiplier: 0.65,
            category: "Note-Taking Techniques",
            subcategory: "Structured Notes",
            effectivenessRating: 6
        ))
        
        techniques.append(Technique(
            name: "Sentence Method",
            techniqueDescription: "Write each point as a sentence.",
            iconName: "text.alignleft",
            xpMultiplier: 0.45,
            category: "Note-Taking Techniques",
            subcategory: "Structured Notes",
            effectivenessRating: 4
        ))
        
        // 2.2 Visual / Flow Notes
        techniques.append(Technique(
            name: "Mapping",
            techniqueDescription: "Branching idea diagrams.",
            iconName: "arrow.triangle.branch",
            xpMultiplier: 0.75,
            category: "Note-Taking Techniques",
            subcategory: "Visual / Flow Notes",
            effectivenessRating: 7
        ))
        
        techniques.append(Technique(
            name: "Flow Notes",
            techniqueDescription: "Freeform, connected notes.",
            iconName: "scribble.variable",
            xpMultiplier: 0.55,
            category: "Note-Taking Techniques",
            subcategory: "Visual / Flow Notes",
            effectivenessRating: 5
        ))
        
        techniques.append(Technique(
            name: "Mind Maps",
            techniqueDescription: "Center topic with branching ideas.",
            iconName: "circle.hexagonpath",
            xpMultiplier: 0.75,
            category: "Note-Taking Techniques",
            subcategory: "Visual / Flow Notes",
            effectivenessRating: 7
        ))
        
        // 2.3 Digital Notes
        techniques.append(Technique(
            name: "Zettelkasten",
            techniqueDescription: "Small linked idea notes.",
            iconName: "square.grid.3x3.fill.square",
            xpMultiplier: 0.75,
            category: "Note-Taking Techniques",
            subcategory: "Digital Notes",
            effectivenessRating: 7
        ))
        
        techniques.append(Technique(
            name: "Digital Annotation",
            techniqueDescription: "Highlight and comment on text.",
            iconName: "highlighter",
            xpMultiplier: 0.55,
            category: "Note-Taking Techniques",
            subcategory: "Digital Notes",
            effectivenessRating: 5
        ))
        
        techniques.append(Technique(
            name: "Highlighting",
            techniqueDescription: "Mark text for quick review.",
            iconName: "paintbrush.pointed",
            xpMultiplier: 0.35,
            category: "Note-Taking Techniques",
            subcategory: "Digital Notes",
            effectivenessRating: 3
        ))
        
        // ⭐ 3. Reading & Comprehension
        // 3.1 Reading Frameworks
        techniques.append(Technique(
            name: "SQ3R",
            techniqueDescription: "Structured read-and-review steps.",
            iconName: "book.pages",
            xpMultiplier: 0.75,
            category: "Reading & Comprehension",
            subcategory: "Reading Frameworks",
            effectivenessRating: 7
        ))
        
        techniques.append(Technique(
            name: "PQ4R",
            techniqueDescription: "Preview, question, read, reflect.",
            iconName: "book.pages.fill",
            xpMultiplier: 0.75,
            category: "Reading & Comprehension",
            subcategory: "Reading Frameworks",
            effectivenessRating: 7
        ))
        
        // 3.2 Reading Strategies
        techniques.append(Technique(
            name: "Skimming",
            techniqueDescription: "Read quickly for main ideas.",
            iconName: "timer",
            xpMultiplier: 0.65,
            category: "Reading & Comprehension",
            subcategory: "Reading Strategies",
            effectivenessRating: 6
        ))
        
        techniques.append(Technique(
            name: "Scanning",
            techniqueDescription: "Search for specific info.",
            iconName: "magnifyingglass",
            xpMultiplier: 0.65,
            category: "Reading & Comprehension",
            subcategory: "Reading Strategies",
            effectivenessRating: 6
        ))
        
        techniques.append(Technique(
            name: "Close Reading",
            techniqueDescription: "Analyze text carefully.",
            iconName: "text.magnifyingglass",
            xpMultiplier: 0.75,
            category: "Reading & Comprehension",
            subcategory: "Reading Strategies",
            effectivenessRating: 7
        ))
        
        techniques.append(Technique(
            name: "Intensive Reading",
            techniqueDescription: "Deep focus on small texts.",
            iconName: "book.closed",
            xpMultiplier: 0.65,
            category: "Reading & Comprehension",
            subcategory: "Reading Strategies",
            effectivenessRating: 6
        ))
        
        techniques.append(Technique(
            name: "Extensive Reading",
            techniqueDescription: "Read a lot for fluency.",
            iconName: "books.vertical",
            xpMultiplier: 0.65,
            category: "Reading & Comprehension",
            subcategory: "Reading Strategies",
            effectivenessRating: 6
        ))
        
        // 3.3 Pre-/Post-Reading
        techniques.append(Technique(
            name: "Pre-Reading",
            techniqueDescription: "Preview headings and terms.",
            iconName: "eye.trianglebadge.exclamationmark",
            xpMultiplier: 0.75,
            category: "Reading & Comprehension",
            subcategory: "Pre-/Post-Reading",
            effectivenessRating: 7
        ))
        
        techniques.append(Technique(
            name: "Guided Questions",
            techniqueDescription: "Answer questions as you read.",
            iconName: "questionmark.app",
            xpMultiplier: 0.95,
            category: "Reading & Comprehension",
            subcategory: "Pre-/Post-Reading",
            effectivenessRating: 9
        ))
        
        techniques.append(Technique(
            name: "Re-Reading",
            techniqueDescription: "Read again for familiarity.",
            iconName: "arrow.counterclockwise",
            xpMultiplier: 0.45,
            category: "Reading & Comprehension",
            subcategory: "Pre-/Post-Reading",
            effectivenessRating: 4
        ))
        
        techniques.append(Technique(
            name: "Summarizing",
            techniqueDescription: "Restate the text concisely.",
            iconName: "doc.text",
            xpMultiplier: 0.95,
            category: "Reading & Comprehension",
            subcategory: "Pre-/Post-Reading",
            effectivenessRating: 9
        ))
        
        // ⭐ 4. Practice-Based Learning
        // 4.1 Problem-Based Practice
        techniques.append(Technique(
            name: "Practice Problems",
            techniqueDescription: "Solve problems repeatedly.",
            iconName: "function",
            xpMultiplier: 1.0,
            category: "Practice-Based Learning",
            subcategory: "Problem-Based Practice",
            effectivenessRating: 10
        ))
        
        techniques.append(Technique(
            name: "Drill Sets",
            techniqueDescription: "Repeat similar problems.",
            iconName: "repeat",
            xpMultiplier: 0.75,
            category: "Practice-Based Learning",
            subcategory: "Problem-Based Practice",
            effectivenessRating: 7
        ))
        
        techniques.append(Technique(
            name: "Past Papers",
            techniqueDescription: "Do previous exams.",
            iconName: "doc.on.doc",
            xpMultiplier: 1.0,
            category: "Practice-Based Learning",
            subcategory: "Problem-Based Practice",
            effectivenessRating: 10
        ))
        
        techniques.append(Technique(
            name: "Exam Simulation",
            techniqueDescription: "Practice under test conditions.",
            iconName: "clock.badge.checkmark",
            xpMultiplier: 1.0,
            category: "Practice-Based Learning",
            subcategory: "Problem-Based Practice",
            effectivenessRating: 10
        ))
        
        // 4.2 Active Production
        techniques.append(Technique(
            name: "Writing Practice",
            techniqueDescription: "Learn by writing content.",
            iconName: "pencil.and.paper",
            xpMultiplier: 0.95,
            category: "Practice-Based Learning",
            subcategory: "Active Production",
            effectivenessRating: 9
        ))
        
        techniques.append(Technique(
            name: "Essay Drills",
            techniqueDescription: "Practice quick essay plans.",
            iconName: "doc.richtext",
            xpMultiplier: 0.75,
            category: "Practice-Based Learning",
            subcategory: "Active Production",
            effectivenessRating: 7
        ))
        
        techniques.append(Technique(
            name: "Coding Challenges",
            techniqueDescription: "Solve coding tasks.",
            iconName: "chevron.left.forwardslash.chevron.right",
            xpMultiplier: 0.95,
            category: "Practice-Based Learning",
            subcategory: "Active Production",
            effectivenessRating: 9
        ))
        
        techniques.append(Technique(
            name: "Error Analysis",
            techniqueDescription: "Review and fix mistakes.",
            iconName: "exclamationmark.triangle",
            xpMultiplier: 0.95,
            category: "Practice-Based Learning",
            subcategory: "Error Analysis",
            effectivenessRating: 9
        ))
        
        // 4.3 Language Skills
        techniques.append(Technique(
            name: "Shadowing",
            techniqueDescription: "Repeat native speech.",
            iconName: "waveform",
            xpMultiplier: 0.95,
            category: "Practice-Based Learning",
            subcategory: "Language Skills",
            effectivenessRating: 9
        ))
        
        techniques.append(Technique(
            name: "Dictation",
            techniqueDescription: "Write what you hear.",
            iconName: "ear",
            xpMultiplier: 0.75,
            category: "Practice-Based Learning",
            subcategory: "Language Skills",
            effectivenessRating: 7
        ))
        
        techniques.append(Technique(
            name: "Pronunciation Drills",
            techniqueDescription: "Practice key sounds.",
            iconName: "mic",
            xpMultiplier: 0.75,
            category: "Practice-Based Learning",
            subcategory: "Language Skills",
            effectivenessRating: 7
        ))
        
        techniques.append(Technique(
            name: "Listening Practice",
            techniqueDescription: "Train comprehension.",
            iconName: "headphones",
            xpMultiplier: 0.75,
            category: "Practice-Based Learning",
            subcategory: "Language Skills",
            effectivenessRating: 7
        ))
        
        // ⭐ 5. Output & Teaching
        // 5.1 Teaching Methods
        techniques.append(Technique(
            name: "Teach Others",
            techniqueDescription: "Explain to learn better.",
            iconName: "person.2",
            xpMultiplier: 1.0,
            category: "Output & Teaching",
            subcategory: "Teaching Methods",
            effectivenessRating: 10
        ))
        
        techniques.append(Technique(
            name: "Peer Instruction",
            techniqueDescription: "Discuss concepts together.",
            iconName: "person.3",
            xpMultiplier: 0.95,
            category: "Output & Teaching",
            subcategory: "Teaching Methods",
            effectivenessRating: 9
        ))
        
        techniques.append(Technique(
            name: "Study Groups",
            techniqueDescription: "Learn collaboratively.",
            iconName: "person.3.fill",
            xpMultiplier: 0.75,
            category: "Output & Teaching",
            subcategory: "Teaching Methods",
            effectivenessRating: 7
        ))
        
        // 5.2 Output Generation
        techniques.append(Technique(
            name: "Presentations",
            techniqueDescription: "Explain topics verbally.",
            iconName: "rectangle.on.rectangle.angled",
            xpMultiplier: 0.75,
            category: "Output & Teaching",
            subcategory: "Output Generation",
            effectivenessRating: 7
        ))
        
        techniques.append(Technique(
            name: "Summaries",
            techniqueDescription: "Condense info clearly.",
            iconName: "doc.plaintext",
            xpMultiplier: 0.95,
            category: "Output & Teaching",
            subcategory: "Output Generation",
            effectivenessRating: 9
        ))
        
        techniques.append(Technique(
            name: "Peer Review",
            techniqueDescription: "Evaluate others' work.",
            iconName: "checkmark.seal",
            xpMultiplier: 0.75,
            category: "Output & Teaching",
            subcategory: "Output Generation",
            effectivenessRating: 7
        ))
        
        techniques.append(Technique(
            name: "Discussions",
            techniqueDescription: "Learn by talking ideas out.",
            iconName: "bubble.left.and.bubble.right.fill",
            xpMultiplier: 0.75,
            category: "Output & Teaching",
            subcategory: "Output Generation",
            effectivenessRating: 7
        ))
        
        // ⭐ 6. Planning & Productivity
        // 6.1 Time Management
        techniques.append(Technique(
            name: "Pomodoro",
            techniqueDescription: "Timed focus intervals.",
            iconName: "timer.circle",
            xpMultiplier: 0.75,
            category: "Planning & Productivity",
            subcategory: "Time Management",
            effectivenessRating: 7
        ))
        
        techniques.append(Technique(
            name: "Time Blocking",
            techniqueDescription: "Assign tasks to calendar blocks.",
            iconName: "calendar",
            xpMultiplier: 0.75,
            category: "Planning & Productivity",
            subcategory: "Time Management",
            effectivenessRating: 7
        ))
        
        techniques.append(Technique(
            name: "Task Batching",
            techniqueDescription: "Group similar tasks.",
            iconName: "square.stack.3d.up",
            xpMultiplier: 0.65,
            category: "Planning & Productivity",
            subcategory: "Time Management",
            effectivenessRating: 6
        ))
        
        techniques.append(Technique(
            name: "Sprints",
            techniqueDescription: "Short bursts of focused work.",
            iconName: "bolt.fill",
            xpMultiplier: 0.65,
            category: "Planning & Productivity",
            subcategory: "Time Management",
            effectivenessRating: 6
        ))
        
        // 6.2 Goals & Task Planning
        techniques.append(Technique(
            name: "SMART Goals",
            techniqueDescription: "Set clear, measurable goals.",
            iconName: "target",
            xpMultiplier: 0.65,
            category: "Planning & Productivity",
            subcategory: "Goals & Task Planning",
            effectivenessRating: 6
        ))
        
        techniques.append(Technique(
            name: "OKRs",
            techniqueDescription: "Set goals with key results.",
            iconName: "chart.bar.doc.horizontal",
            xpMultiplier: 0.65,
            category: "Planning & Productivity",
            subcategory: "Goals & Task Planning",
            effectivenessRating: 6
        ))
        
        techniques.append(Technique(
            name: "Reverse Planning",
            techniqueDescription: "Plan backward from deadline.",
            iconName: "arrow.uturn.backward",
            xpMultiplier: 0.75,
            category: "Planning & Productivity",
            subcategory: "Goals & Task Planning",
            effectivenessRating: 7
        ))
        
        techniques.append(Technique(
            name: "Checklists",
            techniqueDescription: "Mark items as completed.",
            iconName: "checklist",
            xpMultiplier: 0.55,
            category: "Planning & Productivity",
            subcategory: "Goals & Task Planning",
            effectivenessRating: 5
        ))
        
        // 6.3 Scheduling & Tracking
        techniques.append(Technique(
            name: "Study Schedules",
            techniqueDescription: "Plan study times.",
            iconName: "calendar.badge.clock",
            xpMultiplier: 0.75,
            category: "Planning & Productivity",
            subcategory: "Scheduling & Tracking",
            effectivenessRating: 7
        ))
        
        techniques.append(Technique(
            name: "Habit Tracking",
            techniqueDescription: "Track consistency.",
            iconName: "chart.line.uptrend.xyaxis",
            xpMultiplier: 0.65,
            category: "Planning & Productivity",
            subcategory: "Scheduling & Tracking",
            effectivenessRating: 6
        ))
        
        techniques.append(Technique(
            name: "Priority Matrix",
            techniqueDescription: "Sort tasks by importance.",
            iconName: "square.grid.2x2",
            xpMultiplier: 0.75,
            category: "Planning & Productivity",
            subcategory: "Scheduling & Tracking",
            effectivenessRating: 7
        ))
        
        // ⭐ 7. Environmental & Behavioral
        // 7.1 Environment
        techniques.append(Technique(
            name: "Quiet Space",
            techniqueDescription: "Reduce distractions.",
            iconName: "speaker.slash",
            xpMultiplier: 0.75,
            category: "Environmental & Behavioral",
            subcategory: "Environment",
            effectivenessRating: 7
        ))
        
        techniques.append(Technique(
            name: "Library",
            techniqueDescription: "Structured quiet environment.",
            iconName: "building.columns",
            xpMultiplier: 0.75,
            category: "Environmental & Behavioral",
            subcategory: "Environment",
            effectivenessRating: 7
        ))
        
        techniques.append(Technique(
            name: "Café",
            techniqueDescription: "Light noise for relaxed focus.",
            iconName: "cup.and.saucer",
            xpMultiplier: 0.55,
            category: "Environmental & Behavioral",
            subcategory: "Environment",
            effectivenessRating: 5
        ))
        
        techniques.append(Technique(
            name: "Standing Desk",
            techniqueDescription: "Stand while studying.",
            iconName: "figure.stand",
            xpMultiplier: 0.35,
            category: "Environmental & Behavioral",
            subcategory: "Environment",
            effectivenessRating: 3
        ))
        
        // 7.2 Distraction Control
        techniques.append(Technique(
            name: "Blocker Apps",
            techniqueDescription: "Block distracting sites.",
            iconName: "hand.raised.slash",
            xpMultiplier: 0.95,
            category: "Environmental & Behavioral",
            subcategory: "Distraction Control",
            effectivenessRating: 9
        ))
        
        techniques.append(Technique(
            name: "Phone-Free",
            techniqueDescription: "Remove phone temptations.",
            iconName: "iphone.slash",
            xpMultiplier: 0.95,
            category: "Environmental & Behavioral",
            subcategory: "Distraction Control",
            effectivenessRating: 9
        ))
        
        techniques.append(Technique(
            name: "Deep Work",
            techniqueDescription: "Long, focused sessions.",
            iconName: "brain",
            xpMultiplier: 0.85,
            category: "Environmental & Behavioral",
            subcategory: "Distraction Control",
            effectivenessRating: 8
        ))
        
        // 7.3 Physical Methods
        techniques.append(Technique(
            name: "Recall Walks",
            techniqueDescription: "Review while walking.",
            iconName: "figure.walk",
            xpMultiplier: 0.75,
            category: "Environmental & Behavioral",
            subcategory: "Physical Methods",
            effectivenessRating: 7
        ))
        
        techniques.append(Technique(
            name: "White Noise",
            techniqueDescription: "Mask background sounds.",
            iconName: "waveform.circle",
            xpMultiplier: 0.55,
            category: "Environmental & Behavioral",
            subcategory: "Physical Methods",
            effectivenessRating: 5
        ))
        
        // ⭐ 8. Tech-Assisted
        // 8.1 SRS Tools
        techniques.append(Technique(
            name: "Anki",
            techniqueDescription: "Automated spaced repetition.",
            iconName: "rectangle.stack.badge.play",
            xpMultiplier: 1.0,
            category: "Tech-Assisted",
            subcategory: "SRS Tools",
            effectivenessRating: 10
        ))
        
        techniques.append(Technique(
            name: "SRS Apps",
            techniqueDescription: "App-based spaced review.",
            iconName: "apps.iphone",
            xpMultiplier: 1.0,
            category: "Tech-Assisted",
            subcategory: "SRS Tools",
            effectivenessRating: 10
        ))
        
        // 8.2 Digital Notes
        techniques.append(Technique(
            name: "Obsidian",
            techniqueDescription: "Linked digital notes.",
            iconName: "link.circle",
            xpMultiplier: 0.75,
            category: "Tech-Assisted",
            subcategory: "Digital Notes",
            effectivenessRating: 7
        ))
        
        techniques.append(Technique(
            name: "Notion",
            techniqueDescription: "Organized digital workspace.",
            iconName: "square.grid.3x3",
            xpMultiplier: 0.65,
            category: "Tech-Assisted",
            subcategory: "Digital Notes",
            effectivenessRating: 6
        ))
        
        techniques.append(Technique(
            name: "Roam",
            techniqueDescription: "Networked thought notes.",
            iconName: "circle.grid.cross",
            xpMultiplier: 0.75,
            category: "Tech-Assisted",
            subcategory: "Digital Notes",
            effectivenessRating: 7
        ))
        
        // 8.3 Online Learning
        techniques.append(Technique(
            name: "MOOCs",
            techniqueDescription: "Structured online lessons.",
            iconName: "play.rectangle.on.rectangle",
            xpMultiplier: 0.75,
            category: "Tech-Assisted",
            subcategory: "Online Learning",
            effectivenessRating: 7
        ))
        
        techniques.append(Technique(
            name: "Lecture Review",
            techniqueDescription: "Rewatch class recordings.",
            iconName: "play.circle",
            xpMultiplier: 0.65,
            category: "Tech-Assisted",
            subcategory: "Online Learning",
            effectivenessRating: 6
        ))
        
        techniques.append(Technique(
            name: "Auto Quizzes",
            techniqueDescription: "Quick understanding checks.",
            iconName: "questionmark.square",
            xpMultiplier: 0.65,
            category: "Tech-Assisted",
            subcategory: "Online Learning",
            effectivenessRating: 6
        ))
        
        techniques.append(Technique(
            name: "AI Study",
            techniqueDescription: "Use AI for help and quizzes.",
            iconName: "sparkles",
            xpMultiplier: 0.85,
            category: "Tech-Assisted",
            subcategory: "Online Learning",
            effectivenessRating: 8
        ))
        
        techniques.append(Technique(
            name: "Captions/Transcripts",
            techniqueDescription: "Read along for clarity.",
            iconName: "captions.bubble",
            xpMultiplier: 0.75,
            category: "Tech-Assisted",
            subcategory: "Online Learning",
            effectivenessRating: 7
        ))
        
        // ⭐ 9. Subject-Specific Techniques
        // 9.1 Math & Science
        techniques.append(Technique(
            name: "Worked Examples",
            techniqueDescription: "Study solved problems.",
            iconName: "equal.square",
            xpMultiplier: 1.0,
            category: "Subject-Specific Techniques",
            subcategory: "Math & Science",
            effectivenessRating: 10
        ))
        
        techniques.append(Technique(
            name: "Formula Sheets",
            techniqueDescription: "Review key formulas.",
            iconName: "f.cursive",
            xpMultiplier: 0.55,
            category: "Subject-Specific Techniques",
            subcategory: "Math & Science",
            effectivenessRating: 5
        ))
        
        techniques.append(Technique(
            name: "Dimensional Analysis",
            techniqueDescription: "Use units to verify work.",
            iconName: "scalemass",
            xpMultiplier: 0.95,
            category: "Subject-Specific Techniques",
            subcategory: "Math & Science",
            effectivenessRating: 9
        ))
        
        techniques.append(Technique(
            name: "Derivation Practice",
            techniqueDescription: "Rebuild formulas manually.",
            iconName: "arrow.right.arrow.left",
            xpMultiplier: 0.95,
            category: "Subject-Specific Techniques",
            subcategory: "Math & Science",
            effectivenessRating: 9
        ))
        
        // 9.2 Language Learning
        techniques.append(Technique(
            name: "Immersion",
            techniqueDescription: "Surround yourself with language.",
            iconName: "globe",
            xpMultiplier: 1.0,
            category: "Subject-Specific Techniques",
            subcategory: "Language Learning",
            effectivenessRating: 10
        ))
        
        techniques.append(Technique(
            name: "Vocab Lists",
            techniqueDescription: "Memorize word lists.",
            iconName: "list.bullet.rectangle",
            xpMultiplier: 0.65,
            category: "Subject-Specific Techniques",
            subcategory: "Language Learning",
            effectivenessRating: 6
        ))
        
        techniques.append(Technique(
            name: "Grammar Drills",
            techniqueDescription: "Practice grammar rules.",
            iconName: "textformat",
            xpMultiplier: 0.65,
            category: "Subject-Specific Techniques",
            subcategory: "Language Learning",
            effectivenessRating: 6
        ))
        
        techniques.append(Technique(
            name: "Language Exchange",
            techniqueDescription: "Talk with native speakers.",
            iconName: "person.2.wave.2",
            xpMultiplier: 0.95,
            category: "Subject-Specific Techniques",
            subcategory: "Language Learning",
            effectivenessRating: 9
        ))
        
        techniques.append(Technique(
            name: "Reading Aloud",
            techniqueDescription: "Improve fluency by reading out.",
            iconName: "text.bubble",
            xpMultiplier: 0.75,
            category: "Subject-Specific Techniques",
            subcategory: "Language Learning",
            effectivenessRating: 7
        ))
        
        techniques.append(Technique(
            name: "Translation",
            techniqueDescription: "Convert between languages.",
            iconName: "arrow.left.arrow.right",
            xpMultiplier: 0.75,
            category: "Subject-Specific Techniques",
            subcategory: "Language Learning",
            effectivenessRating: 7
        ))
        
        // 9.3 Programming
        techniques.append(Technique(
            name: "Pair Programming",
            techniqueDescription: "Code with a partner.",
            iconName: "person.2.gobackward",
            xpMultiplier: 0.85,
            category: "Subject-Specific Techniques",
            subcategory: "Programming",
            effectivenessRating: 8
        ))
        
        techniques.append(Technique(
            name: "Code-Along",
            techniqueDescription: "Follow tutorials step-by-step.",
            iconName: "play.laptopcomputer",
            xpMultiplier: 0.65,
            category: "Subject-Specific Techniques",
            subcategory: "Programming",
            effectivenessRating: 6
        ))
        
        techniques.append(Technique(
            name: "Rewrite from Memory",
            techniqueDescription: "Recreate code by recall.",
            iconName: "arrow.clockwise.circle",
            xpMultiplier: 0.95,
            category: "Subject-Specific Techniques",
            subcategory: "Programming",
            effectivenessRating: 9
        ))
        
        techniques.append(Technique(
            name: "Mini-Projects",
            techniqueDescription: "Build small real projects.",
            iconName: "hammer",
            xpMultiplier: 0.95,
            category: "Subject-Specific Techniques",
            subcategory: "Programming",
            effectivenessRating: 9
        ))
        
        // 9.4 Humanities
        techniques.append(Technique(
            name: "Source Analysis",
            techniqueDescription: "Evaluate sources critically.",
            iconName: "doc.text.magnifyingglass",
            xpMultiplier: 0.95,
            category: "Subject-Specific Techniques",
            subcategory: "Humanities",
            effectivenessRating: 9
        ))
        
        techniques.append(Technique(
            name: "Case Studies",
            techniqueDescription: "Apply concepts to examples.",
            iconName: "briefcase",
            xpMultiplier: 0.95,
            category: "Subject-Specific Techniques",
            subcategory: "Humanities",
            effectivenessRating: 9
        ))
        
        techniques.append(Technique(
            name: "Thesis Mapping",
            techniqueDescription: "Outline argument structure.",
            iconName: "map.fill",
            xpMultiplier: 0.75,
            category: "Subject-Specific Techniques",
            subcategory: "Humanities",
            effectivenessRating: 7
        ))
        
        techniques.append(Technique(
            name: "Timelining",
            techniqueDescription: "Sequence events visually.",
            iconName: "timeline.selection",
            xpMultiplier: 0.75,
            category: "Subject-Specific Techniques",
            subcategory: "Humanities",
            effectivenessRating: 7
        ))
        
        techniques.append(Technique(
            name: "Debate Practice",
            techniqueDescription: "Defend ideas verbally.",
            iconName: "person.2.badge.gearshape",
            xpMultiplier: 0.75,
            category: "Subject-Specific Techniques",
            subcategory: "Humanities",
            effectivenessRating: 7
        ))
        
        // ⭐ 10. Metacognitive
        // Self-Assessment
        techniques.append(Technique(
            name: "Mistake Log",
            techniqueDescription: "Track and fix errors.",
            iconName: "exclamationmark.square",
            xpMultiplier: 0.95,
            category: "Metacognitive",
            subcategory: "Self-Assessment",
            effectivenessRating: 9
        ))
        
        techniques.append(Technique(
            name: "Confidence Rating",
            techniqueDescription: "Rate certainty per topic.",
            iconName: "chart.bar",
            xpMultiplier: 0.65,
            category: "Metacognitive",
            subcategory: "Self-Assessment",
            effectivenessRating: 6
        ))
        
        techniques.append(Technique(
            name: "KWL",
            techniqueDescription: "Note what you know and learn.",
            iconName: "list.bullet.clipboard",
            xpMultiplier: 0.65,
            category: "Metacognitive",
            subcategory: "Self-Assessment",
            effectivenessRating: 6
        ))
        
        // Reflection
        techniques.append(Technique(
            name: "Study Journal",
            techniqueDescription: "Reflect on study sessions.",
            iconName: "book.closed.fill",
            xpMultiplier: 0.65,
            category: "Metacognitive",
            subcategory: "Reflection",
            effectivenessRating: 6
        ))
        
        techniques.append(Technique(
            name: "Weekly Review",
            techniqueDescription: "Review the week's learning.",
            iconName: "calendar.circle",
            xpMultiplier: 0.95,
            category: "Metacognitive",
            subcategory: "Reflection",
            effectivenessRating: 9
        ))
        
        techniques.append(Technique(
            name: "Progress Review",
            techniqueDescription: "Compare goals vs results.",
            iconName: "chart.line.uptrend.xyaxis.circle",
            xpMultiplier: 0.95,
            category: "Metacognitive",
            subcategory: "Reflection",
            effectivenessRating: 9
        ))
        
        // ⭐ 11. Motivation & Mindset
        // Behavioral
        techniques.append(Technique(
            name: "Rewards",
            techniqueDescription: "Incentivize study.",
            iconName: "gift",
            xpMultiplier: 0.55,
            category: "Motivation & Mindset",
            subcategory: "Behavioral",
            effectivenessRating: 5
        ))
        
        techniques.append(Technique(
            name: "Streaks",
            techniqueDescription: "Track consecutive days.",
            iconName: "flame",
            xpMultiplier: 0.65,
            category: "Motivation & Mindset",
            subcategory: "Behavioral",
            effectivenessRating: 6
        ))
        
        techniques.append(Technique(
            name: "Gamification",
            techniqueDescription: "Add game-like motivation.",
            iconName: "gamecontroller",
            xpMultiplier: 0.65,
            category: "Motivation & Mindset",
            subcategory: "Behavioral",
            effectivenessRating: 6
        ))
        
        // Psychological
        techniques.append(Technique(
            name: "Self-Talk",
            techniqueDescription: "Encourage yourself mentally.",
            iconName: "bubble.left",
            xpMultiplier: 0.45,
            category: "Motivation & Mindset",
            subcategory: "Psychological",
            effectivenessRating: 4
        ))
        
        techniques.append(Technique(
            name: "Visualization",
            techniqueDescription: "Picture success outcomes.",
            iconName: "eye.fill",
            xpMultiplier: 0.45,
            category: "Motivation & Mindset",
            subcategory: "Psychological",
            effectivenessRating: 4
        ))
        
        techniques.append(Technique(
            name: "Accountability",
            techniqueDescription: "Share goals with someone.",
            iconName: "person.crop.circle.badge.checkmark",
            xpMultiplier: 0.75,
            category: "Motivation & Mindset",
            subcategory: "Psychological",
            effectivenessRating: 7
        ))
        
        // ⭐ 12. Exam Preparation
        // Practice
        techniques.append(Technique(
            name: "Timed Practice",
            techniqueDescription: "Work under timers.",
            iconName: "stopwatch",
            xpMultiplier: 1.0,
            category: "Exam Preparation",
            subcategory: "Practice",
            effectivenessRating: 10
        ))
        
        techniques.append(Technique(
            name: "Exam Simulation",
            techniqueDescription: "Mimic real exam setup.",
            iconName: "doc.badge.clock",
            xpMultiplier: 1.0,
            category: "Exam Preparation",
            subcategory: "Practice",
            effectivenessRating: 10
        ))
        
        techniques.append(Technique(
            name: "Open Book Practice",
            techniqueDescription: "Use notes while practicing.",
            iconName: "book.pages.fill",
            xpMultiplier: 0.65,
            category: "Exam Preparation",
            subcategory: "Practice",
            effectivenessRating: 6
        ))
        
        // Review
        techniques.append(Technique(
            name: "High-Yield Review",
            techniqueDescription: "Focus on key test facts.",
            iconName: "star.circle",
            xpMultiplier: 0.75,
            category: "Exam Preparation",
            subcategory: "Review",
            effectivenessRating: 7
        ))
        
        techniques.append(Technique(
            name: "Formula Memorization",
            techniqueDescription: "Commit formulas to memory.",
            iconName: "x.squareroot",
            xpMultiplier: 0.55,
            category: "Exam Preparation",
            subcategory: "Review",
            effectivenessRating: 5
        ))
        
        techniques.append(Technique(
            name: "Priority Targeting",
            techniqueDescription: "Focus on high-impact topics.",
            iconName: "scope",
            xpMultiplier: 0.95,
            category: "Exam Preparation",
            subcategory: "Review",
            effectivenessRating: 9
        ))
        
        return techniques
    }
}
