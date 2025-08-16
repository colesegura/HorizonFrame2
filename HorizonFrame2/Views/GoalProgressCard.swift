import SwiftUI
import SwiftData

struct GoalProgressCard: View {
    let goal: Goal
    let alignments: [DailyAlignment]
    
    private var goalProgress: Double {
        let now = Date()
        let created = goal.createdAt
        guard let target = goal.targetDate else { return 0.0 }
        
        let totalDuration = target.timeIntervalSince(created)
        let elapsedDuration = now.timeIntervalSince(created)
        
        return (elapsedDuration / totalDuration).clamped(to: 0.0...1.0)
    }
    
    private var daysElapsed: Int {
        let createdAt = goal.createdAt
        return Calendar.current.dateComponents([.day], from: createdAt, to: Date()).day ?? 0
    }
    
    private var totalDays: Int {
        let createdAt = goal.createdAt
        guard let targetDate = goal.targetDate else { return 0 }
        return Calendar.current.dateComponents([.day], from: createdAt, to: targetDate).day ?? 0
    }
    
    private var daysRemaining: Int {
        guard let targetDate = goal.targetDate else { return 0 }
        return Calendar.current.dateComponents([.day], from: Date(), to: targetDate).day ?? 0
    }
    
    private var goalStreak: Int {
        calculateGoalStreak()
    }
    
    private var latestEntry: String? {
        // Find the latest alignment for this goal
        let goalAlignments = alignments.filter { alignment in
            alignment.goals.contains { $0.id == goal.id }
        }.sorted { $0.date > $1.date }
        
        // Return the first line of the latest entry if available
        if !goalAlignments.isEmpty {
            // This is a placeholder - in a real app, you would have journal entries
            return "Working towards this goal every day..."
        }
        return nil
    }
    
    // Calculate the color based on progress
    private var progressColor: Color {
        switch goalProgress {
        case 0.0..<0.33:
            return Color.blue // Early stage
        case 0.33..<0.66:
            return Color.orange // Mid-progress
        default:
            return Color.green // Near completion
        }
    }
    
    private var strokeColor: Color {
        progressColor.opacity(0.5)
    }
    
    // Define background gradient colors explicitly
    private let darkBlue1 = Color(UIColor(red: 0x1A/255.0, green: 0x1A/255.0, blue: 0x2E/255.0, alpha: 1.0))
    private let darkBlue2 = Color(UIColor(red: 0x16/255.0, green: 0x21/255.0, blue: 0x3E/255.0, alpha: 1.0))
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Goal header with icon and text
            HStack {
                // Goal icon (emoji or symbol)
                Text("🎯")
                    .font(.system(size: 24))
                    .padding(8)
                    .background(Circle().fill(darkBlue1))
                
                // Goal text
                Text(goal.text)
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Spacer()
            }
            
            // Progress bar
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Background
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 8)
                            
                            // Progress
                            RoundedRectangle(cornerRadius: 4)
                                .fill(progressColor)
                                .frame(width: geometry.size.width * CGFloat(goalProgress), height: 8)
                        }
                    }
                    .frame(height: 8)
                    
                    // Percentage
                    Text("\(Int(goalProgress * 100))%")
                        .font(.caption)
                        .foregroundColor(.white)
                        .frame(width: 40, alignment: .trailing)
                }
                
                // Day counter
                Text("Day \(daysElapsed) of \(totalDays)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            // Stats row
            HStack {
                // Streak counter
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                    Text("\(goalStreak) day streak")
                        .font(.caption)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // Time remaining
                HStack(spacing: 4) {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.blue)
                    Text("\(daysRemaining) days left")
                        .font(.caption)
                        .foregroundColor(.white)
                }
            }
            
            // Latest entry preview
            if let entry = latestEntry {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Latest Entry:")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text(entry)
                        .font(.caption)
                        .foregroundColor(.white)
                        .lineLimit(1)
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(LinearGradient(
                    gradient: Gradient(colors: [darkBlue1, darkBlue2]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(strokeColor, lineWidth: 1)
        )
    }
    
    // Calculate streak for this specific goal
    private func calculateGoalStreak() -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        
        // Filter alignments for this goal
        let goalAlignments = alignments.filter { alignment in
            alignment.goals.contains { $0.id == goal.id }
        }
        
        // Group alignments by day
        let alignmentsByDay = Dictionary(grouping: goalAlignments) { alignment in
            calendar.startOfDay(for: alignment.date)
        }
        
        // Check if aligned today for this goal
        let hasAlignedToday = alignmentsByDay[today] != nil
        
        // Calculate streak
        var streak = 0
        var currentDate = hasAlignedToday ? today : calendar.date(byAdding: .day, value: -1, to: today)!
        
        while let alignmentsForDay = alignmentsByDay[currentDate], !alignmentsForDay.isEmpty {
            streak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDate) else { break }
            currentDate = previousDay
        }
        
        return streak
    }
}

struct GoalProgressCard_Previews: PreviewProvider {
    static var previews: some View {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: Goal.self, DailyAlignment.self, configurations: config)
        
        // Create a sample goal
        let goal = Goal(text: "Meditate Daily", order: 0, targetDate: Calendar.current.date(byAdding: .day, value: 30, to: .now)!, isArchived: false, visualization: nil, isFromOnboarding: false, userVision: nil, isPrimary: true, category: .active)
        
        // Add some sample alignments
        for i in 0..<5 {
            let alignment = DailyAlignment(date: Calendar.current.date(byAdding: .day, value: -i, to: .now)!, completed: true)
            alignment.goals = [goal]
            container.mainContext.insert(alignment)
        }
        
        container.mainContext.insert(goal)
        
        return GoalProgressCard(goal: goal, alignments: [])
            .frame(width: 350)
            .padding()
            .background(Color.black)
            .modelContainer(container)
    }
}
