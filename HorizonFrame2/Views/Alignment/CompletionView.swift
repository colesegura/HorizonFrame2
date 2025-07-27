import SwiftUI
import SwiftData

struct CompletionView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DailyAlignment.date, order: .reverse) private var alignments: [DailyAlignment]
    let alignedGoals: [Goal] // The goals that were part of this alignment
    
    @Environment(\.dismiss) private var dismiss
    @State private var streakCount = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background color
                Color.black.ignoresSafeArea()
                
                // Main content
                VStack(spacing: 40) {
                    Spacer()

                    Text("Good Job!\nYou've completed your Daily Alignment")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineSpacing(8)

                    StreakView(streakCount: streakCount, alignments: alignments)

                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal)
                .zIndex(1)
                
                // Dismiss Button - Separate layer with higher z-index
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: { dismiss() }) {
                            ZStack {
                                Circle().fill(Color.white).frame(width: 60, height: 60)
                                Image(systemName: "xmark")
                                    .font(.title)
                                    .foregroundColor(.black)
                            }
                        }
                        .padding(.horizontal, 30)
                    }
                    .padding(.bottom, geometry.safeAreaInsets.bottom + 110) // Increased padding further to ensure complete visibility
                }
                .zIndex(2) // Ensure button is above other content
            }
            .ignoresSafeArea(edges: .bottom) // Ignore safe area for the entire view
        }
        .onAppear(perform: completeAlignment)
    }
    
    private func completeAlignment() {
        let today = Calendar.current.startOfDay(for: .now)
        
        // Check if today's alignment is already saved
        if !alignments.contains(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
            // Use the alignedGoals passed from the current session
            let newAlignment = DailyAlignment(date: today, completed: true, goals: alignedGoals)
            modelContext.insert(newAlignment)
            try? modelContext.save()
            // Debug: print all alignments and their goals after saving
            let allAlignments = (try? modelContext.fetch(FetchDescriptor<DailyAlignment>())) ?? []
            print("[DEBUG] All alignments after save:")
            for a in allAlignments {
                print("[DEBUG] alignment: \(a.date) completed: \(a.completed) goals: \(a.goals.map { $0.text })")
            }
        }
        
        calculateStreak()
        
        // Check for awards
        let awardManager = AwardManager(modelContext: modelContext)
        // Note: You might need to fetch the total number of goals differently now
        // For now, we'll pass 0 and assume it's handled elsewhere
        awardManager.checkAllAwards(stats: (currentStreak: streakCount, longestStreak: 0, total: alignments.count + 1), totalFocuses: 0) 
    }
    
    private func calculateStreak() {
        var currentStreak = 0
        let sortedAlignments = alignments.sorted { $0.date > $1.date }
        var currentDate = Calendar.current.startOfDay(for: .now)

        for alignment in sortedAlignments {
            if Calendar.current.isDate(alignment.date, inSameDayAs: currentDate) {
                currentStreak += 1
                currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate)!
            } else {
                // Break if there's a gap in the streak
                break
            }
        }
        streakCount = currentStreak
    }
}

struct StreakView: View {
    let streakCount: Int
    let alignments: [DailyAlignment]
    
    var body: some View {
        VStack {
            Text("\(streakCount) DAY STREAK")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .padding(.bottom, 16)
            
            HStack(spacing: 16) {
                // Display days in correct order: today, yesterday, etc.
                ForEach([0, 1, 2, 3, 4], id: \.self) { i in
                    DayCircleView(dayIndex: i, alignments: alignments)
                }
            }
        }
        .padding()
        .frame(width: 351, height: 104)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(20)
    }
}

struct DayCircleView: View {
    let dayIndex: Int
    let alignments: [DailyAlignment]
    
    private var date: Date {
        Calendar.current.date(byAdding: .day, value: -dayIndex, to: .now)!
    }
    
    private var isCompleted: Bool {
        alignments.contains { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
    
    private var dayAbbreviation: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                if isCompleted {
                    Circle()
                        .fill(Color.white)
                    Image(systemName: "checkmark")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                } else {
                    Circle()
                        .stroke(Color.gray, lineWidth: 2)
                }
            }
            .frame(width: 35, height: 35)
            
            Text(dayAbbreviation)
                .font(.system(size: 12))
                .foregroundColor(.gray)
        }
    }
}


#Preview {
    ({
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: Goal.self, DailyAlignment.self, configurations: config)

        // Sample goals for the preview
        let sampleGoal1 = Goal(text: "Preview Goal 1", order: 0)
        let sampleGoal2 = Goal(text: "Preview Goal 2", order: 1)
        let today = Calendar.current.startOfDay(for: .now)
        container.mainContext.insert(DailyAlignment(date: today, completed: true, goals: [sampleGoal1]))

        return CompletionView(alignedGoals: [sampleGoal1, sampleGoal2])
            .modelContainer(container)
            .background(Color.black)
    })()
}
