import Foundation
import SwiftData

@Model
final class JournalEntry {
    var date: Date
    var prompt: String
    var response: String
    var goal: Goal?
    
    init(date: Date = Date(), prompt: String, response: String, goal: Goal? = nil) {
        self.date = date
        self.prompt = prompt
        self.response = response
        self.goal = goal
    }
}
