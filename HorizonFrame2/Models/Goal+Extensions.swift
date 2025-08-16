import Foundation
import SwiftData
import SwiftUI



extension Goal {
    // Computed properties for goal tracking
    var daysTracking: Int {
        Calendar.current.dateComponents([.day], from: createdAt, to: Date()).day ?? 0
    }
    
    var daysRemaining: Int {
        guard let targetDate = targetDate else { return 0 }
        return Calendar.current.dateComponents([.day], from: Date(), to: targetDate).day ?? 0
    }
    
    var daysTotal: Int {
        guard let targetDate = targetDate else { return 0 }
        return Calendar.current.dateComponents([.day], from: createdAt, to: targetDate).day ?? 1
    }
    
    var progressPercentage: Double {
        guard let targetDate = targetDate else { return 0 }
        let total = Calendar.current.dateComponents([.day], from: createdAt, to: targetDate).day ?? 1
        return min(1.0, Double(daysTracking) / Double(total))
    }
    
    var currentStreak: Int {
        // This is a placeholder - in a real implementation, this would calculate
        // the current streak based on consecutive daily alignments
        // For now, we'll return a simple count of journal entries in the last week
        let recentEntries = journalEntries.filter { entry in
            guard let date = Calendar.current.date(byAdding: .day, value: -7, to: Date()) else { return false }
            return entry.date >= date
        }
        return recentEntries.count
    }
    
    var lastEntryPreview: String? {
        let sortedEntries = journalEntries.sorted(by: { entry1, entry2 in
            return entry1.date > entry2.date
        })
        guard let lastEntry = sortedEntries.first else { return nil }
        
        let preview = lastEntry.response
        if preview.count > 30 {
            return String(preview.prefix(30)) + "..."
        }
        return preview
    }
    
    var visionPreview: String? {
        guard let vision = userVision, !vision.isEmpty else { return nil }
        
        if vision.count > 50 {
            return String(vision.prefix(50)) + "..."
        }
        return vision
    }
    
    var goalCategory: GoalCategory {
        get {
            return GoalCategory(rawValue: category) ?? .active
        }
        set {
            category = newValue.rawValue
        }
    }
    
    // Helper method to get an appropriate emoji for the goal
    func getGoalEmoji() -> String {
        // This is a simple implementation - could be enhanced with NLP or user selection
        let lowercasedText = text.lowercased()
        
        if lowercasedText.contains("home") || lowercasedText.contains("house") || lowercasedText.contains("live") {
            return "🏠"
        } else if lowercasedText.contains("job") || lowercasedText.contains("work") || lowercasedText.contains("career") || lowercasedText.contains("promot") {
            return "💼"
        } else if lowercasedText.contains("money") || lowercasedText.contains("financ") || lowercasedText.contains("earn") || lowercasedText.contains("income") {
            return "💰"
        } else if lowercasedText.contains("health") || lowercasedText.contains("fit") || lowercasedText.contains("exercise") {
            return "💪"
        } else if lowercasedText.contains("relation") || lowercasedText.contains("love") || lowercasedText.contains("partner") || lowercasedText.contains("marriage") {
            return "❤️"
        } else if lowercasedText.contains("friend") || lowercasedText.contains("social") {
            return "👥"
        } else if lowercasedText.contains("travel") || lowercasedText.contains("vacation") || lowercasedText.contains("trip") {
            return "✈️"
        } else if lowercasedText.contains("learn") || lowercasedText.contains("study") || lowercasedText.contains("education") || lowercasedText.contains("skill") {
            return "📚"
        }
        
        // Default emoji
        return "🎯"
    }
}
