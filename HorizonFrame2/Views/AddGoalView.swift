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
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Goal text input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("What is one goal you intend to achieve?")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            TextEditor(text: $goalText)
                                .frame(minHeight: 100)
                                .padding(10)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                                .onChange(of: goalText) { validateForm() }
                        }
                        
                        // Target date picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("When do you want to achieve that by?")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            DatePicker("Target Date", selection: $targetDate, displayedComponents: .date)
                                .datePickerStyle(.graphical)
                                .tint(.purple)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                                .onChange(of: targetDate) { validateForm() }
                        }
                        
                        // Vision description input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Describe a moment you'll experience having reached this goal, including what you'll see and feel.")
                                .font(.headline)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                            
                            TextEditor(text: $visionDescription)
                                .frame(minHeight: 150)
                                .padding(10)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                                .onChange(of: visionDescription) { validateForm() }
                        }
                        
                        // Add goal button
                        Button(action: addGoal) {
                            Text("Add Goal")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(isFormValid ? Color.purple : Color.gray)
                                .cornerRadius(10)
                        }
                        .disabled(!isFormValid)
                        .padding(.top, 16)
                    }
                    .padding()
                }
            }
            .navigationTitle("Add a Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
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
            targetDate: targetDate
        )
        
        // Set the user vision through the extension property
        newGoal.userVision = trimmedVisionDescription
        
        modelContext.insert(newGoal)
        try? modelContext.save()
        
        // Check for awards
        checkFocusAwards()
        
        dismiss()
    }
    
    private func checkFocusAwards() {
        let awardManager = AwardManager(modelContext: modelContext)
        awardManager.checkAllAwards(stats: (0,0,0), totalFocuses: goals.count + 1)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Goal.self, ActionItem.self, JournalEntry.self, configurations: config)
    
    return AddGoalView()
        .modelContainer(container)
}
