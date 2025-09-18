import SwiftUI
import SwiftData

struct EveningJournalingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query private var userInterests: [UserInterest]
    @Query(sort: \JournalSession.date, order: .reverse) private var journalSessions: [JournalSession]
    
    @State private var currentResponse = ""
    @State private var currentPrompt = ""
    @State private var isLoading = true
    @State private var currentInterestIndex = 0
    @State private var progressScores: [String: Int] = [:] // Interest display name to score mapping
    @State private var selectedDate = Date()
    @State private var showCompletionSummary = false
    @StateObject private var aiService = AIPromptService()
    
    let onComplete: () -> Void
    
    // Use all interests, not just completed baseline ones
    private var availableInterests: [UserInterest] {
        userInterests.filter { $0.isActive }
    }
    
    private var currentInterest: UserInterest? {
        guard currentInterestIndex < availableInterests.count else { return nil }
        return availableInterests[currentInterestIndex]
    }
    
    private var isLastInterest: Bool {
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
    
    // Get morning journal session for current interest
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
                // Background
                Color.black
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 20) {
                        HStack {
                            Button(action: { dismiss() }) {
                                Image(systemName: "arrow.left")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        Text("Evening Reflection")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                        
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
                    .padding(.bottom, 30)
                
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
                    
                        Spacer()
                        
                        // Continue Button
                        HStack {
                            Spacer()
                            Button(action: {
                                saveCurrentResponse()
                                
                                if isLastInterest {
                                    completeJournaling()
                                } else {
                                    currentInterestIndex += 1
                                    loadPromptForCurrentInterest()
                                }
                            }) {
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.black)
                                    .frame(width: 50, height: 50)
                                    .background(Color.white)
                                    .clipShape(Circle())
                            }
                            .disabled(currentResponse.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            .padding(.trailing, 20)
                            .padding(.bottom, 40)
                        }
                    }
                }
            }
        }.onAppear {
            loadPromptForCurrentInterest()
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(.white)
            }
        }
        .sheet(isPresented: $showCompletionSummary) {
            EveningJournalingCompletionView(onFinish: onComplete)
        }
    }
    
    private func loadPromptForCurrentInterest() {
        guard let interest = currentInterest else {
            // No interests available, use a general evening prompt
            currentPrompt = "How did your day go? What are you grateful for today?"
            return
        }
        
        // Initialize progress score if not set
        if progressScores[interest.displayName] == nil {
            progressScores[interest.displayName] = 5
        }
        
        isLoading = true
        
        Task {
            let prompt = await aiService.generateContextualJournalPrompt(
                for: interest,
                previousSession: morningSession,
                allSessions: journalSessions,
                isEvening: true
            )
            
            await MainActor.run {
                currentPrompt = prompt
                isLoading = false
            }
        }
    }
    
    private func saveCurrentResponse() {
        guard !currentResponse.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        // Handle case where there's no specific interest (general journaling)
        guard let interest = currentInterest else {
            let session = JournalSession(
                type: .dailyReview,
                prompt: currentPrompt,
                userInterest: nil
            )
            session.response = currentResponse
            session.completed = true
            session.aiGenerated = false
            session.progressScore = 5
            
            modelContext.insert(session)
            
            do {
                try modelContext.save()
            } catch {
                print("Error saving general evening journal session: \(error)")
            }
            return
        }
        
        let currentScore = progressScores[interest.displayName] ?? 5
        
        let session = JournalSession(
            type: .dailyReview,
            prompt: currentPrompt,
            userInterest: interest
        )
        session.response = currentResponse
        session.completed = true
        session.aiGenerated = true
        session.progressScore = currentScore
        
        modelContext.insert(session)
        
        // Update diet-specific tracking and check for level advancement
        if interest.healthSubcategory == .diet {
            updateDietProgress(interest: interest, score: currentScore)
        }
        
        do {
            try modelContext.save()
        } catch {
            print("Error saving evening journal session: \(error)")
        }
    }
    
    private func updateDietProgress(interest: UserInterest, score: Int) {
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
            
            // Show level advancement (could add UI feedback here)
            print("🎉 Advanced to level \(interest.currentLevel) in \(interest.displayName)!")
        }
    }
    
    private func completeJournaling() {
        showCompletionSummary = true
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

struct EveningJournalingCompletionView: View {
    let onFinish: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // Success icon
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.green)
                
                // Title
                Text("Evening Reflection Complete")
                    .font(.title.bold())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                // Subtitle
                Text("Your insights have been saved. Great work reflecting on your day!")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Spacer()
                
                // Finish button
                Button(action: {
                    dismiss()
                    onFinish()
                }) {
                    Text("Finish Review")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .cornerRadius(16)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
    }
}

struct ReflectionWeekDayView: View {
    let date: Date
    let isSelected: Bool
    let score: Int?
    
    private let calendar = Calendar.current
    
    private var dayAbbreviation: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date).uppercased()
    }
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    private var isToday: Bool {
        calendar.isDateInToday(date)
    }
    
    private var backgroundColor: Color {
        if let score = score {
            return Color.green.opacity(0.3)
        } else if isToday {
            return Color.clear
        } else {
            return Color.clear
        }
    }
    
    private var borderColor: Color {
        if isSelected {
            return .white
        } else if isToday {
            return .white
        } else if score != nil {
            return Color.green.opacity(0.6)
        } else {
            return Color.gray.opacity(0.5)
        }
    }
    
    private var textColor: Color {
        if isSelected {
            return .white
        } else if isToday {
            return .white
        } else if score != nil {
            return .white
        } else {
            return .gray
        }
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Text(dayAbbreviation)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(textColor)
            
            Text(dayNumber)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(textColor)
        }
        .frame(width: 40, height: 60)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(borderColor, lineWidth: 1)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(backgroundColor)
                )
        )
        .scaleEffect(isSelected ? 1.1 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: UserInterest.self, JournalSession.self, configurations: config)
    
    let userInterest = UserInterest(type: .health, subcategory: "Diet")
    userInterest.baselineCompleted = true
    container.mainContext.insert(userInterest)
    
    return EveningJournalingView(onComplete: {})
        .modelContainer(container)
        .preferredColorScheme(.dark)
}
