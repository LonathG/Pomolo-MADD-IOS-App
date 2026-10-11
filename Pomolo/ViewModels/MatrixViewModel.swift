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
        if let delegatableTask = q1Tasks.first(where: { !$0.isCompleted && $0.estimatedMinutes < 30 }) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                coreDataManager.updateTaskQuadrant(task: delegatableTask, to: .q3)
                reloadAllQuadrants()
                showAIToast = false
            }
        } else {
            showAIToast = false
        }
    }
    
    private func calculateEfficiencyIndex() {
        let highLeverageCount = Double(q1Tasks.count + q2Tasks.count)
        let total = Double(max(1, q1Tasks.count + q2Tasks.count + q3Tasks.count + q4Tasks.count))
        efficiencyIndex = min(100.0, round((highLeverageCount / total) * 100.0))
    }
}
