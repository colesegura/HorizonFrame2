import Foundation
import SwiftData

enum JournalSessionType: String, Codable {
    case baseline = "baseline"
    case dailyAlignment = "daily_alignment"
    case dailyReview = "daily_review"
    case weeklyReview = "weekly_review"
}

@Model
final class JournalSession {
    var date: Date
    var type: String // JournalSessionType raw value
    var prompt: String
    var response: String
    var progressScore: Int? // 1-10 scale for tracking progress
    var aiGenerated: Bool // Whether prompt was AI-generated or predefined
    var completed: Bool
    
    // Relationships
    @Relationship var userInterest: UserInterest?
    @Relationship var dailyAlignment: DailyAlignment?
    @Relationship var dailyReview: DailyReview?
    
    init(type: JournalSessionType, prompt: String, userInterest: UserInterest? = nil) {
        self.date = Date()
        self.type = type.rawValue
        self.prompt = prompt
        self.response = ""
        self.aiGenerated = false
        self.completed = false
        self.userInterest = userInterest
    }
    
    var sessionType: JournalSessionType? {
        return JournalSessionType(rawValue: type)
    }
}

@Model
final class JournalPrompt {
    var content: String
    var interestType: String // InterestType raw value
    var subcategory: String?
    var sessionType: String // JournalSessionType raw value
    var level: Int // 1-10 for progressive complexity
    var isTemplate: Bool // Whether this is a template or AI-generated
    var createdAt: Date
    var usageCount: Int // Track how often this prompt is used
    
    init(content: String, interestType: InterestType, subcategory: String? = nil, sessionType: JournalSessionType, level: Int = 1, isTemplate: Bool = true) {
        self.content = content
        self.interestType = interestType.rawValue
        self.subcategory = subcategory
        self.sessionType = sessionType.rawValue
        self.level = level
        self.isTemplate = isTemplate
        self.createdAt = Date()
        self.usageCount = 0
    }
}
