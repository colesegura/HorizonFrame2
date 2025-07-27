import Foundation
import SwiftData

@Model
final class Goal {
    var text: String
    var order: Int
    var createdAt: Date
    var isArchived: Bool // New property for archiving
    var visualization: String? // Visualization description from onboarding
    var isFromOnboarding: Bool // Flag to identify onboarding goals
    @Relationship(deleteRule: .cascade) var actionItems: [ActionItem] = []
    
    init(text: String, order: Int, isArchived: Bool = false, visualization: String? = nil, isFromOnboarding: Bool = false) {
        self.text = text
        self.order = order
        self.createdAt = Date()
        self.isArchived = isArchived
        self.visualization = visualization
        self.isFromOnboarding = isFromOnboarding
    }
}
