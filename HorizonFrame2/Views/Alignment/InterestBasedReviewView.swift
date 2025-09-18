import SwiftUI
import SwiftData

struct InterestBasedReviewView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query private var userInterests: [UserInterest]
    @Query(sort: \JournalSession.date, order: .reverse) private var journalSessions: [JournalSession]
    
    @State private var currentInterestIndex = 0
    @State private var progressScores: [String: Int] = [:] // Interest ID to score mapping
    @State private var reflectionTexts: [String: String] = [:] // Interest ID to reflection mapping
    @State private var currentReflection = ""
    @StateObject private var aiService = AIPromptService()
    
    let onComplete: () -> Void
    
    private var activeInterests: [UserInterest] {
        userInterests.filter { $0.isActive }
    }
    
    private var currentInterest: UserInterest? {
        guard currentInterestIndex < activeInterests.count else { return nil }
        return activeInterests[currentInterestIndex]
    }
    
    private var isLastInterest: Bool {
        currentInterestIndex >= activeInterests.count - 1
    }
    
    private var currentScore: Int {
        guard let interest = currentInterest else { return 5 }
        return progressScores[interest.id.hashValue.description] ?? 5
    }
    
    // Get morning alignment session for current interest
    private var morningSession: JournalSession? {
        guard let interest = currentInterest else { return nil }
        
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        
        return journalSessions.first { session in
            session.userInterest?.id == interest.id &&
            session.sessionType == .dailyAlignment &&
            session.date >= today &&
            session.date < tomorrow
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Header
                    VStack(spacing: 16) {
                        HStack {
                            Button("Cancel") {
                                dismiss()
                            }
                            .foregroundColor(.white)
                            
                            Spacer()
                            
                            Text("\(currentInterestIndex + 1) of \(activeInterests.count)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        Text("Interest Review")
                            .font(.title.bold())
                            .foregroundColor(.white)
                        
                        if let interest = currentInterest {
                            Text(interest.displayName)
                                .font(.title2)
                                .foregroundColor(.gray)
                        }
                        
                        // Progress indicator
                        HStack(spacing: 8) {
                            ForEach(0..<activeInterests.count, id: \.self) { index in
                                Circle()
                                    .fill(index <= currentInterestIndex ? Color.blue : Color.gray.opacity(0.3))
                                    .frame(width: 8, height: 8)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Content
                    VStack(spacing: 24) {
                        // Morning commitment reference
                        if let session = morningSession, !session.response.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("This morning you committed to:")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Text(session.response)
                                    .font(.body)
                                    .foregroundColor(.gray)
                                    .padding()
                                    .background(Color.white.opacity(0.05))
                                    .cornerRadius(12)
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // Score question
                        VStack(alignment: .leading, spacing: 16) {
                            if let interest = currentInterest {
                                Text("How well did you stick to your \(interest.displayName.lowercased()) goals today?")
                                    .font(.title3.bold())
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                            }
                            
                            // Visual score slider
                            VStack(spacing: 12) {
                                HStack {
                                    Text("Not at all")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    
                                    Spacer()
                                    
                                    Text("Perfectly")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                
                                // Custom slider with visual feedback
                                ZStack {
                                    // Background track
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(height: 12)
                                    
                                    // Progress track
                                    HStack {
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(LinearGradient(
                                                colors: [.red, .orange, .yellow, .green],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            ))
                                            .frame(width: CGFloat(currentScore) / 10.0 * (UIScreen.main.bounds.width - 80), height: 12)
                                        
                                        Spacer()
                                    }
                                }
                                .onTapGesture { location in
                                    let width = UIScreen.main.bounds.width - 80
                                    let score = max(1, min(10, Int((location.x / width) * 10) + 1))
                                    updateScore(score)
                                }
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            let width = UIScreen.main.bounds.width - 80
                                            let score = max(1, min(10, Int((value.location.x / width) * 10) + 1))
                                            updateScore(score)
                                        }
                                )
                                
                                Text("\(currentScore)/10")
                                    .font(.title2.bold())
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Reflection question
                        VStack(alignment: .leading, spacing: 12) {
                            Text("What went well? What could you improve tomorrow?")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            TextEditor(text: $currentReflection)
                                .font(.body)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(12)
                                .frame(minHeight: 100)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        }
                        .padding(.horizontal, 20)
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
                                Text(isLastInterest ? "Complete Review" : "Next")
                                if !isLastInterest {
                                    Image(systemName: "chevron.right")
                                }
                            }
                            .font(.headline)
                            .foregroundColor(.black)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(15)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            setupInitialScores()
            loadReflectionForCurrentInterest()
        }
    }
    
    private func setupInitialScores() {
        for interest in activeInterests {
            if progressScores[interest.id.hashValue.description] == nil {
                progressScores[interest.id.hashValue.description] = 5
            }
            if reflectionTexts[interest.id.hashValue.description] == nil {
                reflectionTexts[interest.id.hashValue.description] = ""
            }
        }
        
        // Load current reflection
        if let interest = currentInterest {
            let reflection = reflectionTexts[interest.id.hashValue.description] ?? ""
        }
    }
    
    private func loadReflectionForCurrentInterest() {
        guard let interest = currentInterest else { return }
        currentReflection = reflectionTexts[interest.id.hashValue.description] ?? ""
    }
    
    private func updateScore(_ score: Int) {
        guard let interest = currentInterest else { return }
        progressScores[interest.id.hashValue.description] = score
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    private func saveCurrentInterest() {
        guard let interest = currentInterest else { return }
        
        // Save reflection text
        reflectionTexts[interest.id.hashValue.description] = currentReflection
        
        // Create journal session for this interest review
        let session = JournalSession(
            type: .dailyReview,
            prompt: "How well did you stick to your \(interest.displayName.lowercased()) goals today?",
            userInterest: interest
        )
        session.response = currentReflection
        session.progressScore = currentScore
        session.completed = true
        session.aiGenerated = false
        
        modelContext.insert(session)
        
        // Update interest progress tracking
        updateInterestProgress(interest: interest, score: currentScore)
        
        do {
            try modelContext.save()
        } catch {
            print("Error saving interest review: \(error)")
        }
    }
    
    private func updateInterestProgress(interest: UserInterest, score: Int) {
        // Add score to weekly tracking
        interest.weeklyProgressScores.append(score)
        
        // Keep only last 7 scores
        if interest.weeklyProgressScores.count > 7 {
            interest.weeklyProgressScores = Array(interest.weeklyProgressScores.suffix(7))
        }
        
        // Check if user should advance to next level
        if aiService.checkAndAdvanceLevel(for: interest, currentScore: score) {
            interest.currentLevel += 1
            interest.lastProgressUpdate = Date()
            
            // Show level advancement feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            print("🎉 Advanced to level \(interest.currentLevel) in \(interest.displayName)!")
        }
    }
    
    private func previousInterest() {
        saveCurrentInterest()
        
        if currentInterestIndex > 0 {
            currentInterestIndex -= 1
            loadReflectionForCurrentInterest()
        }
    }
    
    private func nextInterest() {
        saveCurrentInterest()
        
        if isLastInterest {
            completeReview()
        } else {
            currentInterestIndex += 1
            loadReflectionForCurrentInterest()
        }
    }
    
    private func completeReview() {
        // Save any remaining data
        saveCurrentInterest()
        
        // Complete the review process
        onComplete()
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: UserInterest.self, JournalSession.self, configurations: config)
    
    let dietInterest = UserInterest(type: .health, subcategory: "Diet")
    let stressInterest = UserInterest(type: .stress)
    
    container.mainContext.insert(dietInterest)
    container.mainContext.insert(stressInterest)
    
    return InterestBasedReviewView(onComplete: {})
        .modelContainer(container)
        .preferredColorScheme(.dark)
}
