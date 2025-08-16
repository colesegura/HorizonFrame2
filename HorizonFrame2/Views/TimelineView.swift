import SwiftUI
import SwiftData

struct TimelineView: View {
    @Query(sort: \DailyAlignment.date, order: .reverse) private var alignments: [DailyAlignment]
    @Query(sort: \Goal.order) private var goals: [Goal]
    
    @State private var startOfDay: Date = Date()
    @State private var endOfDay: Date = Date()
    
    @Query(
        FetchDescriptor<DailyAlignment>(
            predicate: nil,
            sortBy: [SortDescriptor(\DailyAlignment.date, order: .reverse)]
        )
    ) private var allAlignments: [DailyAlignment]
    
    private var todayAlignments: [DailyAlignment] {
        allAlignments.filter { alignment in
            alignment.date >= startOfDay && alignment.date < endOfDay
        }
    }
    
    private var currentStreak: Int {
        calculateCurrentStreak()
    }
    
    private var upcomingMilestones: [TimelineItem] {
        generateUpcomingMilestones()
    }
    
    init() {
        let calendar = Calendar.current
        self.startOfDay = calendar.startOfDay(for: Date())
        self.endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Timeline")
                .font(.headline)
                .foregroundColor(.white)
            
            LazyVStack(spacing: 16) {
                ForEach(upcomingMilestones) { item in
                    TimelineItemView(item: item)
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 20)
            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            .background(Color.clear.cornerRadius(20)))
    }
    
    private func calculateCurrentStreak() -> Int {
        guard !alignments.isEmpty else { return 0 }
        
        let sortedDates = alignments.map { $0.date }.sorted { $0 > $1 }
        var currentStreak = 0
        var currentDate = Calendar.current.startOfDay(for: .now)
        
        for date in sortedDates {
            // Compare dates manually instead of using isDate(_:inSameDayAs:)
            let dateDay = Calendar.current.startOfDay(for: date)
            if dateDay == currentDate {
                currentStreak += 1
                currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate)!
            } else {
                break
            }
        }
        
        return currentStreak
    }
    
    private func generateUpcomingMilestones() -> [TimelineItem] {
        var items: [TimelineItem] = []
        
        // Progress milestones
        let progressMilestones = [
            (7, "1 Week Streak", "Complete 7 days in a row"),
            (14, "2 Week Streak", "Complete 14 days in a row"),
            (30, "1 Month Streak", "Complete 30 days in a row"),
            (100, "100 Days", "Complete 100 total alignments")
        ]
        
        for (target, title, description) in progressMilestones {
            if currentStreak < target {
                let daysRemaining = target - currentStreak
                items.append(TimelineItem(
                    id: "progress_\(target)",
                    title: title,
                    description: description,
                    daysRemaining: daysRemaining,
                    type: .milestone,
                    icon: "target"
                ))
                break
            }
        }
        
        // Feature unlocks
        let featureUnlocks = [
            (3, "Emotion Tracking", "Add emotions to your goal moments"),
            (7, "Goal Sharing", "Share your goals with accountability partners"),
            (14, "Advanced Analytics", "Detailed progress insights"),
            (30, "Custom Themes", "Personalize your experience")
        ]
        
        for (daysRequired, title, description) in featureUnlocks {
            if currentStreak < daysRequired {
                let daysRemaining = daysRequired - currentStreak
                items.append(TimelineItem(
                    id: "feature_\(daysRequired)",
                    title: title,
                    description: description,
                    daysRemaining: daysRemaining,
                    type: .feature,
                    icon: "sparkles"
                ))
                break
            }
        }
        
        // Award milestones
        let awardMilestones = [
            (5, "Consistency Award", "Complete 5 alignments"),
            (10, "Dedication Award", "Complete 10 alignments"),
            (25, "Commitment Award", "Complete 25 alignments"),
            (50, "Mastery Award", "Complete 50 alignments")
        ]
        
        for (target, title, description) in awardMilestones {
            if alignments.count < target {
                let daysRemaining = target - alignments.count
                items.append(TimelineItem(
                    id: "award_\(target)",
                    title: title,
                    description: description,
                    daysRemaining: daysRemaining,
                    type: .award,
                    icon: "trophy"
                ))
                break
            }
        }
        
        return items.sorted { $0.daysRemaining < $1.daysRemaining }
    }
}

struct TimelineItem: Identifiable {
    let id: String
    let title: String
    let description: String
    let daysRemaining: Int
    let type: TimelineItemType
    let icon: String
}

enum TimelineItemType {
    case milestone
    case feature
    case award
    
    var color: Color {
        switch self {
        case .milestone:
            return .blue
        case .feature:
            return .purple
        case .award:
            return .yellow
        }
    }
}

struct TimelineItemView: View {
    let item: TimelineItem
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(item.type.color.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: item.icon)
                    .foregroundColor(item.type.color)
                    .font(.title3)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(item.title)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("in \(item.daysRemaining) \(item.daysRemaining == 1 ? "day" : "days")")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Text(item.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        TimelineView()
    }
    .preferredColorScheme(.dark)
} 