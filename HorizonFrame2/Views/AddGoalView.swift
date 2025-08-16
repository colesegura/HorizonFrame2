import SwiftUI
import SwiftData

struct AddGoalView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Goal.order) private var goals: [Goal]
    
    @State private var goalText: String = ""
    @State private var targetDate: Date = Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date()
    @State private var visionDescription: String = ""
    @State private var isFormValid: Bool = false
    @State private var selectedCategory: GoalCategory = .active
    @State private var isPrimary: Bool = false
    
    private var darkGray: Color { Color(hex: "1C1C1E") }
    private var darkerGray: Color { Color(hex: "151515") }
    private var accentGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [Color.blue, Color.purple]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 32) {
                        // Header
                        Text("Create a New Goal")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.top, 8)
                        
                        // Goal text input
                        VStack(alignment: .leading, spacing: 12) {
                            Text("What is one goal you intend to achieve?")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            TextEditor(text: $goalText)
                                .frame(minHeight: 100)
                                .padding(16)
                                .background(darkGray)
                                .cornerRadius(16)
                                .foregroundColor(.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                                .onChange(of: goalText) { validateForm() }
                        }
                        
                        // Category selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Goal Category")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            HStack(spacing: 16) {
                                ForEach(GoalCategory.allCases, id: \.self) { category in
                                    categoryButton(for: category)
                                }
                            }
                        }
                        
                        // Primary goal toggle
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Primary Goal")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Toggle(isOn: $isPrimary) {
                                HStack {
                                    Text("Set as primary goal")
                                        .foregroundColor(.white)
                                    
                                    Text("⭐")
                                }
                            }
                            .toggleStyle(SwitchToggleStyle(tint: .yellow))
                            .padding(16)
                            .background(darkGray)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        }
                        
                        // Target date picker
                        VStack(alignment: .leading, spacing: 12) {
                            Text("When do you want to achieve that by?")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            DatePicker("Target Date", selection: $targetDate, displayedComponents: .date)
                                .datePickerStyle(.graphical)
                                .tint(.blue)
                                .padding(16)
                                .background(darkGray)
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                                .onChange(of: targetDate) { validateForm() }
                        }
                        
                        // Vision description input
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Describe a moment you'll experience having reached this goal")
                                .font(.headline)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                            
                            Text("Include what you'll see, feel, and experience")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .padding(.top, -8)
                            
                            TextEditor(text: $visionDescription)
                                .frame(minHeight: 150)
                                .padding(16)
                                .background(darkGray)
                                .cornerRadius(16)
                                .foregroundColor(.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                                .onChange(of: visionDescription) { validateForm() }
                        }
                        
                        // Add goal button
                        Button(action: addGoal) {
                            Text("Create Goal")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    isFormValid ? 
                                    accentGradient : 
                                    LinearGradient(gradient: Gradient(colors: [Color.gray.opacity(0.5), Color.gray.opacity(0.5)]), startPoint: .leading, endPoint: .trailing)
                                )
                                .cornerRadius(16)
                                .shadow(color: isFormValid ? Color.purple.opacity(0.3) : Color.clear, radius: 8, x: 0, y: 4)
                        }
                        .disabled(!isFormValid)
                        .padding(.top, 16)
                        .padding(.bottom, 32)
                    }
                    .padding(24)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.gray.opacity(0.3))
                            .clipShape(Circle())
                    }
                }
            }
            .preferredColorScheme(.dark)
        }
    }
    
    private func validateForm() {
        let trimmedGoalText = goalText.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedVisionDescription = visionDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        
        isFormValid = !trimmedGoalText.isEmpty && 
                     !trimmedVisionDescription.isEmpty && 
                     targetDate > Date()
    }
    
    private func addGoal() {
        guard isFormValid else { return }
        
        let trimmedGoalText = goalText.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedVisionDescription = visionDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let newGoal = Goal(
            text: trimmedGoalText,
            order: goals.count,
            targetDate: targetDate,
            isPrimary: isPrimary,
            category: selectedCategory
        )
        
        // Set the user vision through the extension property
        newGoal.userVision = trimmedVisionDescription
        
        // If this is set as primary, unset any other primary goals
        if isPrimary {
            for goal in goals where goal.isPrimary {
                goal.isPrimary = false
            }
        }
        
        modelContext.insert(newGoal)
        try? modelContext.save()
        
        // Check for awards
        checkFocusAwards()
        
        // Add haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        dismiss()
    }
    
    private func checkFocusAwards() {
        let awardManager = AwardManager(modelContext: modelContext)
        awardManager.checkAllAwards(stats: (0,0,0), totalFocuses: goals.count + 1)
    }
    
    // Helper method for category selection buttons
    @ViewBuilder
    private func categoryButton(for category: GoalCategory) -> some View {
        let isSelected = selectedCategory == category
        
        Button(action: {
            withAnimation(.spring(response: 0.3)) {
                selectedCategory = category
            }
        }) {
            VStack(spacing: 8) {
                Text(category.icon)
                    .font(.title2)
                
                Text(category.displayName)
                    .font(.caption)
                    .fontWeight(isSelected ? .bold : .regular)
            }
            .frame(minWidth: 80)
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
            .background(isSelected ? darkGray : Color.clear)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .foregroundColor(isSelected ? .white : .gray)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Goal.self, ActionItem.self, JournalEntry.self, configurations: config)
    
    return AddGoalView()
        .modelContainer(container)
        .preferredColorScheme(.dark)
}
