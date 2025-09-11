import SwiftUI
import SwiftData

struct EditGoalView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let goal: Goal
    
    @State private var editedText: String = ""
    @State private var editedVision: String = ""
    @State private var editedVisualization: String = ""
    @State private var editedTargetDate: Date = Date()
    @State private var hasTargetDate: Bool = false
    @State private var editedCategory: GoalCategory = .active
    @State private var showingUnsavedChangesAlert = false
    
    private var hasUnsavedChanges: Bool {
        editedText != goal.text ||
        editedVision != (goal.userVision ?? "") ||
        editedVisualization != (goal.visualization ?? "") ||
        (hasTargetDate ? editedTargetDate != (goal.targetDate ?? Date()) : goal.targetDate != nil) ||
        editedCategory != goal.goalCategory
    }
    
    private var darkGray: Color { Color(hex: "1C1C1E") }
    private var darkerGray: Color { Color(hex: "151515") }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Goal Title Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Goal Title")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            TextField("Enter your goal", text: $editedText, axis: .vertical)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .lineLimit(2...4)
                        }
                        
                        // Target Date Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Target Date")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Toggle("Set target date", isOn: $hasTargetDate)
                                .foregroundColor(.white)
                            
                            if hasTargetDate {
                                DatePicker("Target Date", selection: $editedTargetDate, displayedComponents: .date)
                                    .datePickerStyle(GraphicalDatePickerStyle())
                                    .background(darkGray)
                                    .cornerRadius(12)
                            }
                        }
                        
                        // Category Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Category")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Picker("Category", selection: $editedCategory) {
                                ForEach(GoalCategory.allCases, id: \.self) { category in
                                    HStack {
                                        Text(category.icon)
                                        Text(category.displayName)
                                    }
                                    .tag(category)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                        
                        // Vision Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Vision Description")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text("Describe what your life will look like when you achieve this goal.")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            TextEditor(text: $editedVision)
                                .frame(minHeight: 120)
                                .padding(8)
                                .background(darkGray)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        }
                        
                        // Visualization Section (if exists)
                        if goal.visualization != nil {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Visualization (from onboarding)")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Text("This was created during your initial goal setup.")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                TextEditor(text: $editedVisualization)
                                    .frame(minHeight: 80)
                                    .padding(8)
                                    .background(darkGray)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                                    )
                            }
                        }
                        
                        Spacer(minLength: 50)
                    }
                    .padding()
                }
            }
            .navigationTitle("Edit Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        if hasUnsavedChanges {
                            showingUnsavedChangesAlert = true
                        } else {
                            dismiss()
                        }
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                        dismiss()
                    }
                    .foregroundColor(.blue)
                    .fontWeight(.semibold)
                    .disabled(editedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .preferredColorScheme(.dark)
        }
        .onAppear {
            setupInitialValues()
        }
        .alert("Unsaved Changes", isPresented: $showingUnsavedChangesAlert) {
            Button("Discard Changes", role: .destructive) {
                dismiss()
            }
            Button("Keep Editing", role: .cancel) {}
        } message: {
            Text("You have unsaved changes. Are you sure you want to discard them?")
        }
    }
    
    private func setupInitialValues() {
        editedText = goal.text
        editedVision = goal.userVision ?? ""
        editedVisualization = goal.visualization ?? ""
        editedCategory = goal.goalCategory
        
        if let targetDate = goal.targetDate {
            editedTargetDate = targetDate
            hasTargetDate = true
        } else {
            editedTargetDate = Calendar.current.date(byAdding: .month, value: 3, to: Date()) ?? Date()
            hasTargetDate = false
        }
    }
    
    private func saveChanges() {
        goal.text = editedText.trimmingCharacters(in: .whitespacesAndNewlines)
        goal.userVision = editedVision.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : editedVision.trimmingCharacters(in: .whitespacesAndNewlines)
        goal.visualization = editedVisualization.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : editedVisualization.trimmingCharacters(in: .whitespacesAndNewlines)
        goal.targetDate = hasTargetDate ? editedTargetDate : nil
        goal.goalCategory = editedCategory
        
        try? modelContext.save()
    }
}

// Preview
struct EditGoalView_Previews: PreviewProvider {
    static var previews: some View {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: Goal.self, configurations: config)
        
        let sampleGoal = Goal(
            text: "Live in Denver",
            order: 0,
            targetDate: Calendar.current.date(byAdding: .day, value: 365, to: Date()),
            visualization: "I see myself waking up to mountain views every morning, feeling energized and inspired by the natural beauty around me.",
            userVision: "I'll have a porch or balcony with a view of the mountains. I'll have new friends quickly, and a girlfriend. My parents will come visit."
        )
        
        container.mainContext.insert(sampleGoal)
        
        return EditGoalView(goal: sampleGoal)
            .modelContainer(container)
    }
}
