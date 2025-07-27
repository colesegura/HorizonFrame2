import Foundation
import SwiftData

@Model
final class ActionItem {
    var text: String
    var isCompleted: Bool
    var order: Int
    var createdAt: Date
    var goal: Goal?
    
    init(text: String, order: Int, goal: Goal? = nil, isCompleted: Bool = false) {
        self.text = text
        self.order = order
        self.goal = goal
        self.isCompleted = isCompleted
        self.createdAt = Date()
    }
} 