import Foundation

struct Award {
    let id: String
    let title: String
    let description: String
    let iconName: String
    let requiredAlignments: Int
}

extension Award {
    static let allAwards: [Award] = [
        // Streaks
        Award(id: "streak_3", title: "Getting Started", description: "Complete a 3-day streak.", iconName: "3.circle", requiredAlignments: 3),
        Award(id: "streak_7", title: "Week-Long Habit", description: "Complete a 7-day streak.", iconName: "7.circle", requiredAlignments: 7),
        Award(id: "streak_30", title: "Full Month", description: "Complete a 30-day streak.", iconName: "30.circle", requiredAlignments: 30),
        Award(id: "streak_100", title: "Century Club", description: "Complete a 100-day streak.", iconName: "100.circle", requiredAlignments: 100),
        
        // Total Alignments
        Award(id: "total_1", title: "First Step", description: "Complete your first alignment.", iconName: "figure.walk", requiredAlignments: 1),
        Award(id: "total_10", title: "Apprentice", description: "Complete 10 total alignments.", iconName: "star", requiredAlignments: 10),
        Award(id: "total_50", title: "Adept", description: "Complete 50 total alignments.", iconName: "star.fill", requiredAlignments: 50),
        
        // Focuses
        Award(id: "focus_1", title: "Dreamer", description: "Create your first focus.", iconName: "pencil", requiredAlignments: 1),
        Award(id: "focus_5", title: "Visionary", description: "Create 5 focuses.", iconName: "pencil.and.outline", requiredAlignments: 5),
    ]
}
