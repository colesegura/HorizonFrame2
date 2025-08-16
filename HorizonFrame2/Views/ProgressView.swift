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
                // Gradient background
                LinearGradient(
                    gradient: Gradient(colors: [Color.black, Color(hex: "1A1A2E")]),
                    startPoint: .top,
                    endPoint: .bottom
                ).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Header Section with gradient and progress ring
                        headerSection
                        
                        // Statistics Dashboard
                        statisticsDashboard
                        
                        // Goal Cards Section
                        goalCardsSection
                        
                        // Milestone Celebrations
                        milestonesSection
                        
                        // Calendar Heat Map
                        calendarHeatMapSection
                        
                        // Awards section (keeping for backward compatibility)
                        awardsSection
                        
                    }
                    .padding()
                    .padding(.bottom, 100)
                }
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: 80)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 12) {
                        UpgradeButton()
                        StreakCounterView()
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    // MARK: - View Components
    
    // Header Section with Progress Ring and Motivational Text
    private var headerSection: some View {
        VStack(spacing: 20) {
            // Header text
            VStack(spacing: 8) {
                Text("Your Journey")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                Text(motivationalText)
                    .font(.system(size: 18))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            
            // Progress Ring
            ProgressRingView(progress: progressMetrics.timeProgress)
                .padding(.vertical, 10)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color(hex: "1A1A2E"), Color(hex: "16213E")]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
    }
    
    // Statistics Dashboard with Weekly Stats
    private var statisticsDashboard: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("This Week")
                .font(.headline)
                .foregroundColor(.white)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                StatBox(value: "\(progressMetrics.currentStreak)", label: "Day Streak")
                StatBox(value: "\(thisWeekEntries.count)", label: "Entries")
                StatBox(value: "\(activeGoals.count)", label: "Active Goals")
                StatBox(value: "\(Int(progressMetrics.entryConsistency * 100))%", label: "Consistency")
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(hex: "1A1A2E").opacity(0.5))
        )
    }
    
    // Goal Cards Section
    private var goalCardsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Your Goals")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                NavigationLink(destination: Text("All Goals")) {
                    Text("See All")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            
            if activeGoals.isEmpty {
                emptyGoalsView
            } else {
                VStack(spacing: 15) {
                    ForEach(activeGoals.prefix(3)) { goal in
                        GoalProgressCard(goal: goal, alignments: alignments)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(hex: "1A1A2E").opacity(0.5))
        )
    }
    
    // Empty Goals View
    private var emptyGoalsView: some View {
        VStack(spacing: 20) {
            Image(systemName: "target")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            
            Text("No active goals")
                .font(.headline)
                .foregroundColor(.white)
            
            Text("Create goals to track your progress and stay aligned with your vision")
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            NavigationLink(destination: Text("Create Goal")) {
                Text("Create Goal")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.blue)
                    )
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
    }
    
    // Milestones Section
    private var milestonesSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Milestones")
                .font(.headline)
                .foregroundColor(.white)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(progressMetrics.milestones) { milestone in
                        MilestoneCard(milestone: milestone)
                    }
                }
                .padding(.horizontal, 4)
                .padding(.bottom, 4)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(hex: "1A1A2E").opacity(0.5))
        )
    }
    
    // Awards Section
    private var awardsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Awards")
                .font(.headline)
                .foregroundColor(.white)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 140, maximum: 180))], spacing: 28) {
                ForEach(Award.allAwards, id: \.id) { award in
                    AwardCellWithProgress(award: award, isUnlocked: progressMetrics.totalEntries >= award.requiredAlignments, totalAlignments: progressMetrics.totalEntries)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(hex: "1A1A2E").opacity(0.5))
        )
    }
    
    // Calendar Heat Map Section
    private var calendarHeatMapSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Activity Calendar")
                .font(.headline)
                .foregroundColor(.white)
            
            ProgressCalendarView(alignments: alignments)
            
            HStack {
                Button(action: {
                    withAnimation {
                        displayedMonth = Calendar.current.date(byAdding: .month, value: -1, to: displayedMonth)!
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Text(monthYearString)
                    .font(.subheadline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        if canGoToNextMonth {
                            displayedMonth = Calendar.current.date(byAdding: .month, value: 1, to: displayedMonth)!
                        }
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(canGoToNextMonth ? .white : .gray)
                }
                .disabled(!canGoToNextMonth)
            }
            .padding(.horizontal)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(hex: "1A1A2E").opacity(0.5))
        )
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
