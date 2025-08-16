import SwiftUI
import SwiftData

struct GoalAlignmentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let goal: Goal
    let prompt: String // The prompt is now passed in directly.
    let onComplete: () -> Void // Closure to call when alignment is complete
    
    @State private var journalResponse: String = ""
    @State private var showingCompletionView: Bool = false
    
    // Access AIPromptService through environment
    @EnvironmentObject private var aiService: AIPromptService
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.black, Color(UIColor(red: 0x1A/255.0, green: 0x1A/255.0, blue: 0x2E/255.0, alpha: 1.0))]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Goal display
                        Text(goal.text)
                            .font(.title2.bold())
                            .foregroundColor(.white)
                            .padding(.bottom, 8)
                        
                        // Journal prompt section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Today's Journal Prompt")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                if aiService.isLoading {
                                    Spacer()
                                    ProgressView()
                                        .tint(.white)
                                }
                            }
                            
                            Text(prompt)
                                .font(.body)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.purple.opacity(0.2))
                                .cornerRadius(10)
                        }
                        
                        // Journal response section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Now, respond to the prompt above as if you are experiencing this reality.")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            TextEditor(text: $journalResponse)
                                .frame(minHeight: 200)
                                .padding(10)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                        }
                        
                        // Save button
                        Button(action: saveJournalEntry) {
                            Text("Complete Alignment")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(journalResponse.isEmpty ? Color.gray : Color.purple)
                                .cornerRadius(10)
                        }
                        .disabled(journalResponse.isEmpty)
                        .padding(.top, 16)
                    }
                    .padding()
                }
            }
            .navigationTitle("Goal Alignment")
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


            .fullScreenCover(isPresented: $showingCompletionView) {
                CompletionView(alignedGoals: [goal]) {
                    // When CompletionView is dismissed, call onComplete to move to next goal
                    showingCompletionView = false
                    onComplete()
                }
            }
        }
    }
    

    
    private func saveJournalEntry() {
        let trimmedResponse = journalResponse.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedResponse.isEmpty else { return }
        
        // Create and save journal entry
        let entry = JournalEntry(
            date: Date(),
            prompt: prompt,
            response: trimmedResponse,
            goal: goal
        )
        
        modelContext.insert(entry)
        
        // Create or update today's alignment record
        let today = Calendar.current.startOfDay(for: .now)
        
        // Check if today's alignment already exists
        // We need to use start and end of day for comparison since isDate(_:inSameDayAs:) isn't supported in predicates
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let fetchDescriptor = FetchDescriptor<DailyAlignment>(
            predicate: #Predicate { alignment in
                alignment.date >= startOfDay && alignment.date < endOfDay
            }
        )
        
        do {
            let existingAlignments = try modelContext.fetch(fetchDescriptor)
            
            if let existingAlignment = existingAlignments.first {
                // Add this goal to the existing alignment if not already included
                if !existingAlignment.goals.contains(where: { $0.id == goal.id }) {
                    existingAlignment.goals.append(goal)
                    print("[DEBUG] Added goal \(goal.text) to existing alignment")
                }
            } else {
                // Create a new alignment for today with this goal
                let newAlignment = DailyAlignment(date: today, completed: true, goals: [goal])
                modelContext.insert(newAlignment)
                print("[DEBUG] Created new alignment with goal \(goal.text)")
            }
            
            try modelContext.save()
            
            // Debug: print all alignments and their goals after saving
            let allAlignments = try modelContext.fetch(FetchDescriptor<DailyAlignment>())
            print("[DEBUG] All alignments after save:")
            for a in allAlignments {
                print("[DEBUG] alignment: \(a.date) completed: \(a.completed) goals: \(a.goals.map { $0.text })")
            }
        } catch {
            print("[ERROR] Failed to save alignment: \(error)")
        }
        
        // Show completion view
        showingCompletionView = true
    }
}

// Color extension removed to avoid duplicate declarations

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Goal.self, ActionItem.self, JournalEntry.self, configurations: config)
    
    // Add sample data
    let goal = Goal(text: "I will live in NYC within one year.", order: 0, targetDate: Calendar.current.date(byAdding: .year, value: 1, to: Date()))
    goal.userVision = "I see myself walking through Central Park on a crisp fall morning, heading to my favorite coffee shop before going to my dream job."
    container.mainContext.insert(goal)
    
    // Create AIPromptService for preview
    let aiService = AIPromptService(apiKey: "dummy-key-for-preview")
    
    return GoalAlignmentView(
        goal: goal, 
        prompt: "This is a preview prompt. What is one step you can take today?",
        onComplete: {}
    )
        .modelContainer(container)
        .environmentObject(aiService)
}
