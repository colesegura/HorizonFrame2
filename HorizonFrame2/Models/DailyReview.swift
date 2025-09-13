import Foundation
import SwiftData

@Model
final class DailyReview {
    var date: Date
    var overallScore: Int // Optional overall score for the day
    
    @Relationship(deleteRule: .cascade) 
    var principleReviews: [PrincipleReview] = []
    
    init(date: Date, overallScore: Int = 0) {
        self.date = date
        self.overallScore = overallScore
    }
}
