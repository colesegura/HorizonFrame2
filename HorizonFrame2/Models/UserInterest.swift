import Foundation
import SwiftData

enum InterestType: String, Codable, CaseIterable {
    case motivation = "Become more motivated"
    case focus = "Become more focused"
    case health = "Become healthier"
    case consistency = "Become more consistent"
    case confidence = "Become more confident"
    case goalAchievement = "Become better equipped to reach my goals"
    case mentalHealth = "Improve mental health"
    case gratitude = "Become more grateful"
    case happiness = "Become happier"
    case anxiety = "Reduce anxiety"
    case depression = "Manage depression"
    case stress = "Manage stress"
    case productivity = "Become more productive"
    case timeManagement = "Improve time management"
    case meditation = "Meditate more"
    case phoneUsage = "Use phone/social media less"
    case other = "Other"
    
    var followUpOptions: [String] {
        switch self {
        case .health:
            return ["Diet", "Sleep", "Exercise", "Light diet", "Other"]
        case .productivity:
            return ["Time blocking", "Task prioritization", "Eliminating distractions", "Energy management", "Other"]
        case .stress:
            return ["Work stress", "Relationship stress", "Financial stress", "Health stress", "Other"]
        case .anxiety:
            return ["Social anxiety", "Performance anxiety", "General anxiety", "Health anxiety", "Other"]
        case .focus:
            return ["Deep work", "Attention span", "Eliminating distractions", "Mental clarity", "Other"]
        case .consistency:
            return ["Daily habits", "Exercise routine", "Work schedule", "Sleep schedule", "Other"]
        default:
            return ["General improvement", "Specific goals", "Daily practices", "Mindset shifts", "Other"]
        }
    }
    
    var baselineQuestions: [String] {
        switch self {
        case .health:
            return [
                "How do you feel about your current health?",
                "What specific aspect of your health do you want to improve most?",
                "What's holding you back from consistently maintaining the health habits you want?"
            ]
        case .productivity:
            return [
                "How satisfied are you with your current productivity levels?",
                "What's your biggest productivity challenge right now?",
                "What would being more productive mean for your life?"
            ]
        case .stress:
            return [
                "How would you rate your current stress levels on a scale of 1-10?",
                "What are the main sources of stress in your life?",
                "What stress management techniques have you tried before?"
            ]
        case .anxiety:
            return [
                "How often do you experience anxiety in your daily life?",
                "What situations or thoughts tend to trigger your anxiety?",
                "What would your life look like if you felt more calm and centered?"
            ]
        default:
            return [
                "How do you feel about your current progress in this area?",
                "What do you want to improve or change?",
                "What's been holding you back from making the progress you want?"
            ]
        }
    }
}

enum HealthSubcategory: String, Codable, CaseIterable {
    case diet = "Diet"
    case sleep = "Sleep"
    case exercise = "Exercise"
    case lightDiet = "Light diet"
    case other = "Other"
    
    var baselineQuestions: [String] {
        switch self {
        case .diet:
            return [
                "How do you feel about your current diet and relationship with food?",
                "What specific eating habits or nutrition goals do you want to improve?",
                "What are your biggest challenges when it comes to eating consistently well?",
                "What does your ideal eating pattern look like on a typical day?",
                "How do you currently plan and prepare your meals?"
            ]
        case .sleep:
            return [
                "How would you rate your current sleep quality?",
                "What sleep habits would you like to improve?",
                "What prevents you from getting the sleep you need?"
            ]
        case .exercise:
            return [
                "How do you feel about your current exercise routine?",
                "What type of physical activity do you want to do more of?",
                "What's been stopping you from exercising consistently?"
            ]
        case .lightDiet:
            return [
                "What does 'eating lighter' mean to you?",
                "What changes would you like to make to feel lighter and more energized?",
                "What challenges do you face with portion control or food choices?"
            ]
        case .other:
            return [
                "What specific health area would you like to focus on?",
                "How do you currently feel about this aspect of your health?",
                "What would improvement in this area mean for your daily life?"
            ]
        }
    }
}

@Model
final class UserInterest {
    var type: String // InterestType raw value
    var subcategory: String? // For interests like health that have subcategories
    var customDescription: String? // For "Other" selections
    var isActive: Bool
    var createdAt: Date
    var priority: Int // 1-10, allows users to prioritize multiple interests
    
    // Baseline responses
    var baselineResponses: [String] = [] // Stores responses to baseline questions
    var baselineCompleted: Bool = false
    
    // Progress tracking
    var currentLevel: Int = 1 // 1-10 progression level
    var lastProgressUpdate: Date?
    
    // Diet-specific tracking (for diet pilot)
    var dietGoals: [String] = [] // Specific nutrition goals
    var mealPlanningFrequency: String? // daily, weekly, monthly
    var nutritionFocus: [String] = [] // weight_loss, muscle_gain, energy, general_health
    var dietaryRestrictions: [String] = [] // vegetarian, vegan, gluten_free, etc.
    var weeklyProgressScores: [Int] = [] // Track weekly progress (1-10 scale)
    
    // Note: JournalSession relationship is handled via userInterest property in JournalSession
    
    init(type: InterestType, subcategory: String? = nil, customDescription: String? = nil, priority: Int = 5) {
        self.type = type.rawValue
        self.subcategory = subcategory
        self.customDescription = customDescription
        self.isActive = true
        self.createdAt = Date()
        self.priority = priority
        self.currentLevel = 1
    }
    
    var interestType: InterestType? {
        return InterestType(rawValue: type)
    }
    
    var healthSubcategory: HealthSubcategory? {
        guard let subcategory = subcategory else { return nil }
        return HealthSubcategory(rawValue: subcategory)
    }
    
    var displayName: String {
        if let subcategory = subcategory, !subcategory.isEmpty {
            return subcategory
        }
        return interestType?.rawValue ?? "Unknown Interest"
    }
}
