import SwiftUI
import SwiftData

struct ProgressView: View {
    @Query(sort: \DailyAlignment.date, order: .reverse) private var alignments: [DailyAlignment]
    @Query private var goals: [Goal]
    @Query private var userInterests: [UserInterest]
    @Query(sort: \JournalSession.date, order: .reverse) private var journalSessions: [JournalSession]
    @State private var displayedMonth: Date = Date()
    @State private var selectedDate: Date = Date()
    @State private var selectedTab: ProgressTab = .overview
    
    // Computed properties for statistics
    private var progressMetrics: ProgressMetrics {
        calculateProgressMetrics()
    }
    
    private var activeGoals: [Goal] {
        goals.filter { !$0.isArchived }
    }
    
    private var activeInterests: [UserInterest] {
        userInterests.filter { $0.isActive }
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
                    
                    // Weekly Date Selector
                    WeeklyDateSelector(selectedDate: $selectedDate)
                        .padding(.top, 8)
                    
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
                    
                    // Tab selector
                    HStack(spacing: 0) {
                        ForEach(ProgressTab.allCases, id: \.self) { tab in
                            Button(action: { selectedTab = tab }) {
                                Text(tab.rawValue)
                                    .font(.system(size: 16, weight: selectedTab == tab ? .semibold : .regular))
                                    .foregroundColor(selectedTab == tab ? .white : .white.opacity(0.6))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(selectedTab == tab ? Color.white.opacity(0.2) : Color.clear)
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
                    
                    ScrollView {
                        VStack(spacing: 32) {
                            switch selectedTab {
                            case .overview:
                                overviewContent
                            case .interests:
                                interestsContent
                            case .calendar:
                                calendarContent
                            }
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
    
    // MARK: - Tab Content
    
    private var overviewContent: some View {
        VStack(spacing: 32) {
            // Simple stats
            simpleStatsSection
            
            // Goals progress
            if !activeGoals.isEmpty {
                simpleGoalsSection
            }
            
            // Interest overview
            if !activeInterests.isEmpty {
                interestOverviewSection
            }
        }
    }
    
    private var interestsContent: some View {
        VStack(spacing: 32) {
            if activeInterests.isEmpty {
                emptyInterestsSection
            } else {
                ForEach(activeInterests) { interest in
                    InterestProgressCard(interest: interest, journalSessions: journalSessions)
                }
            }
        }
    }
    
    private var calendarContent: some View {
        VStack(spacing: 32) {
            // Full Month Calendar
            fullMonthCalendarSection
            
            // Selected Date Details
            selectedDateDetailsSection
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
                    Text("\(totalJournalSessions)")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white.opacity(0.9))
                    Text("Journal Sessions")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                VStack {
                    Text("\(activeInterests.count)")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white.opacity(0.9))
                    Text("Active Interests")
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
    
    // Full month calendar section
    private var fullMonthCalendarSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Activity Calendar")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
            
            ClickableProgressCalendar(alignments: alignments, selectedDate: $selectedDate)
        }
    }
    
    // Selected date details section
    private var selectedDateDetailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Details for \(formattedSelectedDate)")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
            
            NavigationLink(destination: DayDetailView(selectedDate: selectedDate)) {
                HStack {
                    Text("View Full Details")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.1))
                )
            }
        }
    }
    
    private var totalJournalSessions: Int {
        journalSessions.filter { $0.completed }.count
    }
    
    // Interest overview section
    private var interestOverviewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Interest Progress")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
            
            ForEach(activeInterests.prefix(3)) { interest in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(interest.displayName)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text("Level \(interest.currentLevel)/10")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    
                    Spacer()
                    
                    // Recent average score
                    if let avgScore = getRecentAverageScore(for: interest) {
                        VStack {
                            Text("\(avgScore, specifier: "%.1f")")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(scoreColor(avgScore))
                            Text("avg")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }
                }
                .padding(.vertical, 8)
            }
            
            if activeInterests.count > 3 {
                Text("+ \(activeInterests.count - 3) more interests")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.5))
            }
        }
    }
    
    // Empty interests section
    private var emptyInterestsSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "target")
                .font(.system(size: 48))
                .foregroundColor(.white.opacity(0.3))
            
            Text("No Active Interests")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
            
            Text("Complete the onboarding flow to set up your interests and start tracking progress.")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.5))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding(.vertical, 40)
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
    
    // Formatted selected date
    private var formattedSelectedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: selectedDate)
    }
    
    // Get motivational text based on progress
    private var motivationalText: String {
        if !activeInterests.isEmpty {
            let interestTexts = [
                "Your interests are shaping your future",
                "Every reflection builds self-awareness",
                "Progress in small areas creates big changes",
                "Your journey of growth continues",
                "Consistency in your interests pays off"
            ]
            return interestTexts[Int.random(in: 0..<interestTexts.count)]
        } else {
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
    }
    
    // Helper methods for interest tracking
    private func getRecentAverageScore(for interest: UserInterest) -> Double? {
        let recentSessions = journalSessions
            .filter { $0.userInterest?.id == interest.id && $0.progressScore != nil }
            .prefix(7) // Last 7 sessions
        
        guard !recentSessions.isEmpty else { return nil }
        
        let totalScore = recentSessions.compactMap { $0.progressScore }.reduce(0, +)
        return Double(totalScore) / Double(recentSessions.count)
    }
    
    private func scoreColor(_ score: Double) -> Color {
        switch score {
        case 8...10: return .green
        case 6..<8: return .yellow
        case 4..<6: return .orange
        default: return .red
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

// Progress tab enum
enum ProgressTab: String, CaseIterable {
    case overview = "Overview"
    case interests = "Interests"
    case calendar = "Calendar"
}

// Interest progress card component
struct InterestProgressCard: View {
    let interest: UserInterest
    let journalSessions: [JournalSession]
    
    private var recentSessions: [JournalSession] {
        journalSessions
            .filter { $0.userInterest?.id == interest.id }
            .prefix(30) // Last 30 sessions
            .sorted { $0.date < $1.date }
    }
    
    private var weeklyScores: [Double] {
        let calendar = Calendar.current
        let today = Date()
        var scores: [Double] = []
        
        for weekOffset in (0..<4).reversed() {
            let weekStart = calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: today)!
            let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart)!
            
            let weekSessions = recentSessions.filter { session in
                session.date >= weekStart && session.date <= weekEnd
            }
            
            if !weekSessions.isEmpty {
                let avgScore = weekSessions.compactMap { $0.progressScore }.reduce(0, +) / weekSessions.count
                scores.append(Double(avgScore))
            } else {
                scores.append(0)
            }
        }
        
        return scores
    }
    
    private var currentAverage: Double {
        let recentScores = recentSessions.prefix(7).compactMap { $0.progressScore }
        guard !recentScores.isEmpty else { return 0 }
        return Double(recentScores.reduce(0, +)) / Double(recentScores.count)
    }
    
    private var trend: String {
        guard weeklyScores.count >= 2 else { return "stable" }
        let recent = weeklyScores.suffix(2)
        let change = recent.last! - recent.first!
        
        if change > 0.5 { return "improving" }
        else if change < -0.5 { return "declining" }
        else { return "stable" }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(interest.displayName)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text("Level \(interest.currentLevel)/10")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(currentAverage, specifier: "%.1f")/10")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(scoreColor(currentAverage))
                    
                    Text(trend)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(trendColor)
                }
            }
            
            // Progress bar for current level
            VStack(alignment: .leading, spacing: 8) {
                Text("Progress to Level \(interest.currentLevel + 1)")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.2))
                            .frame(height: 8)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .frame(width: geometry.size.width * levelProgress, height: 8)
                    }
                }
                .frame(height: 8)
            }
            
            // Weekly trend chart
            if !weeklyScores.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("4-Week Trend")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                    
                    HStack(alignment: .bottom, spacing: 4) {
                        ForEach(Array(weeklyScores.enumerated()), id: \.offset) { index, score in
                            VStack {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(scoreColor(score))
                                    .frame(width: 12, height: max(4, score * 3))
                                
                                Text("W\(index + 1)")
                                    .font(.system(size: 10))
                                    .foregroundColor(.white.opacity(0.5))
                            }
                        }
                        
                        Spacer()
                    }
                }
            }
            
            // Session count
            Text("\(recentSessions.count) sessions completed")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.5))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
        )
    }
    
    private var levelProgress: Double {
        // Calculate progress within current level based on recent performance
        let recentAvg = currentAverage
        let targetForNextLevel = 7.0 // Need 7+ average to advance
        return min(1.0, recentAvg / targetForNextLevel)
    }
    
    private func scoreColor(_ score: Double) -> Color {
        switch score {
        case 8...10: return .green
        case 6..<8: return .yellow
        case 4..<6: return .orange
        default: return .red
        }
    }
    
    private var trendColor: Color {
        switch trend {
        case "improving": return .green
        case "declining": return .red
        default: return .white.opacity(0.6)
        }
    }
}

// Clickable calendar component for Progress page
struct ClickableProgressCalendar: View {
    let alignments: [DailyAlignment]
    @Binding var selectedDate: Date
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
                        let isSelected = calendar.isDate(day, inSameDayAs: selectedDate)
                        
                        NavigationLink(destination: DayDetailView(selectedDate: day)) {
                            ZStack {
                                if isSelected {
                                    Circle()
                                        .fill(Color.white.opacity(0.3))
                                        .frame(width: 32, height: 32)
                                } else if isCompleted {
                                    Circle()
                                        .fill(Color.white.opacity(0.8))
                                        .frame(width: 28, height: 28)
                                }
                                
                                Text("\(calendar.component(.day, from: day))")
                                    .font(.system(size: 14, weight: isCompleted ? .bold : .regular))
                                    .foregroundColor(isSelected ? .white : (isCompleted ? .black : (isFuture ? .white.opacity(0.3) : .white.opacity(0.7))))
                            }
                            .frame(height: 32)
                        }
                        .buttonStyle(.plain)
                    } else {
                        Text("")
                            .frame(height: 32)
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
