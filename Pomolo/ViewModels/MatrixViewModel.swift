import SwiftUI
import CoreData
import Combine

@MainActor
public final class MatrixViewModel: ObservableObject {
    @Published public var q1Tasks: [TaskItem] = []
    @Published public var q2Tasks: [TaskItem] = []
    @Published public var q3Tasks: [TaskItem] = []
    @Published public var q4Tasks: [TaskItem] = []
    @Published public var isGridView: Bool = false
    @Published public var showAIToast: Bool = true
    @Published public var draggedTask: TaskItem? = nil
    @Published public var efficiencyIndex: Double = 78.0
    
    @Published public var balanceSuggestion: AIBalanceSuggestion? = nil
    
    private let coreDataManager = CoreDataManager.shared
    
    public init() {
        reloadAllQuadrants()
    }
    
    public func reloadAllQuadrants() {
        withAnimation(.easeInOut(duration: 0.2)) {
            q1Tasks = coreDataManager.fetchTasks(for: .q1)
            q2Tasks = coreDataManager.fetchTasks(for: .q2)
            q3Tasks = coreDataManager.fetchTasks(for: .q3)
            q4Tasks = coreDataManager.fetchTasks(for: .q4)
            calculateEfficiencyIndex()
            evaluateBalanceSuggestion()
        }
    }
    
    public var totalActiveCount: Int {
        let all = q1Tasks + q2Tasks + q3Tasks + q4Tasks
        return all.filter { !$0.isCompleted }.count
    }
    
    public func tasks(for quadrant: MatrixQuadrant) -> [TaskItem] {
        switch quadrant {
        case .q1: return q1Tasks
        case .q2: return q2Tasks
        case .q3: return q3Tasks
        case .q4: return q4Tasks
        case .inbox: return []
        }
    }
    
    // MARK: - Native Drag & Drop Handler
    public func moveTask(_ task: TaskItem, to destinationQuadrant: MatrixQuadrant) {
        guard task.quadrant != destinationQuadrant else { return }
        
        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
            coreDataManager.updateTaskQuadrant(task: task, to: destinationQuadrant)
            reloadAllQuadrants()
        }
    }
    
    public func toggleTaskCompletion(_ task: TaskItem) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            coreDataManager.toggleTaskCompletion(task: task)
            reloadAllQuadrants()
        }
    }
    
    public func applyAIBalanceRecommendation() {
        guard let suggestion = balanceSuggestion else {
            showAIToast = false
            return
        }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            coreDataManager.updateTaskQuadrant(task: suggestion.task, to: suggestion.targetQuadrant)
            reloadAllQuadrants()
            showAIToast = false
        }
    }
    
    private func evaluateBalanceSuggestion() {
        let activeQ1 = q1Tasks.filter { !$0.isCompleted }
        
        // 1. Check if Q1 contains strategic/deep work tasks that should be in Q2 (Schedule)
        for task in activeQ1 {
            let proper = TaskViewModel.determineQuadrant(
                title: task.wrappedTitle,
                details: task.taskDescription,
                tag: task.tag,
                estimatedMinutes: Int(task.estimatedMinutes),
                dueDate: task.dueDate,
                isFrog: task.isFrog
            )
            if proper == .q2 {
                balanceSuggestion = AIBalanceSuggestion(
                    task: task,
                    targetQuadrant: .q2,
                    title: "Pomolo AI Balance Insight",
                    explanation: "Move '\(task.wrappedTitle)' to Q2 Schedule to protect deep focus blocks.",
                    actionButtonTitle: "SCHEDULE"
                )
                return
            }
        }
        
        // 2. Check if Q1 contains low-leverage routine tasks that can be delegated
        for task in activeQ1 {
            let proper = TaskViewModel.determineQuadrant(
                title: task.wrappedTitle,
                details: task.taskDescription,
                tag: task.tag,
                estimatedMinutes: Int(task.estimatedMinutes),
                dueDate: task.dueDate,
                isFrog: task.isFrog
            )
            if proper == .q3 {
                balanceSuggestion = AIBalanceSuggestion(
                    task: task,
                    targetQuadrant: .q3,
                    title: "Pomolo AI Balance Insight",
                    explanation: "Delegate '\(task.wrappedTitle)' to save \(task.estimatedMinutes)m of peak energy.",
                    actionButtonTitle: "DELEGATE"
                )
                return
            }
        }
        
        // 3. Check if Q1 is overloaded (> 2 tasks)
        if activeQ1.count > 2, let nonCritical = activeQ1.last(where: { !($0.wrappedTitle.lowercased().contains("p0") || $0.wrappedTitle.lowercased().contains("blocker")) }) {
            balanceSuggestion = AIBalanceSuggestion(
                task: nonCritical,
                targetQuadrant: .q2,
                title: "Cognitive Load Balancing",
                explanation: "Re-schedule '\(nonCritical.wrappedTitle)' to Q2 to keep Q1 focused on emergencies.",
                actionButtonTitle: "SCHEDULE"
            )
            return
        }
        
        balanceSuggestion = nil
    }
    
    private func calculateEfficiencyIndex() {
        let highLeverageCount = Double(q1Tasks.count + q2Tasks.count)
        let total = Double(max(1, q1Tasks.count + q2Tasks.count + q3Tasks.count + q4Tasks.count))
        efficiencyIndex = min(100.0, round((highLeverageCount / total) * 100.0))
    }
}

public struct AIBalanceSuggestion: Identifiable {
    public var id: UUID { task.wrappedId }
    public let task: TaskItem
    public let targetQuadrant: MatrixQuadrant
    public let title: String
    public let explanation: String
    public let actionButtonTitle: String
}
