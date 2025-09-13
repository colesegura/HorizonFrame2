import SwiftUI
import SwiftData

struct ProgressView: View {
    @Query(sort: \DailyAlignment.date, order: .reverse) private var alignments: [DailyAlignment]
    @Query private var goals: [Goal]
    @State private var displayedMonth: Date = Date()
    
    // Computed properties for statistics
    private var progressMetrics: ProgressMetrics {
        calculateProgressMetrics()
    }
    
    private var activeGoals: [Goal] {
        goals.filter { !$0.isArchived }
    }
    
    // Filter for this week's entries
    private var thisWeekEntries: [DailyAlignment] {
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))
        return alignments.filter { alignment in
            guard let startOfWeek = startOfWeek else { return false }
            return alignment.date >= startOfWeek
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Full screen black background - matching Today page
                Color.black.ignoresSafeArea()
                
                // Custom header with logo, upgrade button and streak counter
                VStack {
                    HStack(spacing: 12) {
                        // HorizonFrame logo
                        Image("horizonframe-logo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 30)
                        
                        Spacer()
                        UpgradeButton()
                        StreakCounterView()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    
                    Spacer()
                }
                
                VStack(spacing: 24) {
                    Spacer(minLength: 60) // Space for header
                    
                    // Simple title - matching Today page style
                    Text("Your Progress")
                        .font(.system(size: 32))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                    
                    // Motivational text
                    Text(motivationalText)
                        .font(.system(size: 18))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                    
                    // Progress content
                    ScrollView {
                        VStack(spacing: 32) {
                            // Simple stats
                            simpleStatsSection
                            
                            // Goals progress
                            if !activeGoals.isEmpty {
                                simpleGoalsSection
                            }
                            
                            // Calendar
                            simpleCalendarSection
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 120)
                    }
                    
                    Spacer()
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .preferredColorScheme(.dark)
            .statusBar(hidden: true)
        }
    }
    
    // MARK: - Simple View Components
    
    // Simple stats section - matching Today page minimalism
    private var simpleStatsSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack {
                    Text("\(progressMetrics.currentStreak)")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white.opacity(0.9))
                    Text("Day Streak")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                VStack {
                    Text("\(progressMetrics.totalEntries)")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white.opacity(0.9))
                    Text("Total Entries")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                VStack {
                    Text("\(activeGoals.count)")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white.opacity(0.9))
                    Text("Active Goals")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
        }
    }
    
    // Simple goals section
    private var simpleGoalsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Goals")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
            
            ForEach(activeGoals.prefix(3)) { goal in
                VStack(alignment: .leading, spacing: 8) {
                    Text(goal.text)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                    
                    let count = alignmentCount(for: goal)
                    if count > 0 {
                        Text("\(count) \(count == 1 ? "day" : "days") aligned")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    
    // Simple calendar section
    private var simpleCalendarSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Activity Calendar")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
            
            SimpleProgressCalendar(alignments: alignments)
        }
    }
    
    // Helper method to count alignments for a goal
    private func alignmentCount(for goal: Goal) -> Int {
        alignments.filter { alignment in
            alignment.goals.contains(where: { $0.id == goal.id })
        }.count
    }
    
    
    
    
    // MARK: - Helper Methods
    
    // Calculate progress metrics
    private func calculateProgressMetrics() -> ProgressMetrics {
        let (currentStreak, longestStreak, total) = calculateStats()
        
        // Calculate time progress (average across all goals)
        var timeProgress: Double = 0.0
        let activeGoalsCount = activeGoals.count
        
        if activeGoalsCount > 0 {
            var totalProgress: Double = 0.0
            for goal in activeGoals {
                let created = goal.createdAt
                if let target = goal.targetDate {
                    let totalDuration = target.timeIntervalSince(created)
                    let elapsedDuration = Date().timeIntervalSince(created)
                    let progress = (elapsedDuration / totalDuration).clamped(to: 0.0...1.0)
                    totalProgress += progress
                }
            }
            timeProgress = totalProgress / Double(activeGoalsCount)
        }
        
        // Calculate entry consistency (entries vs expected entries)
        let entryConsistency = calculateEntryConsistency()
        
        // Calculate average entry length (placeholder)
        let averageEntryLength: TimeInterval = 300 // 5 minutes placeholder
        
        return ProgressMetrics(
            timeProgress: timeProgress,
            entryConsistency: entryConsistency,
            currentStreak: currentStreak,
            longestStreak: longestStreak,
            totalEntries: total,
            averageEntryLength: averageEntryLength,
            milestones: generateMilestones()
        )
    }
    
    // Calculate streak and total stats
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
        for date in sortedDates.map({ Calendar.current.startOfDay(for: $0) }) {
            if let prev = previousDate {
                let dayDiff = Calendar.current.dateComponents([.day], from: date, to: prev).day ?? 0
                if dayDiff == 1 {
                    streak += 1
                } else {
                    streak = 1
                }
            } else {
                streak = 1
            }
            if streak > longestStreak {
                longestStreak = streak
            }
            previousDate = date
        }
        
        return (currentStreak, longestStreak, alignments.count)
    }
    
    // Calculate entry consistency
    private func calculateEntryConsistency() -> Double {
        // Calculate how many days we expect entries for (since first entry or last 30 days)
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        
        guard let firstAlignment = alignments.last else { return 0.0 }
        
        let startDate = calendar.startOfDay(for: firstAlignment.date)
        let daysSinceStart = calendar.dateComponents([.day], from: startDate, to: today).day ?? 0
        
        // Cap at 30 days to avoid penalizing for very old accounts
        let expectedEntries = min(daysSinceStart + 1, 30)
        
        // Count unique days with entries in the last 30 days
        let last30Days = calendar.date(byAdding: .day, value: -30, to: today)!
        let recentAlignments = alignments.filter { $0.date >= last30Days }
        let uniqueDaysWithEntries = Set(recentAlignments.map { calendar.startOfDay(for: $0.date) }).count
        
        return Double(uniqueDaysWithEntries) / Double(expectedEntries)
    }
    
    // Generate milestones based on user progress
    private func generateMilestones() -> [Milestone] {
        let (currentStreak, longestStreak, totalEntries) = calculateStats()
        
        var milestones: [Milestone] = []
        
        // Streak milestones
        milestones.append(Milestone(
            id: "streak3",
            title: "3-Day Streak",
            description: "Aligned for 3 consecutive days",
            icon: "flame",
            isUnlocked: currentStreak >= 3
        ))
        
        milestones.append(Milestone(
            id: "streak7",
            title: "7-Day Streak",
            description: "Aligned for a full week",
            icon: "flame.fill",
            isUnlocked: currentStreak >= 7 || longestStreak >= 7
        ))
        
        milestones.append(Milestone(
            id: "streak30",
            title: "30-Day Streak",
            description: "Aligned for a month straight",
            icon: "star.fill",
            isUnlocked: currentStreak >= 30 || longestStreak >= 30
        ))
        
        // Entry milestones
        milestones.append(Milestone(
            id: "entries10",
            title: "10 Entries",
            description: "Completed 10 journal entries",
            icon: "doc.text",
            isUnlocked: totalEntries >= 10
        ))
        
        milestones.append(Milestone(
            id: "entries50",
            title: "50 Entries",
            description: "Completed 50 journal entries",
            icon: "doc.text.fill",
            isUnlocked: totalEntries >= 50
        ))
        
        // Goal milestones
        milestones.append(Milestone(
            id: "goals3",
            title: "Triple Focus",
            description: "Working on 3 goals simultaneously",
            icon: "target",
            isUnlocked: activeGoals.count >= 3
        ))
        
        return milestones
    }
    
    // Get motivational text based on progress
    private var motivationalText: String {
        let texts = [
            "Every day brings you closer to your goals",
            "Small steps lead to big changes",
            "Your consistency is building momentum",
            "You're making progress, keep going!",
            "Your future self thanks you for today's effort"
        ]
        
        // Select text based on streak or random if no streak
        if progressMetrics.currentStreak > 0 {
            return texts[progressMetrics.currentStreak % texts.count]
        } else {
            return texts[Int.random(in: 0..<texts.count)]
        }
    }
    
    // Calendar helper properties
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: displayedMonth)
    }
    
    private var canGoToNextMonth: Bool {
        let calendar = Calendar.current
        let currentMonth = calendar.startOfDay(for: calendar.date(from: calendar.dateComponents([.year, .month], from: Date()))!)
        return displayedMonth < currentMonth
    }
}

// Simple calendar component for Progress page
struct SimpleProgressCalendar: View {
    let alignments: [DailyAlignment]
    @State private var displayedMonth: Date = Date()
    private let calendar = Calendar.current
    private let weekDays = ["S", "M", "T", "W", "T", "F", "S"]
    
    var body: some View {
        VStack(spacing: 12) {
            // Month navigation
            HStack {
                Button(action: { 
                    displayedMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth)! 
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white.opacity(0.7))
                        .font(.system(size: 16))
                }
                
                Spacer()
                
                Text(monthYearString)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                
                Spacer()
                
                Button(action: { 
                    if canGoToNextMonth {
                        displayedMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth)! 
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(canGoToNextMonth ? .white.opacity(0.7) : .white.opacity(0.3))
                        .font(.system(size: 16))
                }
                .disabled(!canGoToNextMonth)
            }
            
            // Weekday headers
            HStack {
                ForEach(weekDays, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Calendar grid
            let days = daysInMonthGrid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 6) {
                ForEach(days, id: \.self) { day in
                    if let day = day {
                        let isCompleted = completedDays.contains(calendar.startOfDay(for: day))
                        let isFuture = day > calendar.startOfDay(for: .now)
                        
                        ZStack {
                            if isCompleted {
                                Circle()
                                    .fill(Color.white.opacity(0.8))
                                    .frame(width: 28, height: 28)
                            }
                            
                            Text("\(calendar.component(.day, from: day))")
                                .font(.system(size: 14, weight: isCompleted ? .bold : .regular))
                                .foregroundColor(isCompleted ? .black : (isFuture ? .white.opacity(0.3) : .white.opacity(0.7)))
                        }
                        .frame(height: 28)
                    } else {
                        Text("")
                            .frame(height: 28)
                    }
                }
            }
        }
    }
    
    private var completedDays: Set<Date> {
        Set(alignments.filter { $0.completed }.map { calendar.startOfDay(for: $0.date) })
    }
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: displayedMonth)
    }
    
    private var canGoToNextMonth: Bool {
        let currentMonth = calendar.startOfDay(for: calendar.date(from: calendar.dateComponents([.year, .month], from: Date()))!)
        return displayedMonth < currentMonth
    }
    
    private var daysInMonthGrid: [Date?] {
        let range = calendar.range(of: .day, in: .month, for: displayedMonth)!
        let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth))!
        let firstWeekday = calendar.component(.weekday, from: firstOfMonth) - 1
        var days: [Date?] = Array(repeating: nil, count: firstWeekday)
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                days.append(date)
            }
        }
        while days.count % 7 != 0 {
            days.append(nil)
        }
        return days
    }
}

struct AwardCellWithProgress: View {
    let award: Award
    let isUnlocked: Bool
    let totalAlignments: Int
    
    private var daysUntilUnlock: Int? {
        let required = award.requiredAlignments
        if totalAlignments >= required {
            return nil
        }
        return required - totalAlignments
    }
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? Color.yellow : Color.gray.opacity(0.3))
                    .frame(width: 60, height: 60)
                
                Image(systemName: award.iconName)
                    .font(.title2)
                    .foregroundColor(isUnlocked ? .black : .gray)
            }
            
            Text(award.title)
                .font(.caption)
                .foregroundColor(isUnlocked ? .white : .gray)
                .multilineTextAlignment(.center)
            
            if let daysUntil = daysUntilUnlock {
                Text("in \(daysUntil) \(daysUntil == 1 ? "day" : "days")")
                    .font(.caption2)
                    .foregroundColor(.blue)
            } else if isUnlocked {
                Text("Unlocked!")
                    .font(.caption2)
                    .foregroundColor(.green)
            }
        }
        .frame(width: 100, height: 120)
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

// Calendar view for the progress page
struct ProgressCalendarView: View {
    let alignments: [DailyAlignment]
    // Removed onDaySelected
    @State private var displayedMonth: Date = Calendar.current.startOfMonth(for: .now)
    private let calendar = Calendar.current
    private let weekDays = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
    
    var body: some View {
        VStack(spacing: 12) {
            // Month navigation
            HStack {
                Button(action: { displayedMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth)! }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                        .opacity(canGoToPreviousMonth ? 1 : 0.5)
                }
                .disabled(!canGoToPreviousMonth)
                
                Spacer()
                Text(monthYearString)
                    .font(.headline).bold()
                    .foregroundColor(.white)
                Spacer()
                Button(action: { displayedMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth)! }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(canGoToNextMonth ? .white : .gray)
                }
                .disabled(!canGoToNextMonth)
            }
            .padding(.horizontal, 8)
            
            // Weekday headers
            HStack {
                ForEach(weekDays, id: \.self) { day in
                    Text(day)
                        .font(.caption2).bold()
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Calendar grid
            let days = daysInMonthGrid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(days, id: \.self) { day in
                    if let day = day {
                        let isCompleted = completedDays.contains(calendar.startOfDay(for: day))
                        let isFuture = day > calendar.startOfDay(for: .now)
                        NavigationLink(destination: DayDetailView(selectedDate: day)) {
                            ZStack {
                                if isCompleted {
                                    Capsule()
                                        .fill(Color.green.opacity(0.7))
                                        .frame(height: 28)
                                }
                                Text("\(calendar.component(.day, from: day))")
                                    .font(.body).bold()
                                    .foregroundColor(isCompleted ? .white : (isFuture ? .gray : .gray))
                            }
                            .frame(height: 28)
                        }
                        .buttonStyle(.plain)
                    } else {
                        Text("")
                            .frame(height: 28)
                    }
                }
            }
        }
        .onAppear {
            displayedMonth = calendar.startOfMonth(for: .now)
        }
    }
    
    private var completedDays: Set<Date> {
        Set(alignments.filter { $0.completed }.map { calendar.startOfDay(for: $0.date) })
    }
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: displayedMonth)
    }
    
    private var canGoToNextMonth: Bool {
        calendar.isDate(displayedMonth, equalTo: .now, toGranularity: .month) == false && displayedMonth < calendar.startOfMonth(for: .now)
    }
    private var canGoToPreviousMonth: Bool { true }
    
    private var daysInMonthGrid: [Date?] {
        let range = calendar.range(of: .day, in: .month, for: displayedMonth)!
        let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth))!
        let firstWeekday = calendar.component(.weekday, from: firstOfMonth) - 1 // 0-based
        var days: [Date?] = Array(repeating: nil, count: firstWeekday)
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                days.append(date)
            }
        }
        // Pad to fill last week
        while days.count % 7 != 0 {
            days.append(nil)
        }
        return days
    }
}

// Helper extension for startOfMonth
extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        let components = dateComponents([.year, .month], from: date)
        return self.date(from: components)!
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
