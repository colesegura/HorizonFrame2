import SwiftUI
import SwiftData

struct ProgressView: View {
    @Query(sort: \DailyAlignment.date, order: .reverse) private var alignments: [DailyAlignment]
    // Removed selectedDate and isShowingDayDetail
    
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
                        
                        // Streak Counter at the top
                        VStack(spacing: 4) {
                            Text("\(stats.currentStreak) Day Streak")
                                .font(.title2).bold()
                                .foregroundColor(.white)
                            Text("Days in a row you've aligned.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 10)

                        // Timeline section
                        TimelineView()

                        // Calendar in a rounded box
                        CalendarMonthView(alignments: alignments)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            .background(Color.clear.cornerRadius(20)))
                        .padding(.bottom, 10)

                        // Awards section in a rounded box
                        let unlockedAwardIDs: Set<String> = [] // TODO: Replace with real unlocked award IDs
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Awards")
                                .font(.headline)
                                .foregroundColor(.white)
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 140, maximum: 180))], spacing: 28) {
                                ForEach(Award.allAwards, id: \.id) { award in
                                    AwardCellWithProgress(award: award, isUnlocked: unlockedAwardIDs.contains(award.id), totalAlignments: alignments.count)
                                }
                            }
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            .background(Color.clear.cornerRadius(20)))
                        
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

// Replace CalendarHeatmapView with CalendarMonthView
// Add a placeholder for CalendarMonthView
struct CalendarMonthView: View {
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
