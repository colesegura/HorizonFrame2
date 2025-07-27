import SwiftUI
import SwiftData

struct VisualizationView: View {
    @Binding var currentPage: Int
    let goalsToVisualize: [Goal]
    
    @State private var activeGoalIndex = 0
    @State private var timeRemaining: Double = 90
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var startOfDay: Date = Date()
    @State private var endOfDay: Date = Date()
    
    @Query(
        FetchDescriptor<DailyAlignment>(
            predicate: nil, // We'll filter manually if needed or update dynamically
            sortBy: [SortDescriptor(\DailyAlignment.date, order: .reverse)]
        )
    ) private var allAlignments: [DailyAlignment]
    
    private var todaysAlignment: [DailyAlignment] {
        allAlignments.filter { alignment in
            alignment.date >= startOfDay && alignment.date < endOfDay
        }
    }
    
    init(currentPage: Binding<Int>, goalsToVisualize: [Goal]) {
        self._currentPage = currentPage
        self.goalsToVisualize = goalsToVisualize
        let calendar = Calendar.current
        self.startOfDay = calendar.startOfDay(for: Date())
        self.endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Main content
                VStack(spacing: 20) {
                    Text("Visualize what it will look and feel like to have achieved each goal.\nHold that image in your mind for 90 seconds.")
                        .font(.system(size: 18))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.top, 80)
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            ForEach(Array(goalsToVisualize.enumerated()), id: \.element.id) { index, goal in
                                GoalRowView(goal: goal, 
                                            isActive: index == activeGoalIndex, 
                                            timeRemaining: timeRemaining, 
                                            index: index + 1)
                            }
                        }
                        .padding()
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
                .zIndex(1)
                
                // Next Page Button - Separate layer with higher z-index
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: goToNextGoal) {
                            ZStack {
                                Circle().fill(Color.white).frame(width: 60, height: 60)
                                Image(systemName: "arrow.right")
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
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea(edges: .bottom) // Ignore safe area for the entire view
        }
        .onReceive(timer) {
            _ in
            guard activeGoalIndex < goalsToVisualize.count else { return }
            
            if timeRemaining > 0 {
                timeRemaining -= 0.1
            } else {
                goToNextGoal()
            }
        }
        .onAppear {
            // Reset timer state when view appears
            timeRemaining = 90
            activeGoalIndex = 0
        }
        .onDisappear {
            timer.upstream.connect().cancel()
        }
    }
    
    private func goToNextGoal() {
        if activeGoalIndex < goalsToVisualize.count - 1 {
            activeGoalIndex += 1
            timeRemaining = 90
        } else {
            // All goals completed, move to the final page
            withAnimation {
                currentPage = 2
            }
        }
    }
}

#Preview {
    let goals = [
        Goal(text: "I earn $10,000 per month.", order: 0),
        Goal(text: "I have a loving relationship.", order: 1)
    ]
    
    return VisualizationView(currentPage: .constant(1), goalsToVisualize: goals)
        .background(Color.black)
}
