import Foundation
import SwiftData

@Model
final class DailyReview {
    var date: Date
    var overallScore: Int // Optional overall score for the day
    var isWeeklyReview: Bool = false
    
    @Relationship(deleteRule: .cascade) 
    var principleReviews: [PrincipleReview] = []
    
    init(date: Date, overallScore: Int = 0, isWeeklyReview: Bool = false) {
        self.date = date
        self.overallScore = overallScore
        self.isWeeklyReview = isWeeklyReview
    }
}
