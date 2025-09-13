import Foundation
import SwiftData

@Model
final class WeeklyReview {
    var startDate: Date
    var endDate: Date
    var reflectionText: String
    var goalsForNextWeek: String
    
    init(startDate: Date, endDate: Date, reflectionText: String, goalsForNextWeek: String) {
        self.startDate = startDate
        self.endDate = endDate
        self.reflectionText = reflectionText
        self.goalsForNextWeek = goalsForNextWeek
    }
}
