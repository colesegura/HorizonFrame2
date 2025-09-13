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
                // Full screen black background - matching Today page
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Back button at top
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 20))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 60)
                    
                    // Goal title - matching Today page style
                    Text(goal.text)
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                    
                    // Journal prompt
                    VStack(spacing: 16) {
                        Text("Today's Reflection")
                            .font(.system(size: 20))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text(prompt)
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                    
                    Spacer()
                    
                    // Journal response section
                    VStack(spacing: 16) {
                        Text("Write your response")
                            .font(.system(size: 18))
                            .foregroundColor(.white.opacity(0.8))
                        
                        TextEditor(text: $journalResponse)
                            .frame(minHeight: 150)
                            .padding(16)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                            .foregroundColor(.white)
                            .font(.system(size: 16))
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                    
                    // Complete button - matching Today page style
                    Button(action: saveJournalEntry) {
                        Text("Complete Alignment")
                    }
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black)
                    .frame(width: 320, height: 60)
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .fill(journalResponse.isEmpty ? Color.white.opacity(0.3) : Color.white)
                            .shadow(color: .white.opacity(0.3), radius: 10, x: 0, y: 0)
                    )
                    .disabled(journalResponse.isEmpty)
                    .padding(.bottom, 60)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .preferredColorScheme(.dark)
            .statusBar(hidden: true)
            .fullScreenCover(isPresented: $showingCompletionView) {
                CompletionView(alignedGoals: [goal]) {
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
