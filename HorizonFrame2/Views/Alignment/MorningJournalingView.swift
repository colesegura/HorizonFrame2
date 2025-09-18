import SwiftUI
import SwiftData

struct MorningJournalingView: View {
    @Binding var currentPage: Int
    let onComplete: () -> Void
    
    @Environment(\.modelContext) private var modelContext
    @Query private var userInterests: [UserInterest]
    @Query(sort: \JournalSession.date, order: .reverse) private var journalSessions: [JournalSession]
    
    @State private var currentResponse = ""
    @State private var currentPrompt = ""
    @State private var isLoading = false
    @State private var currentInterestIndex = 0
    @State private var commitmentScores: [String: Int] = [:] // Interest display name to commitment level mapping
    @StateObject private var aiService = AIPromptService()
    
    // Use all active interests
    private var availableInterests: [UserInterest] {
        userInterests.filter { $0.isActive }
    }
    
    private var currentInterest: UserInterest? {
        guard currentInterestIndex < availableInterests.count else { return nil }
        return availableInterests[currentInterestIndex]
    }
    
    private var isLastInterest: Bool {
        availableInterests.isEmpty || currentInterestIndex >= availableInterests.count - 1
    }
    
    // Get previous evening session for current interest
    private var previousEveningSession: JournalSession? {
        guard let interest = currentInterest else { return nil }
        
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let yesterdayStart = Calendar.current.startOfDay(for: yesterday)
        let todayStart = Calendar.current.startOfDay(for: Date())
        
        return journalSessions.first { session in
            session.userInterest?.id == interest.id &&
            session.sessionType == .dailyReview &&
            session.date >= yesterdayStart &&
            session.date < todayStart
        }
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 16) {
                    Text("Morning Alignment")
                        .font(.title.bold())
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    if let interest = currentInterest {
                        Text("Focus: \(interest.displayName)")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(20)
                    } else if availableInterests.isEmpty {
                        Text("General Alignment")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(20)
                    }
                    
                    if availableInterests.count > 1 {
                        Text("\(currentInterestIndex + 1) of \(availableInterests.count)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 40)
                
                // Previous evening reflection reference
                if let eveningSession = previousEveningSession {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Yesterday evening you reflected:")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Text(eveningSession.response)
                            .font(.body)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(12)
                        
                        if let score = eveningSession.progressScore {
                            Text("Progress Score: \(score)/10")
                                .font(.caption)
                                .foregroundColor(.purple)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer()
                
                // Prompt and response area
                VStack(spacing: 24) {
                    if !currentPrompt.isEmpty {
                        Text(currentPrompt)
                            .font(.title2.bold())
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    
                    // Text input
                    VStack(alignment: .leading, spacing: 8) {
                        TextEditor(text: $currentResponse)
                            .font(.body)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(12)
                            .frame(minHeight: 120)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        
                        if currentResponse.isEmpty {
                            Text("Set your intention and commitment for today...")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.leading, 4)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Commitment level slider with diet-specific context
                    if let interest = currentInterest {
                        VStack(alignment: .leading, spacing: 12) {
                            if interest.healthSubcategory == .diet {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("How committed are you to your nutrition today? (1-10)")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    
                                    Text("Level \(interest.currentLevel)/10 • \(getDietLevelDescription(interest.currentLevel))")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                            } else {
                                Text("How committed are you today? (1-10)")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            
                            HStack {
                                Text("1")
                                    .foregroundColor(.gray)
                                
                                Slider(
                                    value: Binding(
                                        get: { Double(commitmentScores[interest.displayName] ?? 7) },
                                        set: { commitmentScores[interest.displayName] = Int($0) }
                                    ),
                                    in: 1...10,
                                    step: 1
                                )
                                .accentColor(.blue)
                                
                                Text("10")
                                    .foregroundColor(.gray)
                            }
                            
                            HStack {
                                Text("Commitment: \(commitmentScores[interest.displayName] ?? 7)")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                                
                                Spacer()
                                
                                if interest.healthSubcategory == .diet && !interest.weeklyProgressScores.isEmpty {
                                    let avgScore = interest.weeklyProgressScores.reduce(0, +) / interest.weeklyProgressScores.count
                                    Text("Recent Avg: \(avgScore)/10")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal, 20)
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
            print("📝 MorningJournalingView appeared! Available interests: \(availableInterests.count)")
            loadPromptForCurrentInterest()
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private func loadPromptForCurrentInterest() {
        guard let interest = currentInterest else {
            // No interests available, use a general morning prompt
            currentPrompt = "What are your intentions for today? How do you want to show up?"
            return
        }
        
        // Initialize commitment score if not set (default to 7 for morning optimism)
        if commitmentScores[interest.displayName] == nil {
            commitmentScores[interest.displayName] = 7
        }
        
        isLoading = true
        
        Task {
            let prompt = await aiService.generateContextualJournalPrompt(
                for: interest,
                previousSession: previousEveningSession,
                isEvening: false // This is morning
            )
            
            await MainActor.run {
                currentPrompt = prompt
                isLoading = false
            }
        }
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
        
        // Handle case where there's no specific interest (general journaling)
        guard let interest = currentInterest else {
            let session = JournalSession(
                type: .dailyAlignment,
                prompt: currentPrompt,
                userInterest: nil
            )
            session.response = currentResponse
            session.completed = true
            session.aiGenerated = false
            session.progressScore = 7 // Default commitment level
            
            modelContext.insert(session)
            
            do {
                try modelContext.save()
            } catch {
                print("Error saving general morning journal session: \(error)")
            }
            return
        }
        
        let currentCommitment = commitmentScores[interest.displayName] ?? 7
        
        let session = JournalSession(
            type: .dailyAlignment,
            prompt: currentPrompt,
            userInterest: interest
        )
        session.response = currentResponse
        session.completed = true
        session.aiGenerated = true
        session.progressScore = currentCommitment
        
        modelContext.insert(session)
        
        // Update morning commitment tracking for diet
        if interest.healthSubcategory == .diet {
            updateMorningCommitment(interest: interest, commitment: currentCommitment)
        }
        
        do {
            try modelContext.save()
        } catch {
            print("Error saving morning journal session: \(error)")
        }
    }
    
    private func updateMorningCommitment(interest: UserInterest, commitment: Int) {
        // Store morning commitment for evening comparison
        interest.lastProgressUpdate = Date()
        
        // Could add morning-specific tracking here if needed
        print("💪 Morning commitment set: \(commitment)/10 for \(interest.displayName)")
    }
    
    private func completeJournaling() {
        // Complete the entire alignment flow
        onComplete()
    }
    
    private func getDietLevelDescription(_ level: Int) -> String {
        switch level {
        case 1...2:
            return "Basic Awareness"
        case 3...4:
            return "Structured Approach"
        case 5...6:
            return "Lifestyle Integration"
        case 7...8:
            return "Mindful Mastery"
        case 9...10:
            return "Holistic Optimization"
        default:
            return "Getting Started"
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: UserInterest.self, JournalSession.self, configurations: config)
    
    let userInterest = UserInterest(type: .health, subcategory: "Diet")
    userInterest.baselineCompleted = true
    container.mainContext.insert(userInterest)
    
    return MorningJournalingView(currentPage: .constant(3), onComplete: {})
        .modelContainer(container)
        .preferredColorScheme(.dark)
}
