import XCTest
import SwiftUI
import SwiftData
@testable import HorizonFrame2

final class GoalAlignmentIntegrationTests: XCTestCase {
    var apiConfig: APIConfig!
    var promptService: AIPromptService!
    
    override func setUp() {
        super.setUp()
        apiConfig = APIConfig()
        promptService = AIPromptService(apiConfig: apiConfig)
    }
    
    override func tearDown() {
        promptService = nil
        apiConfig = nil
        super.tearDown()
    }
    
    func testGoalAlignmentViewModelIntegration() async {
        // Create a test goal with vision
        let goal = Goal(text: "Run a marathon", order: 1)
        goal.userVision = "I see myself crossing the finish line, feeling accomplished and strong."
        goal.targetDate = Calendar.current.date(byAdding: .month, value: 3, to: Date())
        
        // Generate a prompt using the service
        let prompt = await promptService.generateJournalPrompt(for: goal)
        XCTAssertFalse(prompt.isEmpty)
        
        // Verify the prompt is cached
        let cachedPrompt = await promptService.generateJournalPrompt(for: goal)
        XCTAssertEqual(prompt, cachedPrompt)
        
        // Set the prompt on the goal
        goal.currentPrompt = prompt
        
        // Create a journal entry
        let journalEntry = JournalEntry(prompt: prompt, response: "This is my journal response.")
        goal.journalEntries.append(journalEntry)
        
        // Verify the journal entry is associated with the goal
        XCTAssertEqual(goal.journalEntries.count, 1)
        XCTAssertEqual(goal.journalEntries[0].prompt, prompt)
    }
    
    func testAPIConfigIntegration() {
        // Test saving and retrieving API key
        let testKey = "test-api-key-12345"
        apiConfig.saveAPIKey(testKey)
        
        // Verify the key was saved
        let retrievedKey = apiConfig.getAPIKey()
        XCTAssertEqual(retrievedKey, testKey)
        
        // Create a new AIPromptService with the updated config
        let newService = AIPromptService(apiConfig: apiConfig)
        XCTAssertNotNil(newService.openAI)
    }
    
    func testOfflinePromptGeneration() async {
        // Create a test goal
        let goal = Goal(text: "Run a marathon", order: 1)
        goal.userVision = "I see myself crossing the finish line, feeling accomplished and strong."
        
        // Force offline mode
        promptService.isNetworkAvailable = false
        
        // Generate a prompt
        let prompt = await promptService.generateJournalPrompt(for: goal)
        
        // Verify we got a fallback prompt
        XCTAssertFalse(prompt.isEmpty)
        XCTAssertNotNil(promptService.errorMessage)
        XCTAssertTrue(promptService.errorMessage?.contains("No internet") ?? false)
    }
    
    func testErrorHandling() async {
        // Create a test goal with no vision (will cause error path)
        let goal = Goal(text: "Run a marathon", order: 1)
        goal.userVision = nil
        
        // Generate a prompt (should use fallback)
        let prompt = await promptService.generateJournalPrompt(for: goal)
        
        // Verify we still got a valid prompt
        XCTAssertFalse(prompt.isEmpty)
    }
}
