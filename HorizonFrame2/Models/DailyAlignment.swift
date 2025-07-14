import Foundation
import SwiftData

@Model
final class DailyAlignment {
    var date: Date
    var completed: Bool
    
    init(date: Date, completed: Bool) {
        self.date = date
        self.completed = completed
    }
}
