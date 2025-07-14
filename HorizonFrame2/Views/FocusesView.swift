import SwiftUI
import SwiftData

struct FocusesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Goal.order) private var goals: [Goal]
    @State private var newGoalText: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    List {
                        ForEach(goals) { goal in
                            Text(goal.text)
                                .font(.title3)
                                .foregroundColor(.white)
                                .padding(.vertical, 8)
                                .listRowBackground(Color.black)
                                .listRowSeparatorTint(.gray.opacity(0.5))
                        }
                        .onDelete(perform: deleteGoals)
                        .onMove(perform: moveGoals)
                    }
                    .listStyle(.plain)
                    .navigationTitle("Focuses")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            HStack {
                                StreakCounterView()
                                EditButton()
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    
                    // Input field
                    HStack(spacing: 12) {
                        TextField("Add a new focus...", text: $newGoalText, onCommit: addGoal)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(10)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                            .foregroundColor(.white)
                        
                        Button(action: addGoal) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.title)
                                .foregroundColor(.white)
                        }
                        .disabled(newGoalText.isEmpty)
                    }
                    .padding()
                    .background(Color.black)
                }
                .padding(.bottom, 100) // Prevents tab bar from overlapping
            }
            .preferredColorScheme(.dark)
        }
    }

    private func addGoal() {
        guard !newGoalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let newGoal = Goal(text: newGoalText, order: goals.count)
        modelContext.insert(newGoal)
        newGoalText = ""
        
        // Check for awards
        let awardManager = AwardManager(modelContext: modelContext)
        awardManager.checkAllAwards(stats: (0,0,0), totalFocuses: goals.count + 1)
    }

    private func deleteGoals(at offsets: IndexSet) {
        for offset in offsets {
            let goal = goals[offset]
            modelContext.delete(goal)
        }
        updateGoalOrder()
    }

    private func moveGoals(from source: IndexSet, to destination: Int) {
        var reorderedGoals = goals
        reorderedGoals.move(fromOffsets: source, toOffset: destination)
        
        for (index, goal) in reorderedGoals.enumerated() {
            goal.order = index
        }
    }
    
    private func updateGoalOrder() {
        for (index, goal) in goals.enumerated() {
            goal.order = index
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Goal.self, configurations: config)

    // Add sample data
    container.mainContext.insert(Goal(text: "I earn $10,000 per month.", order: 0))
    container.mainContext.insert(Goal(text: "I have a loving relationship.", order: 1))
    container.mainContext.insert(Goal(text: "I have supportive friends.", order: 2))

    return FocusesView()
        .modelContainer(container)
}
