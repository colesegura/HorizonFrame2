import SwiftUI
import SwiftData

struct GoalsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Goal.order) private var goals: [Goal]
    @Query private var alignments: [DailyAlignment] // Fetch all alignments
    @State private var showingAddGoalView: Bool = false
    @State private var editingGoal: Goal? = nil
    @State private var editedGoalText: String = ""
    @State private var editingGoalDetails: Goal? = nil
    @State private var editedGoalDetails: String = ""
    @State private var addingActionItemTo: Goal? = nil
    @State private var newActionItemText: String = ""
    
    // New state variables for redesigned UI
    @State private var selectedCategory: GoalCategory = .active
    @State private var expandedGoals: Set<String> = []
    @State private var userName: String? = UserDefaults.standard.string(forKey: "userName")
    
    // Computed properties for categorized goals
    private var activeGoals: [Goal] { 
        goals.filter { !$0.isArchived && $0.goalCategory == .active } 
    }
    private var upcomingGoals: [Goal] { 
        goals.filter { !$0.isArchived && $0.goalCategory == .upcoming } 
    }
    private var completedGoals: [Goal] { 
        goals.filter { !$0.isArchived && $0.goalCategory == .completed } 
    }
    private var archivedGoals: [Goal] { 
        goals.filter { $0.isArchived } 
    }
    
    // Category counts for badges
    private var categoryCounts: [GoalCategory: Int] {
        [
            .active: activeGoals.count,
            .upcoming: upcomingGoals.count,
            .completed: completedGoals.count
        ]
    }
    
    // Next deadline in days
    private var nextDeadlineDays: Int? {
        let activeAndUpcomingGoals = goals.filter { !$0.isArchived }
        guard !activeAndUpcomingGoals.isEmpty else { return nil }
        
        let today = Calendar.current.startOfDay(for: Date())
        let futureDates = activeAndUpcomingGoals.compactMap { goal -> Int? in
            guard let targetDate = goal.targetDate else { return nil }
            let targetDay = Calendar.current.startOfDay(for: targetDate)
            let components = Calendar.current.dateComponents([.day], from: today, to: targetDay)
            return components.day
        }.filter { $0 > 0 }
        
        return futureDates.min()
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Personalized header
                    PersonalizedHeaderView(
                        activeGoalCount: activeGoals.count + upcomingGoals.count,
                        nextDeadlineDays: nextDeadlineDays,
                        userName: userName
                    )
                    
                    // Category tabs
                    GoalCategoryTabView(
                        selectedCategory: $selectedCategory,
                        categoryCounts: categoryCounts
                    )
                    .padding(.top, 8)
                    
                    // Goals list
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            // Display goals based on selected category
                            ForEach(goalsForSelectedCategory()) { goal in
                                GoalCardView(
                                    goal: goal,
                                    isPrimary: goal.isPrimary,
                                    isExpanded: expandedBinding(for: goal),
                                    onPrimaryToggle: { isPrimary in togglePrimaryGoal(goal, isPrimary: isPrimary) },
                                    onEdit: { editingGoal = goal },
                                    onQuickEntry: { addQuickEntry(for: goal) },
                                    onContinueJourney: { continueJourney(for: goal) }
                                )
                                .padding(.horizontal)
                                .transition(.opacity)
                            }
                            
                            // Empty state
                            if goalsForSelectedCategory().isEmpty {
                                emptyStateView(for: selectedCategory)
                                    .padding(.top, 40)
                            }
                            
                            // Space at bottom for add button
                            Spacer(minLength: 100)
                        }
                        .padding(.top, 8)
                    }
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            HStack(spacing: 12) {
                                UpgradeButton()
                                StreakCounterView()
                            }
                        }
                    }
                    
                    // Floating add button
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            MinimalistAddButton(action: {
                                showingAddGoalView = true
                            })
                            .padding(.trailing, 24)
                            .padding(.bottom, 16)
                        }
                    }
                }
                .padding(.bottom, 80) // Prevents tab bar from overlapping
            }
            .preferredColorScheme(.dark)
            .sheet(item: $editingGoal) { goal in
                editGoalSheet(for: goal)
            }
            .sheet(item: $editingGoalDetails) { goal in
                editGoalDetailsSheet(for: goal)
            }
            .sheet(item: $addingActionItemTo) { goal in
                addActionItemSheet(for: goal)
            }
            .sheet(isPresented: $showingAddGoalView) {
                AddGoalView()
            }
        }
    }
    
    // Helper methods for the redesigned UI
    
    private func goalsForSelectedCategory() -> [Goal] {
        switch selectedCategory {
        case .active:
            return activeGoals
        case .upcoming:
            return upcomingGoals
        case .completed:
            return completedGoals
        }
    }
    
    private func expandedBinding(for goal: Goal) -> Binding<Bool> {
        Binding(
            get: { expandedGoals.contains(String(describing: goal.id)) },
            set: { isExpanded in
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    if isExpanded {
                        expandedGoals.insert(String(describing: goal.id))
                    } else {
                        expandedGoals.remove(String(describing: goal.id))
                    }
                }
            }
        )
    }
    
    private func togglePrimaryGoal(_ goal: Goal, isPrimary: Bool) {
        // If setting as primary, unset any other primary goals
        if isPrimary {
            for otherGoal in goals where otherGoal.isPrimary {
                otherGoal.isPrimary = false
            }
        }
        
        goal.isPrimary = isPrimary
        try? modelContext.save()
        
        // Add haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    private func addQuickEntry(for goal: Goal) {
        // Navigate to quick entry form or journal
        // This would typically navigate to a journal entry form
        // For now, we'll just open the goal details
        editingGoalDetails = goal
    }
    
    private func continueJourney(for goal: Goal) {
        // Navigate to alignment flow for this goal
        // This would typically start the daily alignment flow
        // For now, we'll just open the goal details
        editingGoalDetails = goal
    }
    
    @ViewBuilder
    private func emptyStateView(for category: GoalCategory) -> some View {
        VStack(spacing: 24) {
            Image(systemName: category.emptyStateIcon)
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.6))
            
            Text(category.emptyStateMessage)
                .font(.headline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Button(action: {
                showingAddGoalView = true
            }) {
                Text("Add Your First Goal")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.purple]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    // Legacy methods for backward compatibility
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
            
            // Goal details section (visualization or user vision)
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    // Header with icon
                    HStack {
                        Image(systemName: "eye.fill")
                            .foregroundColor(.purple)
                        Text("Goal Details")
                            .font(.caption)
                            .foregroundColor(.purple)
                    }
                    
                    Spacer()
                    
                    // Edit button
                    Button(action: {
                        editingGoalDetails = goal
                    }) {
                        Image(systemName: "pencil.circle")
                            .foregroundColor(.blue)
                            .font(.caption)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                // Display goal details if available
                if let details = goal.userVision, !details.isEmpty {
                    Text(details)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.leading, 4)
                } else if let visualization = goal.visualization, !visualization.isEmpty {
                    Text(visualization)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.leading, 4)
                } else {
                    Text("Add details about what your life will look like having achieved this goal.")
                        .font(.body.italic())
                        .foregroundColor(.gray)
                        .padding(.leading, 4)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color.purple.opacity(0.1))
            .cornerRadius(8)
            
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
    private func editGoalDetailsSheet(for goal: Goal) -> some View {
        VStack(spacing: 20) {
            Text("Edit Goal Details")
                .font(.headline)
            
            Text("Add as many details as possible that describe what your life will look like having achieved this goal.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            TextEditor(text: $editedGoalDetails)
                .frame(minHeight: 150)
                .padding(4)
                .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))
            
            HStack {
                Button("Cancel") {
                    editingGoalDetails = nil
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Button("Save") {
                    saveGoalDetails(for: goal)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .onAppear {
            editedGoalDetails = goal.userVision ?? ""
        }
        .presentationDetents([.medium])
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

    // Note: Goal creation is now handled in AddGoalView
    
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
    
    private func saveGoalDetails(for goal: Goal) {
        goal.userVision = editedGoalDetails.trimmingCharacters(in: .whitespacesAndNewlines)
        try? modelContext.save()
        editingGoalDetails = nil
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

        // Add sample data with new properties
        let goal1 = Goal(text: "I earn $10,000 per month.", order: 0, isPrimary: true, category: GoalCategory.active)
        goal1.userVision = "I'm sitting at my desk, looking at my bank account balance showing a $10,000 deposit for the month. I feel financially secure and proud of my accomplishments."
        
        let goal2 = Goal(text: "I have a loving relationship.", order: 1, isPrimary: false, category: GoalCategory.active)
        goal2.userVision = "We're holding hands walking along the beach at sunset, laughing and planning our future together."
        
        let goal3 = Goal(text: "I have supportive friends.", order: 2, isPrimary: false, category: GoalCategory.upcoming)
        goal3.userVision = "We're gathered for dinner at my place, sharing stories and supporting each other through life's challenges."
        
        let goal4 = Goal(text: "I completed my certification.", order: 3, isPrimary: false, category: GoalCategory.completed)
        goal4.userVision = "I'm holding my certificate, feeling accomplished and ready for new opportunities."
        
        let goal5 = Goal(text: "I moved to a new city.", order: 4, isArchived: true)
        
        container.mainContext.insert(goal1)
        container.mainContext.insert(goal2)
        container.mainContext.insert(goal3)
        container.mainContext.insert(goal4)
        container.mainContext.insert(goal5)
        
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