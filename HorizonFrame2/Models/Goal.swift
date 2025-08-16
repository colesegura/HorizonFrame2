import Foundation
import SwiftData

@Model
final class Goal {
    var text: String
    var order: Int
    var createdAt: Date
    var targetDate: Date? // Target date for goal achievement
    var isArchived: Bool // New property for archiving
    var visualization: String? // Visualization description from onboarding
    var isFromOnboarding: Bool // Flag to identify onboarding goals
    
    // AI alignment properties
    @Attribute(.externalStorage) var userVision: String?
    @Attribute(.externalStorage) var currentPrompt: String?
    
    // Relationships
    @Relationship(deleteRule: .cascade) var actionItems: [ActionItem] = []
    @Relationship(deleteRule: .cascade) var journalEntries: [JournalEntry] = []
    
    init(text: String, order: Int, targetDate: Date? = nil, isArchived: Bool = false, visualization: String? = nil, isFromOnboarding: Bool = false, userVision: String? = nil) {
        self.text = text
        self.order = order
        self.createdAt = Date()
        self.targetDate = targetDate
        self.isArchived = isArchived
        self.visualization = visualization
        self.isFromOnboarding = isFromOnboarding
        self.userVision = userVision
    }
}
