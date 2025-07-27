import SwiftUI
import SwiftData

struct DayDetailView: View {
    @State var selectedDate: Date
    @Query private var allAlignments: [DailyAlignment]
    private let calendar = Calendar.current
    
    init(selectedDate: Date) {
        self.selectedDate = selectedDate
        // Filter alignments to only include the selected date
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        self._allAlignments = Query(FetchDescriptor<DailyAlignment>(
            predicate: #Predicate { alignment in
                alignment.date >= startOfDay && alignment.date < endOfDay
            },
            sortBy: [SortDescriptor(\DailyAlignment.date, order: .reverse)]
        ))
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Week navigation strip
                    weekNavigation
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
                    
                    if let alignment = alignmentForSelectedDate {
                        if alignment.completed {
                            Text("Alignment Completed")
                                .font(.title2)
                                .foregroundColor(.green)
                            if !alignment.goals.isEmpty {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Goals aligned with:")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    ForEach(alignment.goals, id: \.id) { goal in
                                        HStack {
                                            Text(goal.text)
                                                .font(.body)
                                                .foregroundColor(.white)
                                                .padding(8)
                                                .background(Color.gray.opacity(0.2))
                                                .cornerRadius(10)
                                            Spacer()
                                            Text("\(alignmentCount(for: goal)) \(alignmentCount(for: goal) == 1 ? "day" : "days") aligned")
                                                .font(.caption)
                                                .foregroundColor(.green)
                                        }
                                    }
                                }
                                .padding(.top, 10)
                            } else {
                                Text("No goals recorded for this day.")
                                    .foregroundColor(.gray)
                            }
                        } else {
                            Text("Alignment Started but Not Completed")
                                .font(.title2)
                                .foregroundColor(.yellow)
                        }
                    } else {
                        Text("No alignment data for this day.")
                            .font(.title2)
                            .foregroundColor(.gray)
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
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        return allAlignments.first(where: { $0.date >= startOfDay && $0.date < endOfDay })
    }
    // Count how many days a goal has been aligned with (across all time)
    private func alignmentCount(for goal: Goal) -> Int {
        allAlignments.filter { alignment in
            alignment.goals.contains(where: { $0.id == goal.id })
        }.count
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
