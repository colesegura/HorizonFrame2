import SwiftUI
import SwiftData

struct GoalsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Goal.order) private var goals: [Goal]
    @Query private var alignments: [DailyAlignment] // Fetch all alignments
    @State private var newGoalText: String = ""
    @State private var editingGoal: Goal? = nil
    @State private var editedGoalText: String = ""
    @State private var addingActionItemTo: Goal? = nil
    @State private var newActionItemText: String = ""

    private var activeGoals: [Goal] { goals.filter { !$0.isArchived } }
    private var archivedGoals: [Goal] { goals.filter { $0.isArchived } }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Define your goals and intentions. These are the outcomes you want to align with each day.")
                            .font(.body)
                            .foregroundColor(.gray)
                    }
                    .padding([.top, .horizontal])
                    
                    List {
                        if !activeGoals.isEmpty {
                            Section(header: Text("Active Goals").foregroundColor(.white)) {
                                ForEach(activeGoals) { goal in
                                    goalRow(for: goal, isArchived: false)
                                }
                            }
                        }

                        if !archivedGoals.isEmpty {
                            Section(header: Text("Archived Goals").foregroundColor(.gray)) {
                                ForEach(archivedGoals) { goal in
                                    goalRow(for: goal, isArchived: true)
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .navigationTitle("Goals")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            HStack(spacing: 12) {
                                UpgradeButton()
                                StreakCounterView()
                            }
                        }
                    }
                    
                    // Input field
                    HStack(spacing: 12) {
                        TextField("Add a new goal...", text: $newGoalText, onCommit: addGoal)
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
            .sheet(item: $editingGoal) { goal in
                editGoalSheet(for: goal)
            }
            .sheet(item: $addingActionItemTo) { goal in
                addActionItemSheet(for: goal)
            }
        }
    }
    
    @ViewBuilder
    private func goalRow(for goal: Goal, isArchived: Bool) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Goal text (larger)
            HStack {
                Text(goal.text)
                    .font(.title2.bold())
                    .foregroundColor(isArchived ? .gray : .white)
                    .multilineTextAlignment(.leading)
                Spacer()
                let count = alignmentCount(for: goal)
                Text("\(count) \(count == 1 ? "day" : "days") aligned")
                    .font(.caption)
                    .foregroundColor(isArchived ? .gray : .green)
            }
            
            // Visualization (only for onboarding goals)
            if let visualization = goal.visualization, !visualization.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "eye.fill")
                            .foregroundColor(.purple)
                            .font(.caption)
                        Text("Visualization")
                            .font(.caption.bold())
                            .foregroundColor(.purple)
                    }
                    
                    Text(visualization)
                        .font(.subheadline)
                        .foregroundColor(isArchived ? .gray.opacity(0.8) : .gray)
                        .padding(.leading, 16)
                        .italic()
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color.purple.opacity(0.1))
                .cornerRadius(8)
            }
            
            // Action items
            if !goal.actionItems.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(goal.actionItems.sorted(by: { $0.order < $1.order })) { actionItem in
                        HStack {
                            Button(action: {
                                toggleActionItem(actionItem)
                            }) {
                                Image(systemName: actionItem.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(actionItem.isCompleted ? .green : .gray)
                                    .font(.title3)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Text(actionItem.text)
                                .font(.body)
                                .foregroundColor(actionItem.isCompleted ? .gray : .white)
                                .strikethrough(actionItem.isCompleted)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                deleteActionItem(actionItem)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .padding(.leading, 8)
            }
            
            // Add action item button (only for active goals)
            if !isArchived {
                Button(action: {
                    addingActionItemTo = goal
                }) {
                    HStack {
                        Image(systemName: "plus.circle")
                            .foregroundColor(.blue)
                        Text("Add action item")
                            .foregroundColor(.blue)
                    }
                    .font(.caption)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.leading, 8)
            }
        }
        .padding(.vertical, 8)
        .listRowBackground(Color.black)
        .listRowSeparatorTint(.gray.opacity(0.5))
        .swipeActions(edge: .leading) {
            Button {
                startEditing(goal)
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            .tint(.blue)
        }
        .swipeActions(edge: .trailing) {
            if isArchived {
                Button {
                    unarchiveGoal(goal)
                } label: {
                    Label("Unarchive", systemImage: "archivebox.fill")
                }
                .tint(.green)
            } else {
                Button {
                    archiveGoal(goal)
                } label: {
                    Label("Archive", systemImage: "archivebox")
                }
                .tint(.orange)
            }
            Button(role: .destructive) {
                deleteGoal(goal)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    @ViewBuilder
    private func editGoalSheet(for goal: Goal) -> some View {
        VStack(spacing: 20) {
            Text("Edit Goal")
                .font(.headline)
            TextField("Goal", text: $editedGoalText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            HStack {
                Button("Cancel") { editingGoal = nil }
                    .buttonStyle(.bordered)
                Spacer()
                Button("Save") {
                    if let editingGoal = editingGoal {
                        editingGoal.text = editedGoalText
                    }
                    editingGoal = nil
                }
                .buttonStyle(.borderedProminent)
                .disabled(editedGoalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding()
        .onAppear {
            editedGoalText = goal.text
        }
        .presentationDetents([.height(200)])
    }
    
    @ViewBuilder
    private func addActionItemSheet(for goal: Goal) -> some View {
        VStack(spacing: 20) {
            Text("Add Action Item")
                .font(.headline)
            TextField("Action item", text: $newActionItemText, axis: .vertical)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .lineLimit(3...6)
                .padding()
            HStack {
                Button("Cancel") { 
                    addingActionItemTo = nil
                    newActionItemText = ""
                }
                    .buttonStyle(.bordered)
                Spacer()
                Button("Add") {
                    addActionItem(to: goal)
                }
                .buttonStyle(.borderedProminent)
                .disabled(newActionItemText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding()
        .presentationDetents([.height(200)])
    }

    private func addGoal() {
        guard !newGoalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let newGoal = Goal(text: newGoalText, order: goals.count)
        modelContext.insert(newGoal)
        try? modelContext.save()
        newGoalText = ""
        checkFocusAwards()
    }
    
    private func addActionItem(to goal: Goal) {
        guard !newActionItemText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let newActionItem = ActionItem(
            text: newActionItemText,
            order: goal.actionItems.count,
            goal: goal
        )
        modelContext.insert(newActionItem)
        try? modelContext.save()
        newActionItemText = ""
        addingActionItemTo = nil
    }
    
    private func toggleActionItem(_ actionItem: ActionItem) {
        actionItem.isCompleted.toggle()
        try? modelContext.save()
    }
    
    private func deleteActionItem(_ actionItem: ActionItem) {
        modelContext.delete(actionItem)
        try? modelContext.save()
    }

    private func deleteGoal(_ goal: Goal) {
        modelContext.delete(goal)
        updateGoalOrder()
    }
    
    private func archiveGoal(_ goal: Goal) {
        goal.isArchived = true
    }

    private func unarchiveGoal(_ goal: Goal) {
        goal.isArchived = false
    }

    private func startEditing(_ goal: Goal) {
        editingGoal = goal
    }

    private func moveGoals(from source: IndexSet, to destination: Int) {
        var reorderedGoals = goals
        reorderedGoals.move(fromOffsets: source, toOffset: destination)
        
        for (index, goal) in reorderedGoals.enumerated() {
            goal.order = index
        }
    }
    
    private func updateGoalOrder() {
        let active = goals.filter { !$0.isArchived }
        for (index, goal) in active.enumerated() {
            goal.order = index
        }
    }
    
    private func alignmentCount(for goal: Goal) -> Int {
        alignments.filter { alignment in
            alignment.goals.contains(where: { $0.id == goal.id })
        }.count
    }
    
    private func checkFocusAwards() {
        let awardManager = AwardManager(modelContext: modelContext)
        awardManager.checkAllAwards(stats: (0,0,0), totalFocuses: goals.count + 1)
    }
}

#Preview {
    ({
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: Goal.self, ActionItem.self, DailyAlignment.self, configurations: config)

        // Add sample data
        let goal1 = Goal(text: "I earn $10,000 per month.", order: 0)
        let goal2 = Goal(text: "I have a loving relationship.", order: 1)
        let goal3 = Goal(text: "I have supportive friends.", order: 2, isArchived: true)
        container.mainContext.insert(goal1)
        container.mainContext.insert(goal2)
        container.mainContext.insert(goal3)
        
        // Add sample action items
        let actionItem1 = ActionItem(text: "Create a business plan", order: 0, goal: goal1)
        let actionItem2 = ActionItem(text: "Research market opportunities", order: 1, goal: goal1)
        let actionItem3 = ActionItem(text: "Plan a date night", order: 0, goal: goal2)
        container.mainContext.insert(actionItem1)
        container.mainContext.insert(actionItem2)
        container.mainContext.insert(actionItem3)
        
        // Add sample alignments
        let today = Calendar.current.startOfDay(for: .now)
        container.mainContext.insert(DailyAlignment(date: today, completed: true, goals: [goal1, goal2]))
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        container.mainContext.insert(DailyAlignment(date: yesterday, completed: true, goals: [goal1]))

        return GoalsView()
            .modelContainer(container)
    })()
} 