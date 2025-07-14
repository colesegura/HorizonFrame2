import Foundation

struct Award {
    let id: String
    let title: String
    let description: String
    let icon: String
}

extension Award {
    static let allAwards: [Award] = [
        // Streaks
        Award(id: "streak_3", title: "Getting Started", description: "Complete a 3-day streak.", icon: "3.circle"),
        Award(id: "streak_7", title: "Week-Long Habit", description: "Complete a 7-day streak.", icon: "7.circle"),
        Award(id: "streak_30", title: "Full Month", description: "Complete a 30-day streak.", icon: "30.circle"),
        Award(id: "streak_100", title: "Century Club", description: "Complete a 100-day streak.", icon: "100.circle"),
        
        // Total Alignments
        Award(id: "total_1", title: "First Step", description: "Complete your first alignment.", icon: "figure.walk"),
        Award(id: "total_10", title: "Apprentice", description: "Complete 10 total alignments.", icon: "star"),
        Award(id: "total_50", title: "Adept", description: "Complete 50 total alignments.", icon: "star.fill"),
        
        // Focuses
        Award(id: "focus_1", title: "Dreamer", description: "Create your first focus.", icon: "pencil"),
        Award(id: "focus_5", title: "Visionary", description: "Create 5 focuses.", icon: "pencil.and.outline"),
    ]
}
