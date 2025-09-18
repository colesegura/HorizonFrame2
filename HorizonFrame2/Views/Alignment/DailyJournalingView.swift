import SwiftUI
import SwiftData

struct DailyJournalingView: View {
    @Binding var currentPage: Int
    let onComplete: () -> Void
    
    @Environment(\.modelContext) private var modelContext
    @Query private var userInterests: [UserInterest]
    @Query private var journalSessions: [JournalSession]
    @State private var currentResponse = ""
    @State private var currentPrompt = ""
    @State private var isLoading = false
    @State private var currentInterestIndex = 0
    @State private var selectedDate = Date()
    @StateObject private var aiService = AIPromptService()
    
    // Use all interests, not just completed baseline ones
    private var availableInterests: [UserInterest] {
        userInterests.filter { $0.isActive }
    }
    
    private var currentInterest: UserInterest? {
        guard currentInterestIndex < availableInterests.count else { return nil }
        return availableInterests[currentInterestIndex]
    }
    
    private var isLastInterest: Bool {
        // If no interests, treat as single general prompt (always last)
        if availableInterests.isEmpty {
            return true
        }
        return currentInterestIndex >= availableInterests.count - 1
    }
    
    private var weekDays: [Date] {
        let calendar = Calendar.current
        let today = Date()
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
        return (0..<7).compactMap {
            calendar.date(byAdding: .day, value: $0, to: startOfWeek)
        }
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea(.all)
            
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 16) {
                    Text("Morning Alignment")
                        .font(.title.bold())
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    // Weekly Calendar
                    HStack(spacing: 8) {
                        ForEach(weekDays, id: \.self) { date in
                            ReflectionWeekDayView(
                                date: date,
                                isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate),
                                score: getScoreForDate(date)
                            )
                            .onTapGesture {
                                selectedDate = date
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                Spacer()
                
                // Content Area
                VStack(spacing: 30) {
                    // Reflection Header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .bottom, spacing: 0) {
                            Text("Reflection")
                                .font(.largeTitle.bold())
                                .foregroundColor(.white)
                            
                            if let interest = currentInterest {
                                Text(" - ")
                                    .font(.title2)
                                    .foregroundColor(.gray)
                                Text(interest.displayName)
                                    .font(.title2)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // AI Prompt
                    if !currentPrompt.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text(currentPrompt)
                                .font(.title3)
                                .foregroundColor(.white)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer()
                    
                    // Text Input Area
                    VStack(alignment: .leading, spacing: 12) {
                        TextEditor(text: $currentResponse)
                            .font(.body)
                            .foregroundColor(.white)
                            .background(Color.black)
                            .frame(minHeight: 200)
                            .padding(.horizontal, 20)
                            .onTapGesture {
                                // Focus the text editor
                            }
                    }
                }
                
                Spacer()
                
                // Navigation buttons
                HStack(spacing: 16) {
                    if currentInterestIndex > 0 {
                        Button(action: previousInterest) {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("Previous")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(15)
                        }
                    }
                    
                    Button(action: nextInterest) {
                        HStack {
                            Text(isLastInterest ? "Complete" : "Next")
                            if !isLastInterest {
                                Image(systemName: "chevron.right")
                            }
                        }
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(currentResponse.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.white)
                        .cornerRadius(15)
                    }
                    .disabled(currentResponse.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            loadPromptForCurrentInterest()
        }
    }
    
    private func loadPromptForCurrentInterest() {
        guard let interest = currentInterest else {
            // No interests with completed baseline, use a general prompt
            currentPrompt = "What's one thing you want to focus on improving today?"
            return
        }
        
        isLoading = true
        
        Task {
            let prompt = await aiService.generateContextualJournalPrompt(
                for: interest,
                previousSession: getLastJournalSession(for: interest),
                isEvening: false
            )
            
            await MainActor.run {
                currentPrompt = prompt
                isLoading = false
            }
        }
    }
    
    private func getLastJournalSession(for interest: UserInterest) -> JournalSession? {
        // Get the most recent journal session for this interest from all sessions
        return journalSessions.filter { session in
            session.userInterest?.id == interest.id
        }.sorted { $0.date > $1.date }.first
    }
    
    private func previousInterest() {
        saveCurrentResponse()
        
        if currentInterestIndex > 0 {
            currentInterestIndex -= 1
            currentResponse = ""
            loadPromptForCurrentInterest()
        }
    }
    
    private func nextInterest() {
        saveCurrentResponse()
        
        if isLastInterest {
            completeJournaling()
        } else {
            currentInterestIndex += 1
            currentResponse = ""
            loadPromptForCurrentInterest()
        }
    }
    
    private func saveCurrentResponse() {
        guard !currentResponse.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let session = JournalSession(
            type: .dailyAlignment,
            prompt: currentPrompt,
            userInterest: currentInterest // Can be nil for general prompts
        )
        session.response = currentResponse
        session.completed = true
        session.aiGenerated = currentInterest != nil // Only AI generated if we have an interest
        
        modelContext.insert(session)
        
        do {
            try modelContext.save()
        } catch {
            print("Error saving journal session: \(error)")
        }
    }
    
    private func completeJournaling() {
        onComplete()
    }
    
    private func getScoreForDate(_ date: Date) -> Int? {
        guard let interest = currentInterest else { return nil }
        
        let calendar = Calendar.current
        let sessions = journalSessions.filter { session in
            guard let sessionInterest = session.userInterest,
                  sessionInterest.id == interest.id,
                  session.sessionType == .dailyReview else { return false }
            return calendar.isDate(session.date, inSameDayAs: date)
        }
        
        return sessions.first?.progressScore
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: UserInterest.self, JournalSession.self, configurations: config)
    
    let userInterest = UserInterest(type: .health, subcategory: "Diet")
    userInterest.baselineCompleted = true
    container.mainContext.insert(userInterest)
    
    return DailyJournalingView(currentPage: .constant(3), onComplete: {})
        .modelContainer(container)
        .preferredColorScheme(.dark)
}
