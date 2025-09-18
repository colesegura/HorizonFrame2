import Foundation
import SwiftUI

// Mock OpenAI API client until we can add the real dependency
class OpenAI {
    let apiToken: String
    
    init(apiToken: String) {
        self.apiToken = apiToken
    }
    
    struct ChatQuery {
        let model: Model
        let messages: [Chat]
        let maxTokens: Int
        
        enum Model: String {
            case gpt4o = "gpt-4o"
        }
    }
    
    struct Chat {
        let role: Role
        let content: String
        
        enum Role: String {
            case system, user, assistant
        }
    }
    
    struct ChatResult {
        struct Choice {
            struct Message {
                let content: String
            }
            let message: Message
        }
        let choices: [Choice]
    }
    
    func chats(query: ChatQuery) async throws -> ChatResult {
        // Create URL request to OpenAI API
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            throw NSError(domain: "AIPromptService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Convert our query to the format expected by OpenAI API
        let messages = query.messages.map { chat in
            return ["role": chat.role.rawValue, "content": chat.content]
        }
        
        let requestBody: [String: Any] = [
            "model": query.model.rawValue,
            "messages": messages,
            "max_tokens": query.maxTokens
        ]
        
        // Serialize to JSON
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            throw NSError(domain: "AIPromptService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to serialize request"])
        }
        
        request.httpBody = jsonData
        
        // Make the API call
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Check for HTTP errors
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "AIPromptService", code: 3, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw NSError(domain: "AIPromptService", code: httpResponse.statusCode, 
                          userInfo: [NSLocalizedDescriptionKey: "API error: \(errorMessage)"])
        }
        
        // Parse the response
        struct OpenAIResponse: Decodable {
            struct Choice: Decodable {
                struct Message: Decodable {
                    let content: String
                }
                let message: Message
            }
            let choices: [Choice]
        }
        
        let decoder = JSONDecoder()
        let openAIResponse = try decoder.decode(OpenAIResponse.self, from: data)
        
        // Convert to our internal format
        return ChatResult(choices: openAIResponse.choices.map { choice in
            return ChatResult.Choice(message: ChatResult.Choice.Message(content: choice.message.content))
        })
    }
}

class AIPromptService: ObservableObject {
    private var openAI: OpenAI?
    private let systemPrompt = "You are a life coach helping someone visualize their future success."
    private let journalingSystemPrompt = "You are an intelligent journaling assistant that creates personalized, contextual prompts to help users develop self-awareness and achieve their goals. Your prompts should be specific, actionable, and build upon previous responses. For diet-related interests, create prompts that match the user's progression level (1-10), with higher levels requiring more sophisticated thinking about nutrition, mindfulness, and lifestyle integration."
    
    // Morning-oriented prompts
    private let morningPrompts = [
        "As you begin your day, imagine it's a morning after you've achieved your goal. Write a journal entry describing how this shapes your day ahead.",
        "Picture yourself waking up having achieved your goal. How does this morning feel different? Write about your mindset as you start the day.",
        "Visualize your morning routine after reaching your goal. Write about how your day begins and the energy you bring to it.",
        "Imagine planning your day knowing you've achieved what you set out to do. Write about your priorities and focus for today.",
        "Think about the first cup of coffee or tea of your day after achieving your goal. What thoughts and plans come to mind as you prepare for the day ahead?"
    ]
    
    // Evening-oriented prompts
    private let eveningPrompts = [
        "As you wind down your day, reflect on how tomorrow will be different once you've achieved your goal. Write about your expectations.",
        "Picture yourself reviewing your day's accomplishments after reaching your goal. Write about the satisfaction and next steps.",
        "Visualize an evening relaxing after a day lived in alignment with your achieved goal. Write about your reflections.",
        "Imagine sharing your day's experiences with someone after achieving your goal. What would you tell them about how your life has changed?",
        "Think about going to sleep with the knowledge that you've achieved your goal. Write about your thoughts as you plan for tomorrow."
    ]
    
    // General prompts (used as fallbacks)
    private let fallbackPrompts = [
        "Imagine it's a Saturday after you've achieved your goal. Write a journal entry describing what your day looks like.",
        "Picture yourself celebrating the achievement of your goal. What does that moment feel like? Write a journal entry about it.",
        "Visualize a typical day in your life after you've reached your goal. Write about what you see, feel, and experience.",
        "Imagine running into an old friend after achieving your goal. They ask how you're doing. Write a journal entry about this encounter.",
        "Think about the first day after you've achieved your goal. Write a journal entry describing your thoughts and feelings."
    ]
    
    // Published properties for UI updates
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    // Cache for prompts to reduce API calls
    private var promptCache: [String: String] = [:]
    
    // Network availability flag
    private var isNetworkAvailable: Bool {
        return NetworkMonitor.shared.isConnected
    }
    
    init(apiKey: String = APIConfig.openAIAPIKey) {
        if !apiKey.isEmpty && apiKey != "REPLACE_WITH_YOUR_API_KEY" {
            self.openAI = OpenAI(apiToken: apiKey)
        }
        
        // Load cached prompts from UserDefaults
        if let cachedData = UserDefaults.standard.data(forKey: "ai_prompt_cache"),
           let cachedPrompts = try? JSONDecoder().decode([String: String].self, from: cachedData) {
            self.promptCache = cachedPrompts
        }
    }
    
    func generateJournalPrompt(for goal: Goal, isEveningAlignment: Bool = false) async -> String {
        await MainActor.run { isLoading = true }
        
        // Generate a unique cache key with timestamp to ensure a new prompt each time
        let timestamp = Date().timeIntervalSince1970
        let cacheKey = "goal_\(goal.id)_\(timestamp)"
        
        // Skip cache and generate a new prompt each time
        if !isNetworkAvailable {
            await MainActor.run { isLoading = false }
            return getRandomFallbackPrompt(isEveningAlignment: isEveningAlignment)
        }
        
        // Check if network is available
        guard isNetworkAvailable, let openAI = self.openAI else {
            await MainActor.run { 
                isLoading = false 
                errorMessage = "No internet connection. Using offline prompt."
            }
            let fallbackPrompt = getRandomFallbackPrompt(isEveningAlignment: isEveningAlignment)
            return fallbackPrompt
        }
        
        // Check if we have the required data
        guard let userVision = goal.userVision, !userVision.isEmpty else {
            await MainActor.run { isLoading = false }
            return getRandomFallbackPrompt(isEveningAlignment: isEveningAlignment)
        }
        
        let targetDateString = goal.targetDate?.formatted(date: .long, time: .omitted) ?? "the future"
        
        do {
            // Create a query with our mock implementation
            let query = OpenAI.ChatQuery(
                model: .gpt4o,
                messages: [
                    OpenAI.Chat(role: .system, content: systemPrompt),
                    OpenAI.Chat(role: .user, content: """
                    Goal: \(goal.text)
                    Target date: \(targetDateString)
                    User's vision: \(String(userVision.suffix(1000)))
                    Time of day: \(isEveningAlignment ? "evening" : "morning")
                    
                    Create a specific, vivid journal prompt that helps them imagine a moment after achieving this goal.
                    The prompt should be in second person ("Imagine you are...") and should be specific to their goal.
                    Make it feel like a real moment they might experience after achieving their goal.
                    \(isEveningAlignment ? "Since it's evening, focus on reflection, planning for tomorrow, or winding down the day." : "Since it's morning, focus on starting the day, planning ahead, or morning activities.")
                    Keep the prompt under 3 sentences.
                    """)
                ],
                maxTokens: 150
            )
            
            let result = try await openAI.chats(query: query)
            
            if let promptContent = result.choices.first?.message.content {
                let trimmedPrompt = promptContent.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                
                // Cache the successful result
                promptCache[cacheKey] = trimmedPrompt
                savePromptCache()
                
                await MainActor.run { 
                    isLoading = false 
                    errorMessage = nil
                }
                
                return trimmedPrompt
            } else {
                await MainActor.run { 
                    isLoading = false 
                    errorMessage = "Received empty response from AI service."
                }
                return getRandomFallbackPrompt(isEveningAlignment: isEveningAlignment)
            }
        } catch {
            print("Error generating journal prompt: \(error)")
            await MainActor.run { 
                isLoading = false 
                errorMessage = "Failed to generate prompt: \(error.localizedDescription)"
            }
            return getRandomFallbackPrompt(isEveningAlignment: isEveningAlignment)
        }
    }
    
    private func getRandomFallbackPrompt(isEveningAlignment: Bool = false) -> String {
        if isEveningAlignment {
            return eveningPrompts.randomElement() ?? eveningPrompts[0]
        } else {
            return morningPrompts.randomElement() ?? morningPrompts[0]
        }
    }
    
    private func savePromptCache() {
        if let encodedData = try? JSONEncoder().encode(promptCache) {
            UserDefaults.standard.set(encodedData, forKey: "ai_prompt_cache")
        }
    }
    
    func clearCache() {
        promptCache.removeAll()
        UserDefaults.standard.removeObject(forKey: "ai_prompt_cache")
    }
    
    func resetError() {
        errorMessage = nil
    }
    
    // Generate a prompt without using the API for offline use
    func generateOfflinePrompt(for goal: Goal, isEveningAlignment: Bool = false) -> String {
        // Create a more personalized fallback prompt based on the goal text
        let goalText = goal.text.lowercased()
        
        if goalText.contains("live") || goalText.contains("move") || goalText.contains("home") {
            return "Imagine it's your first morning waking up in your new home. Write a journal entry about how it feels to finally be living where you've always wanted to be."
        } else if goalText.contains("job") || goalText.contains("career") || goalText.contains("work") || goalText.contains("business") {
            return "Imagine it's the end of a fulfilling day at your dream job or business. Write about what made today special and how it feels to be doing work you love."
        } else if goalText.contains("relationship") || goalText.contains("partner") || goalText.contains("love") || goalText.contains("marriage") {
            return "Picture a perfect day spent with your partner, now that you've built the relationship you've always wanted. Write about the moments that make you feel most connected and fulfilled."
        } else if goalText.contains("health") || goalText.contains("fitness") || goalText.contains("weight") || goalText.contains("exercise") {
            return "Imagine looking in the mirror and feeling completely satisfied with your health and fitness. Write about how your daily routine has changed and how your body feels now."
        } else if goalText.contains("money") || goalText.contains("financial") || goalText.contains("income") || goalText.contains("earn") {
            return "Visualize checking your bank account and seeing that you've reached your financial goal. Write about what this means for your life and the sense of security it brings."
        } else {
            return getRandomFallbackPrompt(isEveningAlignment: isEveningAlignment)
        }
    }
    
    // MARK: - Intelligent Journaling Methods
    
    // Generate baseline questions for a user interest
    func generateBaselinePrompt(for userInterest: UserInterest) async -> String {
        await MainActor.run { isLoading = true }
        
        guard isNetworkAvailable, let openAI = self.openAI else {
            await MainActor.run { isLoading = false }
            return getBaselineFallbackPrompt(for: userInterest)
        }
        
        let interestDescription = buildInterestDescription(userInterest)
        
        do {
            let query = OpenAI.ChatQuery(
                model: .gpt4o,
                messages: [
                    OpenAI.Chat(role: .system, content: journalingSystemPrompt),
                    OpenAI.Chat(role: .user, content: """
                    The user is interested in: \(interestDescription)
                    
                    Create a thoughtful baseline question that helps establish where they currently are with this interest.
                    The question should be open-ended and encourage honest self-reflection.
                    Keep it under 2 sentences and make it feel conversational.
                    
                    Examples of good baseline questions:
                    - "How do you feel about your current diet?"
                    - "What's your relationship with stress like right now?"
                    - "How satisfied are you with your current productivity levels?"
                    """)
                ],
                maxTokens: 100
            )
            
            let result = try await openAI.chats(query: query)
            
            if let promptContent = result.choices.first?.message.content {
                let trimmedPrompt = promptContent.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                await MainActor.run { 
                    isLoading = false 
                    errorMessage = nil
                }
                return trimmedPrompt
            }
        } catch {
            print("Error generating baseline prompt: \(error)")
        }
        
        await MainActor.run { isLoading = false }
        return getBaselineFallbackPrompt(for: userInterest)
    }
    
    // Generate contextual daily alignment prompt with progressive learning
    func generateContextualJournalPrompt(
        for userInterest: UserInterest,
        previousSession: JournalSession? = nil,
        allSessions: [JournalSession] = [],
        isEvening: Bool = false
    ) async -> String {
        await MainActor.run { isLoading = true }
        
        guard isNetworkAvailable, let openAI = self.openAI else {
            await MainActor.run { isLoading = false }
            return getContextualFallbackPrompt(for: userInterest, isEvening: isEvening)
        }
        
        let interestDescription = buildInterestDescription(userInterest)
        let contextualInfo = buildContextualInfo(userInterest: userInterest, previousSession: previousSession, allSessions: allSessions)
        let progressionInfo = buildProgressionInfo(userInterest: userInterest)
        let learningInsights = buildLearningInsights(userInterest: userInterest, allSessions: allSessions)
        
        do {
            let query = OpenAI.ChatQuery(
                model: .gpt4o,
                messages: [
                    OpenAI.Chat(role: .system, content: journalingSystemPrompt),
                    OpenAI.Chat(role: .user, content: """
                    User's interest: \(interestDescription)
                    Time of day: \(isEvening ? "evening" : "morning")
                    Context: \(contextualInfo)
                    Progression: \(progressionInfo)
                    Learning insights: \(learningInsights)
                    
                    Create a specific, actionable journal prompt that:
                    1. References their previous responses to show continuity and learning
                    2. \(isEvening ? "Asks how their morning commitment went and what they learned" : "References yesterday's success/failure and builds on it")
                    3. Builds on their current progression level and patterns
                    4. Feels personal and relevant to their specific situation
                    5. Encourages accountability and growth mindset
                    6. Shows the system is learning about them over time
                    
                    \(isEvening ? "Focus on reflection, progress assessment, and tomorrow's improvements." : "Focus on building on yesterday's learnings and setting today's intention.")
                    Keep it under 2 sentences and make it conversational.
                    """)
                ],
                maxTokens: 120
            )
            
            let result = try await openAI.chats(query: query)
            
            if let promptContent = result.choices.first?.message.content {
                let trimmedPrompt = promptContent.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                await MainActor.run { 
                    isLoading = false 
                    errorMessage = nil
                }
                return trimmedPrompt
            }
        } catch {
            print("Error generating contextual prompt: \(error)")
        }
        
        await MainActor.run { isLoading = false }
        return getContextualFallbackPrompt(for: userInterest, isEvening: isEvening)
    }
    
    // Method to advance user to next level based on consistent progress
    func checkAndAdvanceLevel(for userInterest: UserInterest, currentScore: Int) -> Bool {
        // Add current score to weekly tracking
        var scores = userInterest.weeklyProgressScores
        scores.append(currentScore)
        
        // Keep only last 7 scores (one week)
        if scores.count > 7 {
            scores = Array(scores.suffix(7))
        }
        
        // Check if user should advance to next level
        if scores.count >= 5 { // Need at least 5 sessions
            let avgScore = scores.reduce(0, +) / scores.count
            let consistentHighScores = scores.filter { $0 >= 7 }.count >= 4 // 4 out of last 5 sessions scored 7+
            
            if avgScore >= 7 && consistentHighScores && userInterest.currentLevel < 10 {
                return true // User should advance
            }
        }
        
        return false
    }
    
    // MARK: - Helper Methods for Intelligent Journaling
    
    private func buildInterestDescription(_ userInterest: UserInterest) -> String {
        var description = userInterest.interestType?.rawValue ?? "Personal growth"
        
        if let subcategory = userInterest.subcategory {
            description += " (specifically: \(subcategory))"
        }
        
        if let customDescription = userInterest.customDescription {
            description += " - \(customDescription)"
        }
        
        return description
    }
    
    private func buildContextualInfo(userInterest: UserInterest, previousSession: JournalSession?, allSessions: [JournalSession] = []) -> String {
        var context = "This is a new area of focus for the user."
        
        if let baseline = userInterest.baselineResponses.first, !baseline.isEmpty {
            context = "User's baseline: \(String(baseline.prefix(200)))"
        }
        
        // Add recent session history for pattern recognition
        let recentSessions = allSessions
            .filter { $0.userInterest?.id == userInterest.id }
            .sorted { $0.date > $1.date }
            .prefix(3)
        
        if !recentSessions.isEmpty {
            context += " Recent patterns: "
            for (index, session) in recentSessions.enumerated() {
                let timeframe = index == 0 ? "yesterday" : "\(index + 1) days ago"
                context += "\(timeframe): \(String(session.response.prefix(100)))"
                if let score = session.progressScore {
                    context += " (score: \(score)/10)"
                }
                if index < recentSessions.count - 1 { context += "; " }
            }
        }
        
        // Add specific previous session context
        if let previous = previousSession, !previous.response.isEmpty {
            let sessionType = previous.sessionType == .dailyAlignment ? "morning commitment" : "evening reflection"
            context += " Last \(sessionType): \(String(previous.response.prefix(150)))"
            if let score = previous.progressScore {
                context += " (score: \(score)/10)"
            }
        }
        
        return context
    }
    
    private func buildLearningInsights(userInterest: UserInterest, allSessions: [JournalSession]) -> String {
        let userSessions = allSessions.filter { $0.userInterest?.id == userInterest.id }
        guard !userSessions.isEmpty else { return "No learning patterns yet." }
        
        var insights = ""
        
        // Analyze score trends
        let recentScores = userSessions
            .compactMap { $0.progressScore }
            .suffix(7)
        
        if recentScores.count >= 3 {
            let avgScore = recentScores.reduce(0, +) / recentScores.count
            let trend = recentScores.count >= 5 ? 
                Double(recentScores.suffix(3).reduce(0, +)) / 3.0 - Double(Array(recentScores.prefix(3)).reduce(0, +)) / 3.0 : 0.0
            
            insights += "Score trend: avg \(avgScore)/10"
            if trend > 0.5 { insights += " (improving)" }
            else if trend < -0.5 { insights += " (declining)" }
            else { insights += " (stable)" }
        }
        
        // Identify common themes in responses
        let commonWords = extractCommonThemes(from: userSessions)
        if !commonWords.isEmpty {
            insights += "; Common themes: \(commonWords.joined(separator: ", "))"
        }
        
        // Track consistency patterns
        let morningCommitments = userSessions.filter { $0.sessionType == .dailyAlignment }.count
        let eveningReflections = userSessions.filter { $0.sessionType == .dailyReview }.count
        insights += "; Consistency: \(morningCommitments) morning, \(eveningReflections) evening sessions"
        
        return insights
    }
    
    private func extractCommonThemes(from sessions: [JournalSession]) -> [String] {
        let responses = sessions.compactMap { $0.response }.joined(separator: " ").lowercased()
        let words = responses.components(separatedBy: CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters))
            .filter { $0.count > 3 && !["this", "that", "with", "have", "will", "want", "need", "feel", "think"].contains($0) }
        
        let wordCounts = Dictionary(grouping: words, by: { $0 }).mapValues { $0.count }
        return wordCounts.sorted { $0.value > $1.value }.prefix(3).map { $0.key }
    }
    
    private func buildProgressionInfo(userInterest: UserInterest) -> String {
        let level = userInterest.currentLevel
        var progression = "Current level: \(level)/10"
        
        // Add diet-specific progression context
        if userInterest.healthSubcategory == .diet {
            if !userInterest.dietGoals.isEmpty {
                progression += ", Goals: \(userInterest.dietGoals.joined(separator: ", "))"
            }
            if !userInterest.nutritionFocus.isEmpty {
                progression += ", Focus areas: \(userInterest.nutritionFocus.joined(separator: ", "))"
            }
            if !userInterest.weeklyProgressScores.isEmpty {
                let avgScore = userInterest.weeklyProgressScores.reduce(0, +) / userInterest.weeklyProgressScores.count
                progression += ", Recent avg progress: \(avgScore)/10"
            }
        }
        
        return progression
    }
    
    private func getBaselineFallbackPrompt(for userInterest: UserInterest) -> String {
        if let interestType = userInterest.interestType {
            return interestType.baselineQuestions.first ?? "How do you feel about your current progress in this area?"
        }
        return "How do you feel about your current progress in this area?"
    }
    
    private func getContextualFallbackPrompt(for userInterest: UserInterest, isEvening: Bool) -> String {
        guard let interestType = userInterest.interestType else {
            return isEvening ? "How did you do with your goals today?" : "What's one thing you can do today to move forward?"
        }
        
        switch interestType {
        case .health:
            if let subcategory = userInterest.healthSubcategory {
                switch subcategory {
                case .diet:
                    return getDietProgressivePrompt(for: userInterest, isEvening: isEvening)
                case .exercise:
                    return isEvening ? "How did your physical activity go today?" : "How will you move your body today?"
                case .sleep:
                    return isEvening ? "How was your sleep quality last night?" : "What will you do today to set yourself up for good sleep tonight?"
                default:
                    return isEvening ? "How did you take care of your health today?" : "What's one healthy choice you can make today?"
                }
            }
            return isEvening ? "How did you take care of your health today?" : "What's one healthy choice you can make today?"
        case .productivity:
            return isEvening ? "How productive were you today, and what can you improve tomorrow?" : "What's the most important thing you need to accomplish today?"
        case .stress:
            return isEvening ? "How did you manage stress today?" : "What will you do today to stay calm and centered?"
        default:
            return isEvening ? "How did you progress in this area today?" : "What's one action you can take today in this area?"
        }
    }
    
    // MARK: - Diet Progressive Prompts (Pilot Implementation)
    
    private func getDietProgressivePrompt(for userInterest: UserInterest, isEvening: Bool) -> String {
        let level = userInterest.currentLevel
        
        if isEvening {
            return getDietEveningPrompt(level: level)
        } else {
            return getDietMorningPrompt(level: level)
        }
    }
    
    private func getDietMorningPrompt(level: Int) -> String {
        switch level {
        case 1:
            return "What's one healthy food choice you want to make today?"
        case 2:
            return "How will you plan your meals today to support your nutrition goals?"
        case 3:
            return "What specific nutrients or food groups do you want to focus on today?"
        case 4:
            return "How can you prepare your meals today to align with your energy and health goals?"
        case 5:
            return "What eating patterns will you follow today to optimize how you feel?"
        case 6:
            return "How will you balance nutrition, satisfaction, and your lifestyle needs in today's meals?"
        case 7:
            return "What mindful eating practices will you incorporate into your meals today?"
        case 8:
            return "How will you use food as fuel to support your physical and mental performance today?"
        case 9:
            return "What advanced nutrition strategies will you implement today to optimize your wellbeing?"
        case 10:
            return "How will you integrate your nutrition choices today with your broader health and life goals?"
        default:
            return "What do you need to do today to eat the way you want?"
        }
    }
    
    private func getDietEveningPrompt(level: Int) -> String {
        switch level {
        case 1:
            return "How did your food choices today make you feel?"
        case 2:
            return "How well did you stick to your meal planning today, and what can you improve tomorrow?"
        case 3:
            return "Did you get the nutrients you needed today? What would you adjust for tomorrow?"
        case 4:
            return "How did your meal preparation support your energy levels throughout the day?"
        case 5:
            return "How did your eating patterns today affect your mood, energy, and overall wellbeing?"
        case 6:
            return "How well did you balance nutrition goals with life's demands today?"
        case 7:
            return "What did you notice about your hunger cues, satisfaction, and mindful eating today?"
        case 8:
            return "How did your nutrition choices today support your physical and mental performance?"
        case 9:
            return "What insights did you gain about your body's response to today's nutrition choices?"
        case 10:
            return "How did your nutrition align with your broader health vision today, and what will you optimize tomorrow?"
        default:
            return "How well did you stick to your eating goals today?"
        }
    }
}

// Network monitoring class to check internet connectivity
class NetworkMonitor {
    static let shared = NetworkMonitor()
    
    // In a real implementation, this would use NWPathMonitor to check connectivity
    // For simplicity, we'll assume connectivity is available
    var isConnected: Bool = true
}

// MARK: - Diet Progression Levels

/*
Diet Progression System (1-10 levels):

Level 1-2: Basic Awareness
- Simple food choices and awareness
- Basic meal planning

Level 3-4: Structured Approach
- Nutrient focus and meal prep
- Energy optimization

Level 5-6: Lifestyle Integration
- Eating patterns and balance
- Lifestyle alignment

Level 7-8: Mindful Mastery
- Mindful eating and performance
- Advanced strategies

Level 9-10: Holistic Optimization
- Body awareness and life integration
- Complete nutrition mastery
*/
