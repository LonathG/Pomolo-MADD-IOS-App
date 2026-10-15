import SwiftUI
import CoreData
import Combine

public enum InboxFilterTab: String, CaseIterable, Identifiable {
    case all = "All"
    case unsorted = "Unsorted"
    case today = "Today"
    
    public var id: String { rawValue }
}

@MainActor
public final class TaskViewModel: ObservableObject {
    @Published public var allTasks: [TaskItem] = []
    @Published public var selectedFilter: InboxFilterTab = .unsorted
    @Published public var quickAddText: String = ""
    @Published public var isAutoSorting: Bool = false
    
    private let coreDataManager = CoreDataManager.shared
    
    public init() {
        fetchAll()
    }
    
    public func fetchAll() {
        allTasks = coreDataManager.fetchAllTasks()
    }
    
    public var filteredTasks: [TaskItem] {
        switch selectedFilter {
        case .all:
            return allTasks
        case .unsorted:
            return allTasks.filter { $0.quadrant == .inbox }
        case .today:
            return allTasks.filter {
                guard let due = $0.dueDate else { return false }
                return Calendar.current.isDateInToday(due)
            }
        }
    }
    
    public var unsortedCount: Int {
        allTasks.filter { $0.quadrant == .inbox }.count
    }
    
    public func quickAddTask() {
        let trimmed = quickAddText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        let tag = extractTag(from: trimmed)
        _ = coreDataManager.createTask(
            title: trimmed,
            details: nil,
            tag: tag,
            quadrant: .inbox,
            estimatedMinutes: 25,
            dueDate: Date()
        )
        quickAddText = ""
        fetchAll()
    }
    
    public func toggleCompletion(task: TaskItem) {
        coreDataManager.toggleTaskCompletion(task: task)
        fetchAll()
    }
    
    public func deleteTask(task: TaskItem) {
        coreDataManager.deleteTask(task: task)
        fetchAll()
    }
    
    public func assignTask(_ task: TaskItem, to quadrant: MatrixQuadrant) {
        coreDataManager.updateTaskQuadrant(task: task, to: quadrant)
        fetchAll()
    }
    
    public func autoSortInboxTasks() {
        isAutoSorting = true
        let unsorted = allTasks.filter { $0.quadrant == .inbox }
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
            for task in unsorted {
                let targetQuadrant = Self.determineQuadrant(
                    title: task.wrappedTitle,
                    details: task.taskDescription,
                    tag: task.tag,
                    estimatedMinutes: Int(task.estimatedMinutes),
                    dueDate: task.dueDate,
                    isFrog: task.isFrog
                )
                coreDataManager.updateTaskQuadrant(task: task, to: targetQuadrant)
            }
            coreDataManager.save()
            fetchAll()
            isAutoSorting = false
        }
    }
    
    /// Determines the appropriate Eisenhower Matrix quadrant based on comprehensive semantic heuristics
    public static func determineQuadrant(
        title: String,
        details: String? = nil,
        tag: String? = nil,
        estimatedMinutes: Int = 25,
        dueDate: Date? = nil,
        isFrog: Bool = false
    ) -> MatrixQuadrant {
        let combined = "\(title) \(details ?? "")".lowercased()
        let tagLower = (tag ?? "").lowercased()
        
        // 1. Q1 DO FIRST (Urgent & Important)
        // Crises, emergencies, severe bugs, immediate deadlines, blocker issues
        let q1Keywords = [
            "p0", "p1", "critical", "urgent", "emergency", "crisis", "blocker",
            "hotfix", "outage", "downtime", "crash", "bug", "leak", "memory leak",
            "vulnerability", "exploit", "broken", "severe", "incident", "deadline",
            "immediate", "asap", "tax audit", "compliance audit", "submission",
            "app store review", "store rejection", "prod issue", "production issue",
            "escalation", "overdue", "fix immediately", "data corruption", "down"
        ]
        
        var q1Score: Double = 0.0
        for kw in q1Keywords {
            if combined.contains(kw) {
                q1Score += 4.0
            }
        }
        if tagLower == "release" || tagLower == "security" || tagLower == "hotfix" {
            q1Score += 3.0
        }
        if let due = dueDate, Calendar.current.isDateInToday(due) || due < Date() {
            q1Score += 2.5
        }
        
        // 2. Q2 SCHEDULE (Important, Not Urgent)
        // High leverage, strategic planning, architecture, design systems, research, deep focus
        let q2Keywords = [
            "strategy", "roadmap", "plan", "planning", "schedule", "proposal", "spec",
            "vision", "milestone", "okr", "goal", "quarterly", "deep focus", "deep work",
            "initiative", "architecture", "design", "figma", "wireframe", "prototype",
            "ux", "ui", "redesign", "tokens", "build", "develop", "implement", "create",
            "feature", "refactor", "codebase", "optimize", "engine", "research", "study",
            "learn", "synthesize", "interview", "analysis", "synthesis", "explore",
            "draft", "write", "documentation", "workout", "exercise", "investor", "pitch deck",
            "product strategy", "user research", "one-pager"
        ]
        
        var q2Score: Double = 0.0
        for kw in q2Keywords {
            if combined.contains(kw) {
                q2Score += 3.5
            }
        }
        if tagLower == "strategy" || tagLower == "design" || tagLower == "research" || tagLower == "product" {
            q2Score += 3.0
        }
        if tagLower == "dev" && q1Score < 4.0 {
            q2Score += 2.0
        }
        if estimatedMinutes >= 45 {
            q2Score += 2.0
        }
        if isFrog {
            q2Score += 3.0
        }
        
        // 3. Q3 DELEGATE (Urgent, Not Important)
        // Hand-offs, assistants, bookings, routine administrative logistics, orders, inquiries
        let q3Keywords = [
            "delegate", "outsource", "hand off", "handoff", "assign to", "forward to",
            "ask assistant", "virtual assistant", "assistant", "book flight", "book hotel",
            "book table", "reserve", "order food", "order supplies", "catering",
            "venue shortlist", "courier", "print copies", "file expense", "expense report",
            "submit receipt", "invoice approval", "rsvp", "send reminder", "reschedule calendar",
            "transcribe", "coordinate time", "fill survey", "canned response", "dispatch",
            "errand", "buy groceries", "pick up laundry", "dry clean", "routine inquiry"
        ]
        
        var q3Score: Double = 0.0
        for kw in q3Keywords {
            if combined.contains(kw) {
                q3Score += 4.5
            }
        }
        if tagLower == "ops" || tagLower == "admin" || tagLower == "logistics" {
            if q1Score < 3.0 && q2Score < 3.0 {
                q3Score += 2.5
            }
        }
        if estimatedMinutes <= 15 && q2Score < 3.0 && q1Score < 3.0 {
            q3Score += 1.0
        }
        
        // 4. Q4 ELIMINATE (Neither Urgent nor Important)
        // Declutter, stale backlog, mindless browsing, low-value trivia, archiving
        let q4Keywords = [
            "eliminate", "drop", "delete", "archive", "declutter", "stale backlog",
            "deprecated", "unsubscribe", "casual browsing", "browse reddit", "youtube",
            "social media", "mindless", "trivia", "unimportant", "low priority",
            "p3", "p4", "nice to have", "someday", "maybe", "optional reading",
            "clear backlog", "clean downloads", "empty trash", "stale issues"
        ]
        
        var q4Score: Double = 0.0
        for kw in q4Keywords {
            if combined.contains(kw) {
                q4Score += 4.0
            }
        }
        if tagLower == "backlog" || tagLower == "archive" || tagLower == "declutter" {
            q4Score += 3.0
        }
        
        // Evaluate highest scoring quadrant
        let scores: [(MatrixQuadrant, Double)] = [
            (.q1, q1Score),
            (.q2, q2Score),
            (.q3, q3Score),
            (.q4, q4Score)
        ]
        
        if let maxEntry = scores.max(by: { $0.1 < $1.1 }), maxEntry.1 > 1.5 {
            return maxEntry.0
        }
        
        // Smart Default Fallback:
        // Proactive, high-leverage Eisenhower mindset:
        // If it's due today -> Q1 (Do First)
        // If it's a typical productive task -> Q2 (Schedule)
        // NEVER blindly dump tasks into Delegate or Trash!
        if let due = dueDate, Calendar.current.isDateInToday(due) {
            return .q1
        }
        return .q2
    }
    
    private func extractTag(from text: String) -> String {
        let lower = text.lowercased()
        if lower.contains("design") || lower.contains("figma") { return "Design" }
        if lower.contains("strategy") || lower.contains("product") { return "Strategy" }
        if lower.contains("dev") || lower.contains("code") || lower.contains("bug") { return "Dev" }
        if lower.contains("meet") || lower.contains("sync") || lower.contains("1:1") { return "Team" }
        if lower.contains("book") || lower.contains("order") || lower.contains("expense") { return "Ops" }
        if lower.contains("reply") || lower.contains("email") || lower.contains("inquiry") { return "Comms" }
        return "General"
    }
}
