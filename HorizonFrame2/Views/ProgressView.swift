import SwiftUI
import SwiftData

struct ProgressView: View {
    @Query(sort: \DailyAlignment.date, order: .reverse) private var alignments: [DailyAlignment]
    
    private var stats: (currentStreak: Int, longestStreak: Int, total: Int) {
        calculateStats()
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        Text("Your Journey")
                            .font(.largeTitle).bold()
                            .foregroundColor(.white)
                        
                        // Awards Link
                        NavigationLink(destination: AwardsView()) {
                            HStack {
                                Text("View Your Awards")
                                Image(systemName: "chevron.right")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.15))
                            .cornerRadius(15)
                        }
                        
                        // Stats Section
                        HStack(spacing: 20) {
                            StatBox(value: "\(stats.currentStreak)", label: "Current Streak")
                            StatBox(value: "\(stats.longestStreak)", label: "Longest Streak")
                            StatBox(value: "\(stats.total)", label: "Total Alignments")
                        }
                        
                        // Calendar Heatmap
                        CalendarHeatmapView(alignments: alignments)
                            .padding()
                            .background(Color.gray.opacity(0.15))
                            .cornerRadius(20)
                        
                    }
                    .padding()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    StreakCounterView()
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private func calculateStats() -> (currentStreak: Int, longestStreak: Int, total: Int) {
        guard !alignments.isEmpty else { return (0, 0, 0) }
        
        let sortedDates = alignments.map { $0.date }.sorted { $0 > $1 }
        
        var currentStreak = 0
        var longestStreak = 0
        var streak = 0
        
        var currentDate = Calendar.current.startOfDay(for: .now)
        
        // Calculate current streak
        for date in sortedDates {
            if Calendar.current.isDate(date, inSameDayAs: currentDate) {
                currentStreak += 1
                currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate)!
            } else {
                break
            }
        }
        
        // Calculate longest streak
        var previousDate: Date? = nil
        for date in sortedDates.reversed() { // Iterate from oldest to newest
            if let prev = previousDate, !Calendar.current.isDate(date, inSameDayAs: Calendar.current.date(byAdding: .day, value: 1, to: prev)!) {
                streak = 0 // Reset streak if not consecutive
            }
            streak += 1
            if streak > longestStreak {
                longestStreak = streak
            }
            previousDate = date
        }
        
        return (currentStreak, longestStreak, alignments.count)
    }
}

struct StatBox: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack {
            Text(value)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
            Text(label)
                .font(.footnote)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

struct CalendarHeatmapView: View {
    let alignments: [DailyAlignment]
    private let calendar = Calendar.current
    private let monthFormatter = DateFormatter()
    
    init(alignments: [DailyAlignment]) {
        self.alignments = alignments
        self.monthFormatter.dateFormat = "MMMM"
    }
    
    var body: some View {
        // This is a placeholder for the full calendar view.
        // A proper implementation would be more complex, showing months and days.
        // For now, we'll show a simple grid of the last 35 days.
        let completedDays = Set(alignments.map { calendar.startOfDay(for: $0.date) })
        let days = (0..<35).map { calendar.date(byAdding: .day, value: -$0, to: .now)! }.reversed()
        
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
            ForEach(days, id: \.self) { day in
                ZStack {
                    Circle()
                        .fill(completedDays.contains(calendar.startOfDay(for: day)) ? Color.green.opacity(0.7) : Color.gray.opacity(0.3))
                        .frame(width: 30, height: 30)
                    
                    if calendar.isDate(day, inSameDayAs: .now) {
                        Circle().stroke(Color.white, lineWidth: 2)
                    }
                }
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: DailyAlignment.self, configurations: config)
    // Add sample data
    for i in 0..<5 {
        container.mainContext.insert(DailyAlignment(date: Calendar.current.date(byAdding: .day, value: -i, to: .now)!, completed: true))
    }
    for i in 10..<15 {
        container.mainContext.insert(DailyAlignment(date: Calendar.current.date(byAdding: .day, value: -i, to: .now)!, completed: true))
    }
    
    return ProgressView()
        .modelContainer(container)
}
