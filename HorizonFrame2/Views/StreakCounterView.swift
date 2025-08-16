import SwiftUI
import SwiftData

struct StreakCounterView: View {
    @Query(sort: \DailyAlignment.date, order: .reverse) private var alignments: [DailyAlignment]
    
    private var currentStreak: Int {
        var streak = 0
        let sortedDates = alignments.map { $0.date }.sorted { $0 > $1 }
        let today = Calendar.current.startOfDay(for: .now)
        
        // Check if aligned today without using isDate(_:inSameDayAs:)
        let hasAlignedToday = alignments.contains { alignment in
            let alignmentDay = Calendar.current.startOfDay(for: alignment.date)
            return alignmentDay == today
        }
        
        var currentDate = hasAlignedToday ? today : Calendar.current.date(byAdding: .day, value: -1, to: today)!
        
        for date in sortedDates {
            // Compare dates manually instead of using isDate(_:inSameDayAs:)
            let dateDay = Calendar.current.startOfDay(for: date)
            if dateDay == currentDate {
                streak += 1
                currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate)!
            } else {
                break
            }
        }
        return streak
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "flame.fill")
                .foregroundColor(.orange)
            Text("\(currentStreak)")
                .font(.system(.headline, design: .rounded).bold())
                .foregroundColor(.white)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(20)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: DailyAlignment.self, configurations: config)
    container.mainContext.insert(DailyAlignment(date: .now, completed: true))
    
    return StreakCounterView()
        .modelContainer(container)
        .background(Color.black)
}
