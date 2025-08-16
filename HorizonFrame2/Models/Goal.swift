import Foundation
import SwiftData

enum GoalCategory: String, Codable, CaseIterable {
    case active
    case upcoming
    case completed
    
    var displayName: String {
        switch self {
        case .active:
            return "Active"
        case .upcoming:
            return "Upcoming"
        case .completed:
            return "Completed"
        }
    }
    
    var icon: String {
        switch self {
        case .active:
            return "●"
        case .upcoming:
            return "○"
        case .completed:
            return "✓"
        }
    }
    
    var emptyStateIcon: String {
        switch self {
        case .active:
            return "target"
        case .upcoming:
            return "calendar.badge.clock"
        case .completed:
            return "checkmark.circle"
        }
    }
    
    var emptyStateMessage: String {
        switch self {
        case .active:
            return "No active goals yet. Add a goal to start tracking your progress!"
        case .upcoming:
            return "No upcoming goals. Add goals you're planning to work on in the future."
        case .completed:
            return "No completed goals yet. Your achievements will appear here!"
        }
    }
}

@Model
final class Goal {
    var text: String
    var order: Int
    var createdAt: Date
    var targetDate: Date? // Target date for goal achievement
    var isArchived: Bool // New property for archiving
    var visualization: String? // Visualization description from onboarding
    var isFromOnboarding: Bool // Flag to identify onboarding goals
    var isPrimary: Bool = false // Flag for primary goal selection
    var category: String = GoalCategory.active.rawValue // Goal category (active, upcoming, completed)
    
    // AI alignment properties
    @Attribute(.externalStorage) var userVision: String?
    @Attribute(.externalStorage) var currentPrompt: String?
    
    // Relationships
    @Relationship(deleteRule: .cascade) var actionItems: [ActionItem] = []
    @Relationship(deleteRule: .cascade) var journalEntries: [JournalEntry] = []
    
    init(text: String, order: Int, targetDate: Date? = nil, isArchived: Bool = false, visualization: String? = nil, isFromOnboarding: Bool = false, userVision: String? = nil, isPrimary: Bool = false, category: GoalCategory = .active) {
        self.text = text
        self.order = order
        self.createdAt = Date()
        self.targetDate = targetDate
        self.isArchived = isArchived
        self.visualization = visualization
        self.isFromOnboarding = isFromOnboarding
        self.userVision = userVision
        self.isPrimary = isPrimary
        self.category = category.rawValue
    }
}
