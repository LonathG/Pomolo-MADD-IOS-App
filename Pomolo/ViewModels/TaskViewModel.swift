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
                let lower = task.wrappedTitle.lowercased()
                if lower.contains("p0") || lower.contains("bug") || lower.contains("leak") || lower.contains("urgent") || lower.contains("metadata") {
                    task.quadrant = .q1
                } else if lower.contains("strategy") || lower.contains("figma") || lower.contains("research") || lower.contains("architecture") {
                    task.quadrant = .q2
                } else if lower.contains("schedule") || lower.contains("sync") || lower.contains("reply") || lower.contains("inquiry") {
                    task.quadrant = .q3
                } else {
                    task.quadrant = .q4
                }
            }
            coreDataManager.save()
            fetchAll()
            isAutoSorting = false
        }
    }
    
    private func extractTag(from text: String) -> String {
        let lower = text.lowercased()
        if lower.contains("design") || lower.contains("figma") { return "Design" }
        if lower.contains("strategy") || lower.contains("product") { return "Strategy" }
        if lower.contains("dev") || lower.contains("code") || lower.contains("bug") { return "Dev" }
        if lower.contains("meet") || lower.contains("sync") || lower.contains("1:1") { return "Team" }
        return "General"
    }
}
