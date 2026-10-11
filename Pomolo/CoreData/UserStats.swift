import Foundation
import CoreData

@objc(UserStats)
public class UserStats: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID?
    @NSManaged public var dailyStreak: Int32
    @NSManaged public var totalPomodoroPoints: Int32
    @NSManaged public var todayFocusMinutes: Int32
    @NSManaged public var totalFrogsCompleted: Int32
    @NSManaged public var lastActiveDate: Date?
    @NSManaged public var efficiencyIndex: Double
}

public extension UserStats {
    var wrappedStreak: Int {
        Int(dailyStreak)
    }
    
    var wrappedPoints: Int {
        Int(totalPomodoroPoints)
    }
    
    var wrappedFocusMinutes: Int {
        Int(todayFocusMinutes)
    }
    
    static func fetchRequest() -> NSFetchRequest<UserStats> {
        return NSFetchRequest<UserStats>(entityName: "UserStats")
    }
}
