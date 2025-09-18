import SwiftUI
import SwiftData

struct DayDetailView: View {
    @State var selectedDate: Date
    @Query private var allAlignments: [DailyAlignment]
    @Query private var allJournalEntries: [JournalEntry]
    @Query private var allDailyReviews: [DailyReview]
    @Query private var allWeeklyReviews: [WeeklyReview]
    private let calendar = Calendar.current
    
    init(selectedDate: Date) {
        self.selectedDate = selectedDate
    }
    
    // Filtered data based on current selectedDate
    private var alignmentsForSelectedDate: [DailyAlignment] {
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        return allAlignments.filter { $0.date >= startOfDay && $0.date < endOfDay }
    }
    
    private var journalEntriesForSelectedDate: [JournalEntry] {
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        return allJournalEntries.filter { $0.date >= startOfDay && $0.date < endOfDay }
    }
    
    private var dailyReviewsForSelectedDate: [DailyReview] {
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        return allDailyReviews.filter { $0.date >= startOfDay && $0.date < endOfDay && !$0.isWeeklyReview }
    }
    
    private var weeklyReviewsForSelectedDate: [WeeklyReview] {
        return allWeeklyReviews.filter { $0.startDate <= selectedDate && $0.endDate >= selectedDate }
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Weekly Date Selector
                    WeeklyDateSelector(selectedDate: $selectedDate)
                        .padding(.top, 8)
                    // Day navigation arrows and date
                    HStack {
                        Button(action: { selectedDate = calendar.date(byAdding: .day, value: -1, to: selectedDate)! }) {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                        Spacer()
                        Text(formattedDate)
                            .font(.title2).bold()
                            .foregroundColor(.white)
                        Spacer()
                        Button(action: { selectedDate = calendar.date(byAdding: .day, value: 1, to: selectedDate)! }) {
                            Image(systemName: "chevron.right")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.top, 20)
                    
                    // Show all session data for the selected date
                    VStack(spacing: 24) {
                        // Daily Alignment Section
                        alignmentSection
                        
                        // Daily Review Section
                        dailyReviewSection
                        
                        // Weekly Review Section
                        weeklyReviewSection
                    }
                    
                    Spacer()
                }
                .padding()
            }
        }
        .navigationTitle("Day Details")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
        .onAppear {
            print("[DEBUG] alignments for \(formattedDate): \(allAlignments.count)")
            for a in allAlignments {
                print("[DEBUG] alignment: \(a.date) completed: \(a.completed) goals: \(a.goals.map { $0.text })")
            }
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: selectedDate)
    }
    
    // Computed property for the alignment for the selected date
    private var alignmentForSelectedDate: DailyAlignment? {
        return alignmentsForSelectedDate.first
    }
    
    // MARK: - Section Views
    
    // Daily Alignment Section
    private var alignmentSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Daily Alignment")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            let journalEntries = journalEntriesForSelectedDate
            let alignments = alignmentsForSelectedDate
            
            if !journalEntries.isEmpty {
                Text("\(journalEntries.count) Alignment\(journalEntries.count > 1 ? "s" : "") Completed")
                    .font(.headline)
                    .foregroundColor(.green)
                    
                ForEach(journalEntries) { entry in
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(entry.goal?.text ?? "Goal")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Prompt:")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            Text(entry.prompt)
                                .font(.body)
                                .foregroundColor(.white)
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.purple.opacity(0.2))
                                .cornerRadius(10)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Response:")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            Text(entry.response)
                                .font(.body)
                                .foregroundColor(.white)
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(12)
                }
            } else if let alignment = alignments.first, alignment.completed {
                Text("Alignment Completed")
                    .font(.headline)
                    .foregroundColor(.green)
                if !alignment.goals.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Goals aligned with:")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                        ForEach(alignment.goals, id: \.id) { goal in
                            HStack {
                                Text(goal.text)
                                    .font(.body)
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                                Spacer()
                            }
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(12)
                }
            } else if let alignment = alignments.first, !alignment.completed {
                Text("Alignment Started but Not Completed")
                    .font(.headline)
                    .foregroundColor(.yellow)
            } else {
                Text("No alignment data for this day")
                    .font(.body)
                    .foregroundColor(.gray)
            }
        }
    }
    
    // Daily Review Section
    private var dailyReviewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Daily Review")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            let dailyReviews = dailyReviewsForSelectedDate
            
            if !dailyReviews.isEmpty {
                ForEach(dailyReviews, id: \.date) { review in
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Daily Review Completed")
                                .font(.headline)
                                .foregroundColor(.green)
                            
                            Spacer()
                            
                            Text(review.date.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        if review.overallScore > 0 {
                            HStack {
                                Text("Overall Score:")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Text("\(review.overallScore)/10")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Spacer()
                            }
                        }
                        
                        if !review.principleReviews.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Principle Reviews:")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                ForEach(review.principleReviews, id: \.id) { principleReview in
                                    VStack(alignment: .leading, spacing: 6) {
                                        HStack {
                                            Text(principleReview.principle?.text ?? "Principle")
                                                .font(.body)
                                                .foregroundColor(.white)
                                            Spacer()
                                            Text("\(principleReview.score)/10")
                                                .font(.body)
                                                .fontWeight(.bold)
                                                .foregroundColor(principleReview.score >= 7 ? .green : principleReview.score >= 4 ? .orange : .red)
                                        }
                                        
                                        if !principleReview.reflectionText.isEmpty {
                                            Text(principleReview.reflectionText)
                                                .font(.body)
                                                .foregroundColor(.white.opacity(0.8))
                                                .padding(8)
                                                .background(Color.gray.opacity(0.2))
                                                .cornerRadius(8)
                                        }
                                    }
                                    .padding(8)
                                    .background(Color.white.opacity(0.03))
                                    .cornerRadius(8)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(12)
                }
            } else {
                Text("No daily review data for this day")
                    .font(.body)
                    .foregroundColor(.gray)
            }
        }
    }
    
    // Weekly Review Section
    private var weeklyReviewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Weekly Review")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            if !weeklyReviewsForSelectedDate.isEmpty {
                ForEach(weeklyReviewsForSelectedDate, id: \.startDate) { weeklyReview in
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Weekly Review Completed")
                                .font(.headline)
                                .foregroundColor(.green)
                            
                            Spacer()
                            
                            Text("\(formatDateRange(start: weeklyReview.startDate, end: weeklyReview.endDate))")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Reflection:")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            Text(weeklyReview.reflectionText)
                                .font(.body)
                                .foregroundColor(.white)
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(10)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Goals for Next Week:")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            Text(weeklyReview.goalsForNextWeek)
                                .font(.body)
                                .foregroundColor(.white)
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.green.opacity(0.2))
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(12)
                }
            } else {
                Text("No weekly review data for this week")
                    .font(.body)
                    .foregroundColor(.gray)
            }
        }
    }
    
    // Helper function to format date range
    private func formatDateRange(start: Date, end: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
    }
    
    // Week navigation view
    private var weekNavigation: some View {
        let weekDays = daysOfWeek(for: selectedDate)
        return HStack(spacing: 12) {
            ForEach(weekDays, id: \.self) { day in
                let isSelected = calendar.isDate(day, inSameDayAs: selectedDate)
                VStack {
                    Button(action: { selectedDate = day }) {
                        Circle()
                            .fill(isSelected ? Color.green : Color.gray.opacity(0.3))
                            .frame(width: 36, height: 36)
                            .overlay(
                                Text("\(calendar.component(.day, from: day))")
                                    .font(.headline)
                                    .foregroundColor(isSelected ? .white : .gray)
                            )
                    }
                    .buttonStyle(.plain)
                    Text(shortWeekdayString(for: day))
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.top, 24)
    }
    // Helper: get all days in the week of the selected date
    private func daysOfWeek(for date: Date) -> [Date] {
        let weekday = calendar.component(.weekday, from: date)
        let startOfWeek = calendar.date(byAdding: .day, value: -(weekday - calendar.firstWeekday), to: calendar.startOfDay(for: date))!
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
    }
    private func shortWeekdayString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: DailyAlignment.self, configurations: config)
    let calendar = Calendar.current
    let sampleDate = calendar.startOfDay(for: .now)
    
    // Sample alignment
    let alignment = DailyAlignment(date: sampleDate, completed: true)
    container.mainContext.insert(alignment)
    
    return NavigationStack {
        DayDetailView(selectedDate: sampleDate)
    }
    .modelContainer(container)
}
