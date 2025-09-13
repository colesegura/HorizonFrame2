import Foundation
import SwiftData

@Model
final class PrincipleReview {
    var score: Int // Score from 1-10
    var reflectionText: String
    
    // Relationship to the principle being reviewed
    @Relationship var principle: PersonalCodePrinciple?
    
    // Relationship back to the parent DailyReview
    var dailyReview: DailyReview?
    
    init(score: Int, reflectionText: String, principle: PersonalCodePrinciple) {
        self.score = score
        self.reflectionText = reflectionText
        self.principle = principle
    }
}
