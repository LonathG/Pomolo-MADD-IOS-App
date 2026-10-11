import Foundation
import CoreData

public final class CoreDataManager: @unchecked Sendable {
    public static let shared = CoreDataManager()
    
    public let persistentContainer: NSPersistentContainer
    
    public var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    public init(inMemory: Bool = false) {
        // Attempt to load from .xcdatamodeld bundle, otherwise build managed object model dynamically
        let model: NSManagedObjectModel
        if let modelURL = Bundle.main.url(forResource: "Pomolo", withExtension: "momd"),
           let loadedModel = NSManagedObjectModel(contentsOf: modelURL) {
            model = loadedModel
        } else {
            model = Self.createProgrammaticModel()
        }
        
        let container = NSPersistentContainer(name: "Pomolo", managedObjectModel: model)
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                print("Core Data failed to load store: \(error), \(error.userInfo)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        self.persistentContainer = container
        
        seedInitialDataIfEmpty()
    }
    
    // MARK: - Programmatic Schema Fallback
    private static func createProgrammaticModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()
        
        // TaskItem Entity
        let taskEntity = NSEntityDescription()
        taskEntity.name = "TaskItem"
        taskEntity.managedObjectClassName = NSStringFromClass(TaskItem.self)
        
        let idAttr = NSAttributeDescription()
        idAttr.name = "id"
        idAttr.attributeType = .UUIDAttributeType
        idAttr.isOptional = false
        
        let titleAttr = NSAttributeDescription()
        titleAttr.name = "title"
        titleAttr.attributeType = .stringAttributeType
        titleAttr.isOptional = false
        
        let descAttr = NSAttributeDescription()
        descAttr.name = "taskDescription"
        descAttr.attributeType = .stringAttributeType
        descAttr.isOptional = true
        
        let tagAttr = NSAttributeDescription()
        tagAttr.name = "tag"
        tagAttr.attributeType = .stringAttributeType
        tagAttr.isOptional = true
        
        let createdAtAttr = NSAttributeDescription()
        createdAtAttr.name = "createdAt"
        createdAtAttr.attributeType = .dateAttributeType
        createdAtAttr.isOptional = false
        
        let dueDateAttr = NSAttributeDescription()
        dueDateAttr.name = "dueDate"
        dueDateAttr.attributeType = .dateAttributeType
        dueDateAttr.isOptional = true
        
        let isCompletedAttr = NSAttributeDescription()
        isCompletedAttr.name = "isCompleted"
        isCompletedAttr.attributeType = .booleanAttributeType
        isCompletedAttr.defaultValue = false
        
        let isFrogAttr = NSAttributeDescription()
        isFrogAttr.name = "isFrog"
        isFrogAttr.attributeType = .booleanAttributeType
        isFrogAttr.defaultValue = false
        
        let quadAttr = NSAttributeDescription()
        quadAttr.name = "matrixQuadrant"
        quadAttr.attributeType = .stringAttributeType
        quadAttr.defaultValue = "inbox"
        
        let estMinAttr = NSAttributeDescription()
        estMinAttr.name = "estimatedMinutes"
        estMinAttr.attributeType = .integer16AttributeType
        estMinAttr.defaultValue = 25
        
        let estPomAttr = NSAttributeDescription()
        estPomAttr.name = "estimatedPomodoros"
        estPomAttr.attributeType = .integer16AttributeType
        estPomAttr.defaultValue = 1
        
        let compPomAttr = NSAttributeDescription()
        compPomAttr.name = "completedPomodoros"
        compPomAttr.attributeType = .integer16AttributeType
        compPomAttr.defaultValue = 0
        
        let cogAttr = NSAttributeDescription()
        cogAttr.name = "cognitiveLoadScore"
        cogAttr.attributeType = .doubleAttributeType
        cogAttr.defaultValue = 0.0
        
        let orderAttr = NSAttributeDescription()
        orderAttr.name = "orderIndex"
        orderAttr.attributeType = .integer32AttributeType
        orderAttr.defaultValue = 0
        
        taskEntity.properties = [
            idAttr, titleAttr, descAttr, tagAttr, createdAtAttr, dueDateAttr,
            isCompletedAttr, isFrogAttr, quadAttr, estMinAttr, estPomAttr,
            compPomAttr, cogAttr, orderAttr
        ]
        
        // UserStats Entity
        let statsEntity = NSEntityDescription()
        statsEntity.name = "UserStats"
        statsEntity.managedObjectClassName = NSStringFromClass(UserStats.self)
        
        let statsId = NSAttributeDescription()
        statsId.name = "id"
        statsId.attributeType = .UUIDAttributeType
        statsId.isOptional = false
        
        let streakAttr = NSAttributeDescription()
        streakAttr.name = "dailyStreak"
        streakAttr.attributeType = .integer32AttributeType
        streakAttr.defaultValue = 7
        
        let pointsAttr = NSAttributeDescription()
        pointsAttr.name = "totalPomodoroPoints"
        pointsAttr.attributeType = .integer32AttributeType
        pointsAttr.defaultValue = 1420
        
        let focusMinAttr = NSAttributeDescription()
        focusMinAttr.name = "todayFocusMinutes"
        focusMinAttr.attributeType = .integer32AttributeType
        focusMinAttr.defaultValue = 165
        
        let frogsAttr = NSAttributeDescription()
        frogsAttr.name = "totalFrogsCompleted"
        frogsAttr.attributeType = .integer32AttributeType
        frogsAttr.defaultValue = 3
        
        let effAttr = NSAttributeDescription()
        effAttr.name = "efficiencyIndex"
        effAttr.attributeType = .doubleAttributeType
        effAttr.defaultValue = 78.0
        
        let lastDateAttr = NSAttributeDescription()
        lastDateAttr.name = "lastActiveDate"
        lastDateAttr.attributeType = .dateAttributeType
        lastDateAttr.isOptional = true
        
        statsEntity.properties = [
            statsId, streakAttr, pointsAttr, focusMinAttr, frogsAttr, effAttr, lastDateAttr
        ]
        
        model.entities = [taskEntity, statsEntity]
        return model
    }
    
    // MARK: - Save Context
    public func save() {
        let context = viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save Core Data context: \(error)")
            }
        }
    }
    
    // MARK: - Task CRUD Operations
    @discardableResult
    public func createTask(
        title: String,
        details: String? = nil,
        tag: String = "General",
        quadrant: MatrixQuadrant = .inbox,
        estimatedMinutes: Int = 25,
        dueDate: Date? = nil,
        isFrog: Bool = false
    ) -> TaskItem {
        let task = TaskItem(context: viewContext)
        task.id = UUID()
        task.title = title
        task.taskDescription = details
        task.tag = tag
        task.createdAt = Date()
        task.dueDate = dueDate
        task.isCompleted = false
        task.matrixQuadrant = quadrant.rawValue
        task.estimatedMinutes = Int16(estimatedMinutes)
        task.estimatedPomodoros = Int16(max(1, estimatedMinutes / 25))
        task.completedPomodoros = 0
        task.cognitiveLoadScore = 0.0
        task.isFrog = isFrog
        task.orderIndex = Int32(Date().timeIntervalSince1970)
        save()
        return task
    }
    
    public func updateTaskQuadrant(task: TaskItem, to quadrant: MatrixQuadrant) {
        task.matrixQuadrant = quadrant.rawValue
        save()
    }
    
    public func toggleTaskCompletion(task: TaskItem) {
        task.isCompleted.toggle()
        if task.isCompleted && task.isFrog {
            let stats = getUserStats()
            stats.totalFrogsCompleted += 1
        }
        save()
    }
    
    public func deleteTask(task: TaskItem) {
        viewContext.delete(task)
        save()
    }
    
    public func fetchTasks(for quadrant: MatrixQuadrant) -> [TaskItem] {
        let request: NSFetchRequest<TaskItem> = TaskItem.fetchRequest()
        request.predicate = NSPredicate(format: "matrixQuadrant == %@", quadrant.rawValue)
        request.sortDescriptors = [NSSortDescriptor(key: "orderIndex", ascending: true)]
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching tasks for quadrant \(quadrant.rawValue): \(error)")
            return []
        }
    }
    
    public func fetchAllTasks() -> [TaskItem] {
        let request: NSFetchRequest<TaskItem> = TaskItem.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching all tasks: \(error)")
            return []
        }
    }
    
    // MARK: - User Stats & Streaks
    public func getUserStats() -> UserStats {
        let request: NSFetchRequest<UserStats> = UserStats.fetchRequest()
        do {
            let results = try viewContext.fetch(request)
            if let existing = results.first {
                return existing
            }
        } catch {
            print("Error fetching UserStats: \(error)")
        }
        
        let stats = UserStats(context: viewContext)
        stats.id = UUID()
        stats.dailyStreak = 7
        stats.totalPomodoroPoints = 1420
        stats.todayFocusMinutes = 165
        stats.totalFrogsCompleted = 3
        stats.efficiencyIndex = 78.0
        stats.lastActiveDate = Date()
        save()
        return stats
    }
    
    public func recordCompletedPomodoro(durationMinutes: Int = 25, points: Int = 100) {
        let stats = getUserStats()
        stats.todayFocusMinutes += Int32(durationMinutes)
        stats.totalPomodoroPoints += Int32(points)
        stats.lastActiveDate = Date()
        save()
    }
    
    // MARK: - Pre-Seeding Design Demo Data
    public func seedInitialDataIfEmpty() {
        let count = (try? viewContext.count(for: TaskItem.fetchRequest())) ?? 0
        guard count == 0 else { return }
        
        // Q1: Do First
        createTask(
            title: "App Store submission metadata & privacy audit",
            details: "Critical privacy declarations, screenshots, and version bump for v2.4 launch.",
            tag: "Release",
            quadrant: .q1,
            estimatedMinutes: 45,
            dueDate: Calendar.current.date(bySettingHour: 17, minute: 0, second: 0, of: Date())
        )
        
        createTask(
            title: "Fix production memory leak on iPad client",
            details: "Investigate Instruments leak in canvas render loop.",
            tag: "Engineering",
            quadrant: .q1,
            estimatedMinutes: 45,
            dueDate: Date()
        )
        
        // Q2: Schedule / Deep Focus (The Primary Frog)
        createTask(
            title: "Draft Q3 Product Strategy One-Pager",
            details: "Highest leverage initiative this week. Unblocks 3 engineering workstreams during your peak morning clarity window.",
            tag: "Strategy",
            quadrant: .q2,
            estimatedMinutes: 60,
            dueDate: Calendar.current.date(byAdding: .day, value: 3, to: Date()),
            isFrog: true
        )
        
        createTask(
            title: "User research synthesis on onboarding flow",
            details: "Review 6 customer interview video recordings.",
            tag: "Research",
            quadrant: .q2,
            estimatedMinutes: 90
        )
        
        // Q3: Delegate
        createTask(
            title: "Schedule quarterly 1:1 leadership syncs",
            details: "Handed over to Calendar Bot.",
            tag: "Team",
            quadrant: .q3,
            estimatedMinutes: 15
        )
        
        createTask(
            title: "Send venue shortlist options for offsite",
            details: "Elena R. (Operations) pending feedback.",
            tag: "Ops",
            quadrant: .q3,
            estimatedMinutes: 20
        )
        
        // Q4: Eliminate
        createTask(
            title: "Review archive of deprecated Figma wireframes",
            details: "Low leverage cleaning backlog.",
            tag: "Design",
            quadrant: .q4,
            estimatedMinutes: 15
        )
        
        // Inbox (Unsorted)
        createTask(
            title: "Review Figma design tokens & iOS components",
            details: "Check squircle radii and dynamic type scaling.",
            tag: "Design",
            quadrant: .inbox,
            estimatedMinutes: 20
        )
        
        createTask(
            title: "Clear backlog triage in Linear",
            details: "Categorize 15 stale issues.",
            tag: "Ops",
            quadrant: .inbox,
            estimatedMinutes: 25
        )
        
        createTask(
            title: "Reply to investor update inquiries",
            details: "Draft follow-up email response.",
            tag: "Comms",
            quadrant: .inbox,
            estimatedMinutes: 10
        )
        
        _ = getUserStats()
        save()
    }
}
