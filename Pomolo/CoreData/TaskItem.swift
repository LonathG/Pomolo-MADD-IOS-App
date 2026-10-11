import Foundation
import CoreData

@objc(TaskItem)
public class TaskItem: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var taskDescription: String?
    @NSManaged public var tag: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var dueDate: Date?
    @NSManaged public var isCompleted: Bool
    @NSManaged public var matrixQuadrant: String?
    @NSManaged public var estimatedMinutes: Int16
    @NSManaged public var estimatedPomodoros: Int16
    @NSManaged public var completedPomodoros: Int16
    @NSManaged public var cognitiveLoadScore: Double
    @NSManaged public var isFrog: Bool
    @NSManaged public var orderIndex: Int32
}

public extension TaskItem {
    var wrappedId: UUID {
        id ?? UUID()
    }
    
    var wrappedTitle: String {
        title ?? "Untitled Task"
    }
    
    var wrappedTag: String {
        tag ?? "General"
    }
    
    var quadrant: MatrixQuadrant {
        get {
            guard let raw = matrixQuadrant else { return .inbox }
            return MatrixQuadrant(rawValue: raw) ?? .inbox
        }
        set {
            matrixQuadrant = newValue.rawValue
        }
    }
    
    static func fetchRequest() -> NSFetchRequest<TaskItem> {
        return NSFetchRequest<TaskItem>(entityName: "TaskItem")
    }
}
