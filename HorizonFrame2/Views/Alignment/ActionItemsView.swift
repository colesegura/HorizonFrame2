import SwiftUI
import SwiftData

struct ActionItemsView: View {
    @Binding var currentPage: Int
    let goals: [Goal]
    let onComplete: () -> Void
    
    @Environment(\.modelContext) private var modelContext
    @State private var actionItems: [Goal: String] = [:] // Use Goal directly as key instead of ID string
    @State private var showingActionItemSheet = false
    @State private var selectedGoal: Goal?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Main content
                VStack(spacing: 20) {
                    Text("What action items that you can complete today will help you reach your long-term goals?")
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.top, 80)
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            ForEach(goals, id: \.id) { goal in
                                GoalActionItemCard(
                                    goal: goal,
                                    actionItemText: actionItems[goal] ?? "",
                                    onAddActionItem: {
                                        selectedGoal = goal
                                        showingActionItemSheet = true
                                    }
                                )
                            }
                        }
                        .padding()
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .zIndex(1)
                
                // Complete Button - Separate layer with higher z-index
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            // Save action items to goals
                            saveActionItems()
                            // Complete the alignment
                            onComplete()
                        }) {
                            ZStack {
                                Circle().fill(Color.white).frame(width: 60, height: 60)
                                Image(systemName: "checkmark")
                                    .font(.title)
                                    .foregroundColor(.black)
                            }
                        }
                        .padding(.horizontal, 30)
                    }
                    .padding(.bottom, geometry.safeAreaInsets.bottom + 110)
                }
                .zIndex(2)
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .sheet(isPresented: $showingActionItemSheet) {
            if let goal = selectedGoal {
                ActionItemSheet(
                    goal: goal,
                    actionItemText: actionItems[goal] ?? "",
                    onSave: { text in
                        actionItems[goal] = text
                        showingActionItemSheet = false
                    }
                )
            }
        }
    }
    
    private func saveActionItems() {
        for (goal, actionItemText) in actionItems {
            if !actionItemText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                let actionItem = ActionItem(
                    text: actionItemText,
                    order: goal.actionItems.count,
                    goal: goal
                )
                modelContext.insert(actionItem)
            }
        }
        try? modelContext.save()
    }
}

struct GoalActionItemCard: View {
    let goal: Goal
    let actionItemText: String
    let onAddActionItem: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(goal.text)
                .font(.headline)
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
            
            if !actionItemText.isEmpty {
                Text(actionItemText)
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)
                    .padding(.leading, 8)
            }
            
            Button(action: onAddActionItem) {
                HStack {
                    Image(systemName: actionItemText.isEmpty ? "plus.circle" : "pencil.circle")
                    Text(actionItemText.isEmpty ? "Add action item" : "Edit action item")
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
    }
}

struct ActionItemSheet: View {
    let goal: Goal
    let actionItemText: String
    let onSave: (String) -> Void
    
    @State private var text: String
    @FocusState private var isTextFieldFocused: Bool
    @Environment(\.dismiss) private var dismiss
    
    init(goal: Goal, actionItemText: String, onSave: @escaping (String) -> Void) {
        self.goal = goal
        self.actionItemText = actionItemText
        self.onSave = onSave
        self._text = State(initialValue: actionItemText)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Action item for: \(goal.text)")
                    .font(.headline)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.top)
                
                ZStack(alignment: .leading) {
                    if text.isEmpty && !isTextFieldFocused {
                        Text("Today, I will complete one task from my project")
                            .font(.body)
                            .foregroundColor(.gray.opacity(0.7))
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal, 20)
                            .onTapGesture {
                                isTextFieldFocused = true
                            }
                    }
                    
                    TextField("", text: $text, axis: .vertical)
                        .font(.body)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .lineLimit(3)
                        .padding(.horizontal, 20)
                        .focused($isTextFieldFocused)
                }
                
                Spacer()
            }
            .background(Color.black)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Save") {
                    onSave(text)
                }
                .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            )
        }
        .presentationDetents([.medium])
    }
}

// Keep the existing GoalRowView, ActiveTimerCircle, InactiveTimerCircle, and Color extension for potential future use
struct GoalRowView: View {
    let goal: Goal
    let isActive: Bool
    let timeRemaining: Double
    let index: Int
    
    // Define the gray color explicitly
    private let grayColor = Color(UIColor(red: 0x7e/255.0, green: 0x7e/255.0, blue: 0x7e/255.0, alpha: 1.0))
    
    var body: some View {
        HStack(spacing: 16) {
            if isActive {
                ActiveTimerCircle(timeRemaining: timeRemaining)
            } else {
                InactiveTimerCircle(index: index)
            }
            
            Text(goal.text)
                .font(.system(size: isActive ? 20 : 15, weight: isActive ? .bold : .regular))
                .foregroundColor(isActive ? .white : grayColor)
                .animation(.easeInOut, value: isActive)
            
            Spacer()
        }
    }
}

struct ActiveTimerCircle: View {
    let timeRemaining: Double
    private var progress: Double { 1.0 - (timeRemaining / 90.0) }
    
    var body: some View {
        ZStack {
            // Background gray circle
            Circle()
                .fill(Color.gray.opacity(0.3))

            // White progress fill that gets revealed
            Path { path in
                let center = CGPoint(x: 96 / 2, y: 96 / 2)
                path.move(to: center)
                path.addArc(center: center, radius: 96 / 2, startAngle: .degrees(-90), endAngle: .degrees(-90 + (360 * (1 - progress))), clockwise: true)
                path.closeSubpath()
            }
            .fill(Color.white)
            .animation(.linear, value: progress)

            Text(timeString(time: Int(ceil(timeRemaining))))
                .font(.system(size: 22, weight: .bold, design: .monospaced))
                .foregroundColor(.black)
        }
        .frame(width: 96, height: 96)
    }
    
    private func timeString(time: Int) -> String {
        let minutes = time / 60
        let seconds = time % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct InactiveTimerCircle: View {
    let index: Int
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.gray.opacity(0.5))
            Text("\(index)")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(width: 49, height: 49)
    }
}

// Using shared Color extension defined elsewhere in the app
