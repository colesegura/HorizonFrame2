import Foundation
import SwiftData

@Model
final class DailyAlignment {
    var date: Date
    var completed: Bool
    @Relationship var goals: [Goal] // Relationship to aligned goals
    
    init(date: Date, completed: Bool, goals: [Goal] = []) {
        self.date = date
        self.completed = completed
        self.goals = goals
    }
}
