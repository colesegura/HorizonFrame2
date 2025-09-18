import SwiftUI
import SwiftData

struct GoalsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Goal.order) private var goals: [Goal]
    @Query private var alignments: [DailyAlignment] // Fetch all alignments
    @Query private var personalCodes: [PersonalCode]
    @Query private var userInterests: [UserInterest]
    @State private var showingAddGoalView: Bool = false
    @State private var editingGoal: Goal? = nil
    @State private var addingActionItemTo: Goal? = nil
    @State private var newActionItemText: String = ""
    @State private var showingAddPrincipleView: Bool = false
    @State private var editingPrinciple: PersonalCodePrinciple? = nil
    
    // New state variables for redesigned UI
    @State private var selectedCategory: GoalCategory = .active
    @State private var expandedGoals: Set<String> = []
    @State private var userName: String? = UserDefaults.standard.string(forKey: "userName")
    
    // Computed properties for categorized goals
    private var activeGoals: [Goal] { 
        goals.filter { !$0.isArchived }
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
    private var personalCode: PersonalCode {
        if let code = personalCodes.first {
            return code
        } else {
            let newCode = PersonalCode()
            modelContext.insert(newCode)
            return newCode
        }
    }
    
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
                // Full screen black background - matching Today page
                Color.black.ignoresSafeArea()
                
                // Custom header with logo, upgrade button and streak counter
                VStack {
                    HStack(spacing: 12) {
                        // HorizonFrame logo
                        Image("horizonframe-logo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 30)
                        
                        Spacer()
                        UpgradeButton()
                        StreakCounterView()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    
                    Spacer()
                }
                
                VStack(spacing: 24) {
                    Spacer(minLength: 60) // Space for header
                    
                    // Simple title - matching Today page style
                    Text("Your Goals")
                        .font(.system(size: 32))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                    
                    // Goals list with minimal styling
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            // --- Personal Code Section ---
                            Section {
                                let principles = personalCode.principles.sorted { $0.order < $1.order }
                                if principles.isEmpty {
                                    emptyPrinciplesView()
                                } else {
                                    ForEach(principles) { principle in
                                        PrincipleRowView(
                                            principle: principle,
                                            onEdit: {
                                                editingPrinciple = principle
                                            },
                                            onDelete: {
                                                // Find the index of the principle to delete
                                                if let index = principles.firstIndex(of: principle) {
                                                    deletePrinciples(at: IndexSet(integer: index))
                                                }
                                            }
                                        )
                                    }
                                    .onMove(perform: movePrinciples)
                                }
                                
                                Button(action: {
                                    showingAddPrincipleView = true
                                }) {
                                    Label("Add Principle", systemImage: "plus")
                                        .foregroundColor(.white)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.white.opacity(0.1))
                                        .cornerRadius(16)
                                }
                            }
                            .padding(.horizontal, 24)

                            // --- Interests Section (for testing) ---
                            Section(header: Text("Your Interests").font(.headline).foregroundColor(.gray).padding(.top, 20)) {
                                interestsEditorSection()
                            }
                            .padding(.horizontal, 24)

                            // --- Goals Section ---
                            Section(header: Text("Long-Term Goals").font(.headline).foregroundColor(.gray).padding(.top, 20)) {
                                ForEach(activeGoals) { goal in
                                    goalRowMinimal(for: goal)
                                }
                                
                                // Empty state for goals
                                if activeGoals.isEmpty {
                                    emptyStateViewMinimal()
                                        .padding(.top, 20)
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 120) // Bottom padding for tab bar and floating button
                    }
                    
                    Spacer()
                    
                    // Edit button for principles
                    if !personalCode.principles.isEmpty {
                        EditButton()
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.bottom, 16)
                    }

                    // Add goal button at bottom - matching Today page style
                    Button(action: {
                        showingAddGoalView = true
                    }) {
                        Text("Add Goal")
                    }
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black)
                    .frame(width: 320, height: 60)
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .fill(Color.white)
                            .shadow(color: .white.opacity(0.3), radius: 10, x: 0, y: 0)
                    )
                    .padding(.bottom, 120)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .preferredColorScheme(.dark)
            .statusBar(hidden: true)
            .sheet(item: $editingGoal) { goal in
                EditGoalView(goal: goal)
            }
            .sheet(item: $addingActionItemTo) { goal in
                addActionItemSheet(for: goal)
            }
            .sheet(isPresented: $showingAddGoalView) {
                AddGoalView()
            }
            .sheet(isPresented: $showingAddPrincipleView) {
                AddPrincipleView(personalCode: personalCode)
            }
            .sheet(item: $editingPrinciple) { principle in
                EditPrincipleView(principle: principle)
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
        // For now, we'll just open the goal editor
        editingGoal = goal
    }
    
    private func continueJourney(for goal: Goal) {
        // Navigate to alignment flow for this goal
        // This would typically start the daily alignment flow
        // For now, we'll just open the goal editor
        editingGoal = goal
    }
    
    @ViewBuilder
    private func emptyPrinciplesView() -> some View {
        VStack(spacing: 16) {
            Text("No principles yet")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
            
            Text("Add your first principle to define how you want to live each day.")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.5))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.vertical, 20)
    }
    
    @ViewBuilder
    private func interestsEditorSection() -> some View {
        VStack(spacing: 16) {
            if userInterests.isEmpty {
                VStack(spacing: 12) {
                    Text("No interests selected")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text("Add interests to get personalized journaling prompts")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.5))
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, 16)
            } else {
                ForEach(userInterests) { interest in
                    interestRow(for: interest)
                }
            }
            
            // Quick add buttons for common interests
            VStack(spacing: 12) {
                Text("Quick Add:")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 8) {
                    quickAddButton(for: .health, subcategory: "Diet")
                    quickAddButton(for: .productivity, subcategory: "Time blocking")
                    quickAddButton(for: .focus, subcategory: "Deep work")
                    quickAddButton(for: .consistency, subcategory: "Daily habits")
                }
            }
            .padding(.top, 8)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    @ViewBuilder
    private func interestRow(for interest: UserInterest) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(interest.displayName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                if let subcategory = interest.healthSubcategory {
                    Text(subcategory.rawValue)
                        .font(.system(size: 12))
                        .foregroundColor(.blue)
                } else if let subcategory = interest.subcategory, !subcategory.isEmpty {
                    Text(subcategory)
                        .font(.system(size: 12))
                        .foregroundColor(.blue)
                }
                
                HStack(spacing: 12) {
                    Text("Active: \(interest.isActive ? "Yes" : "No")")
                        .font(.system(size: 11))
                        .foregroundColor(interest.isActive ? .green : .gray)
                    
                    if interest.baselineCompleted {
                        Text("Baseline ✓")
                            .font(.system(size: 11))
                            .foregroundColor(.green)
                    }
                    
                    if interest.healthSubcategory == .diet {
                        Text("Level \(interest.currentLevel)")
                            .font(.system(size: 11))
                            .foregroundColor(.purple)
                    }
                }
            }
            
            Spacer()
            
            Menu {
                Button(action: {
                    toggleInterestActive(interest)
                }) {
                    Label(interest.isActive ? "Deactivate" : "Activate", 
                          systemImage: interest.isActive ? "pause.circle" : "play.circle")
                }
                
                if !interest.baselineCompleted {
                    Button(action: {
                        markBaselineCompleted(interest)
                    }) {
                        Label("Mark Baseline Complete", systemImage: "checkmark.circle")
                    }
                }
                
                Divider()
                
                Button(role: .destructive, action: {
                    deleteInterest(interest)
                }) {
                    Label("Delete", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .foregroundColor(.white.opacity(0.6))
                    .font(.system(size: 16))
            }
        }
        .padding(.vertical, 8)
    }
    
    @ViewBuilder
    private func quickAddButton(for type: InterestType, subcategory: String) -> some View {
        Button(action: {
            addQuickInterest(type: type, subcategory: subcategory)
        }) {
            VStack(spacing: 4) {
                Text(type.rawValue)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(subcategory)
                    .font(.system(size: 10))
                    .foregroundColor(.blue)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(Color.blue.opacity(0.2))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }

    @ViewBuilder
    private func emptyStateViewMinimal() -> some View {
        VStack(spacing: 24) {
            Text("No goals yet")
                .font(.system(size: 22))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
            
            Text("Add your first goal to get started")
                .font(.system(size: 18))
                .foregroundColor(.white.opacity(0.5))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    @ViewBuilder
    private func goalRowMinimal(for goal: Goal) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Goal text
            HStack {
                Text(goal.text)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.leading)
                Spacer()
                
                // Menu button
                Menu {
                    Button(action: {
                        editingGoal = goal
                    }) {
                        Label("Edit Goal", systemImage: "pencil")
                    }
                    
                    Button(action: {
                        addingActionItemTo = goal
                    }) {
                        Label("Add Action Item", systemImage: "plus.circle")
                    }
                    
                    Divider()
                    
                    Button(role: .destructive, action: {
                        deleteGoal(goal)
                    }) {
                        Label("Delete Goal", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.white.opacity(0.6))
                        .font(.system(size: 16, weight: .medium))
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // Progress bar (if goal has target date)
            if let targetDate = goal.targetDate {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Progress")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                        
                        Spacer()
                        
                        Text("\(Int(progressPercentage(for: goal) * 100))%")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Background
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 6)
                            
                            // Progress
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.8))
                                .frame(width: max(0, min(CGFloat(progressPercentage(for: goal)) * geometry.size.width, geometry.size.width)), height: 6)
                                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progressPercentage(for: goal))
                        }
                    }
                    .frame(height: 6)
                }
            }
            
            // Goal details if available
            if let details = goal.userVision, !details.isEmpty {
                Text(details)
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(3)
            } else if let visualization = goal.visualization, !visualization.isEmpty {
                Text(visualization)
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(3)
            }
            
            // Alignment count
            let count = alignmentCount(for: goal)
            if count > 0 {
                Text("\(count) \(count == 1 ? "day" : "days") aligned")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                deleteGoal(goal)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
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
                        editingGoal = goal
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
        try? modelContext.save()
        updateGoalOrder()
        
        // Add haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
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
    
    private func progressPercentage(for goal: Goal) -> Double {
        guard let targetDate = goal.targetDate else { return 0.0 }
        let created = goal.createdAt
        let totalDuration = targetDate.timeIntervalSince(created)
        let elapsedDuration = Date().timeIntervalSince(created)
        return min(max(elapsedDuration / totalDuration, 0.0), 1.0)
    }
    
    private func movePrinciples(from source: IndexSet, to destination: Int) {
        var sortedPrinciples = personalCode.principles.sorted { $0.order < $1.order }
        sortedPrinciples.move(fromOffsets: source, toOffset: destination)
        
        for (index, principle) in sortedPrinciples.enumerated() {
            principle.order = index
        }
        
        // Haptic feedback for move
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    private func deletePrinciples(at offsets: IndexSet) {
        let sortedPrinciples = personalCode.principles.sorted { $0.order < $1.order }
        for index in offsets {
            let principleToDelete = sortedPrinciples[index]
            modelContext.delete(principleToDelete)
        }
        
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    private func checkFocusAwards() {
        let awardManager = AwardManager(modelContext: modelContext)
        awardManager.checkAllAwards(stats: (0,0,0), totalFocuses: goals.count + 1)
    }
    
    // MARK: - Interest Management Functions
    
    private func addQuickInterest(type: InterestType, subcategory: String) {
        // Check if this interest already exists
        let existingInterest = userInterests.first { interest in
            interest.type == type.rawValue && interest.subcategory == subcategory
        }
        
        if existingInterest != nil {
            // Interest already exists, just activate it
            existingInterest?.isActive = true
            try? modelContext.save()
            return
        }
        
        // Create new interest
        let newInterest = UserInterest(type: type, subcategory: subcategory)
        newInterest.isActive = true
        newInterest.baselineCompleted = false // For testing, you can set this to true
        
        // Health subcategory is automatically handled by the computed property
        
        modelContext.insert(newInterest)
        
        do {
            try modelContext.save()
            
            // Add haptic feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        } catch {
            print("Error saving new interest: \(error)")
        }
    }
    
    private func toggleInterestActive(_ interest: UserInterest) {
        interest.isActive.toggle()
        
        do {
            try modelContext.save()
            
            // Add haptic feedback
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        } catch {
            print("Error toggling interest active state: \(error)")
        }
    }
    
    private func markBaselineCompleted(_ interest: UserInterest) {
        interest.baselineCompleted = true
        
        do {
            try modelContext.save()
            
            // Add haptic feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        } catch {
            print("Error marking baseline completed: \(error)")
        }
    }
    
    private func deleteInterest(_ interest: UserInterest) {
        modelContext.delete(interest)
        
        do {
            try modelContext.save()
            
            // Add haptic feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        } catch {
            print("Error deleting interest: \(error)")
        }
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