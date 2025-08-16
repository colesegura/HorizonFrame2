import SwiftUI
import SwiftData

struct GoalAlignmentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let goal: Goal
    @State private var journalPrompt: String = "Loading your personalized prompt..."
    @State private var journalResponse: String = ""
    @State private var showingCompletionAlert: Bool = false
    @State private var showingErrorAlert: Bool = false
    
    // Access AIPromptService through environment
    @EnvironmentObject private var aiService: AIPromptService
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.black, Color(hex: "1A1A2E")]),
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
                            
                            Text(journalPrompt)
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
            .onAppear {
                loadJournalPrompt()
            }
            .alert("Error", isPresented: $showingErrorAlert) {
                Button("Try Again") {
                    loadJournalPrompt()
                }
                Button("Use Offline Prompt") {
                    journalPrompt = aiService.generateOfflinePrompt(for: goal)
                    aiService.resetError()
                }
            } message: {
                Text(aiService.errorMessage ?? "An unknown error occurred.")
            }
            .alert("Alignment Complete", isPresented: $showingCompletionAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Your journal entry has been saved. Keep aligning with your goals daily for best results.")
            }
        }
    }
    
    private func loadJournalPrompt() {
        // Always generate a new prompt for each alignment session
        Task {
            let prompt = await aiService.generateJournalPrompt(for: goal)
            
            // Update UI on main thread
            await MainActor.run {
                journalPrompt = prompt
                goal.currentPrompt = prompt
                try? modelContext.save()
                
                // Show error alert if there was an error
                if aiService.errorMessage != nil {
                    showingErrorAlert = true
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
            prompt: journalPrompt,
            response: trimmedResponse,
            goal: goal
        )
        
        modelContext.insert(entry)
        try? modelContext.save()
        
        // Show completion alert
        showingCompletionAlert = true
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Goal.self, ActionItem.self, JournalEntry.self, configurations: config)
    
    // Add sample data
    let goal = Goal(text: "I will live in NYC within one year.", order: 0, targetDate: Calendar.current.date(byAdding: .year, value: 1, to: Date()))
    goal.userVision = "I see myself walking through Central Park on a crisp fall morning, heading to my favorite coffee shop before going to my dream job."
    container.mainContext.insert(goal)
    
    // Create AIPromptService for preview
    let aiService = AIPromptService(apiKey: "dummy-key-for-preview")
    
    return GoalAlignmentView(goal: goal)
        .modelContainer(container)
        .environmentObject(aiService)
}
