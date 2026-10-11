import SwiftUI

/// Represents the Eisenhower Matrix 2x2 prioritization quadrants
public enum MatrixQuadrant: String, CaseIterable, Identifiable, Codable {
    case q1 = "q1" // Urgent & Important (Do First)
    case q2 = "q2" // Important, Not Urgent (Schedule / Deep Focus)
    case q3 = "q3" // Urgent, Not Important (Delegate)
    case q4 = "q4" // Neither Urgent nor Important (Eliminate / Drop)
    case inbox = "inbox" // Unsorted / Quick capture
    
    public var id: String { rawValue }
    
    public var title: String {
        switch self {
        case .q1: return "DO FIRST"
        case .q2: return "SCHEDULE"
        case .q3: return "DELEGATE"
        case .q4: return "ELIMINATE"
        case .inbox: return "INBOX"
        }
    }
    
    public var subtitle: String {
        switch self {
        case .q1: return "URGENT • CRITICAL"
        case .q2: return "HIGH IMPACT • GROWTH"
        case .q3: return "TIME-SENSITIVE • OUTSOURCE"
        case .q4: return "LOW IMPACT • DROP"
        case .inbox: return "AWAITING TRIAGE"
        }
    }
    
    public var themeColor: Color {
        switch self {
        case .q1: return Color.pomoloQ1
        case .q2: return Color.pomoloQ2
        case .q3: return Color.pomoloQ3
        case .q4: return Color.pomoloQ4
        case .inbox: return Color.pomoloPeach
        }
    }
    
    public var systemIcon: String {
        switch self {
        case .q1: return "bolt.fill"
        case .q2: return "brain.head.profile"
        case .q3: return "person.2.fill"
        case .q4: return "archivebox.fill"
        case .inbox: return "tray.fill"
        }
    }
    
    public var defaultBadgeText: String {
        switch self {
        case .q1: return "P0 Hotfix"
        case .q2: return "Deep Focus"
        case .q3: return "Automate / Delegate"
        case .q4: return "Declutter"
        case .inbox: return "Unsorted"
        }
    }
}
