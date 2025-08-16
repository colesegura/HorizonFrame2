import SwiftUI
import SwiftData

struct CalendarMonthView: View {
    let month: Date
    let alignments: [DailyAlignment]
    
    private let daysInWeek = 7
    private let calendar = Calendar.current
    
    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: month)
    }
    
    private var days: [Date?] {
        let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: month))!
        
        let firstWeekday = calendar.component(.weekday, from: monthStart)
        let offsetDays = firstWeekday - calendar.firstWeekday
        
        let daysInMonth = calendar.range(of: .day, in: .month, for: monthStart)!.count
        
        var days = [Date?]()
        
        // Add empty cells for days before the first of the month
        for _ in 0..<offsetDays {
            days.append(nil)
        }
        
        // Add days of the month
        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: monthStart) {
                days.append(date)
            }
        }
        
        // Add empty cells to complete the last week
        let remainingCells = (daysInWeek - (days.count % daysInWeek)) % daysInWeek
        for _ in 0..<remainingCells {
            days.append(nil)
        }
        
        return days
    }
    
    private func hasAlignment(for date: Date) -> Bool {
        alignments.contains { calendar.isDate($0.date, inSameDayAs: date) }
    }
    
    private func activityIntensity(for date: Date) -> Double {
        // Count how many alignments happened on this date
        let count = alignments.filter { calendar.isDate($0.date, inSameDayAs: date) }.count
        
        // Map count to intensity (0.0 to 1.0)
        switch count {
        case 0: return 0.0
        case 1: return 0.3
        case 2: return 0.6
        default: return 1.0
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Month title
            Text(monthTitle)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.bottom, 4)
            
            // Day headers
            HStack(spacing: 4) {
                ForEach(0..<daysInWeek, id: \.self) { index in
                    Text(dayOfWeekLetter(for: index))
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: daysInWeek), spacing: 4) {
                ForEach(0..<days.count, id: \.self) { index in
                    if let date = days[index] {
                        let intensity = activityIntensity(for: date)
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(intensity > 0 ? Color.purple.opacity(intensity) : Color.gray.opacity(0.1))
                                .aspectRatio(1, contentMode: .fit)
                            
                            Text("\(calendar.component(.day, from: date))")
                                .font(.caption2)
                                .foregroundColor(intensity > 0 ? .white : .gray)
                        }
                    } else {
                        // Empty cell
                        Color.clear
                            .aspectRatio(1, contentMode: .fit)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "1A1A2E").opacity(0.5))
        )
    }
    
    private func dayOfWeekLetter(for index: Int) -> String {
        let weekdaySymbols = calendar.shortWeekdaySymbols
        let adjustedIndex = (index + calendar.firstWeekday - 1) % 7
        return String(weekdaySymbols[adjustedIndex].prefix(1))
    }
}

struct CalendarMonthView_Previews: PreviewProvider {
    static var previews: some View {
        let calendar = Calendar.current
        let today = Date()
        
        // Generate some sample alignments
        var sampleAlignments: [DailyAlignment] = []
        for i in 0..<30 {
            if [2, 5, 6, 9, 12, 15, 18, 19, 20, 25, 26].contains(i) {
                if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                    let alignment = DailyAlignment(date: date, completed: true)
                    sampleAlignments.append(alignment)
                    
                    // Add multiple entries for some days
                    if [5, 15, 26].contains(i) {
                        let extraAlignment = DailyAlignment(date: date, completed: true)
                        sampleAlignments.append(extraAlignment)
                    }
                    if [15].contains(i) {
                        let extraAlignment = DailyAlignment(date: date, completed: true)
                        sampleAlignments.append(extraAlignment)
                    }
                }
            }
        }
        
        return CalendarMonthView(month: today, alignments: sampleAlignments)
            .frame(width: 350)
            .padding()
            .background(Color.black)
    }
}
