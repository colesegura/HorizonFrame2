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
    private let fallbackPrompts = [
        "Imagine it's a Saturday morning after you've achieved your goal. Write a journal entry describing what your day looks like.",
        "Picture yourself celebrating the achievement of your goal. What does that moment feel like? Write a journal entry about it.",
        "Visualize a typical day in your life after you've reached your goal. Write about what you see, feel, and experience.",
        "Imagine running into an old friend after achieving your goal. They ask how you're doing. Write a journal entry about this encounter.",
        "Think about the first morning after you've achieved your goal. Write a journal entry describing your thoughts and feelings."
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
    
    func generateJournalPrompt(for goal: Goal) async -> String {
        await MainActor.run { isLoading = true }
        
        // Generate a unique cache key with timestamp to ensure a new prompt each time
        let timestamp = Date().timeIntervalSince1970
        let cacheKey = "goal_\(goal.id)_\(timestamp)"
        
        // Skip cache and generate a new prompt each time
        if !isNetworkAvailable {
            await MainActor.run { isLoading = false }
            return getRandomFallbackPrompt()
        }
        
        // Check if network is available
        guard isNetworkAvailable, let openAI = self.openAI else {
            await MainActor.run { 
                isLoading = false 
                errorMessage = "No internet connection. Using offline prompt."
            }
            let fallbackPrompt = getRandomFallbackPrompt()
            return fallbackPrompt
        }
        
        // Check if we have the required data
        guard let userVision = goal.userVision, !userVision.isEmpty else {
            await MainActor.run { isLoading = false }
            return getRandomFallbackPrompt()
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
                    
                    Create a specific, vivid journal prompt that helps them imagine a moment after achieving this goal.
                    The prompt should be in second person ("Imagine you are...") and should be specific to their goal.
                    Make it feel like a real moment they might experience after achieving their goal.
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
                return getRandomFallbackPrompt()
            }
        } catch {
            print("Error generating journal prompt: \(error)")
            await MainActor.run { 
                isLoading = false 
                errorMessage = "Failed to generate prompt: \(error.localizedDescription)"
            }
            return getRandomFallbackPrompt()
        }
    }
    
    private func getRandomFallbackPrompt() -> String {
        fallbackPrompts.randomElement() ?? fallbackPrompts[0]
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
    func generateOfflinePrompt(for goal: Goal) -> String {
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
            return getRandomFallbackPrompt()
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
