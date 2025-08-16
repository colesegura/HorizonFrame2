import XCTest
import SwiftData
@testable import HorizonFrame2

final class AIPromptServiceTests: XCTestCase {
    var apiConfig: APIConfig!
    var service: AIPromptService!
    
    override func setUp() {
        super.setUp()
        apiConfig = APIConfig()
        service = AIPromptService(apiConfig: apiConfig)
    }
    
    override func tearDown() {
        service = nil
        apiConfig = nil
        super.tearDown()
    }
    
    func testInitialization() {
        XCTAssertNotNil(service)
        XCTAssertNotNil(service.openAI)
        XCTAssertFalse(service.isLoading)
        XCTAssertNil(service.errorMessage)
    }
    
    func testGetRandomFallbackPrompt() {
        let prompt = service.getRandomFallbackPrompt()
        XCTAssertFalse(prompt.isEmpty)
        
        // Test that multiple calls return different prompts (not guaranteed but likely)
        var uniquePrompts = Set<String>()
        for _ in 0..<10 {
            uniquePrompts.insert(service.getRandomFallbackPrompt())
        }
        
        // We should have at least 2 unique prompts from 10 calls
        XCTAssertGreaterThan(uniquePrompts.count, 1)
    }
    
    func testGenerateOfflinePrompt() {
        // Test different goal categories
        let homeGoal = Goal(text: "Move to a new home", order: 1)
        let careerGoal = Goal(text: "Get a new job in tech", order: 2)
        let relationshipGoal = Goal(text: "Improve my relationship with my partner", order: 3)
        let healthGoal = Goal(text: "Lose 20 pounds and get fit", order: 4)
        let financialGoal = Goal(text: "Save $10,000 for a down payment", order: 5)
        let otherGoal = Goal(text: "Learn to play the guitar", order: 6)
        
        // Test that each goal type gets an appropriate prompt
        let homePrompt = service.generateOfflinePrompt(for: homeGoal)
        XCTAssertTrue(homePrompt.contains("home"))
        
        let careerPrompt = service.generateOfflinePrompt(for: careerGoal)
        XCTAssertTrue(careerPrompt.contains("job") || careerPrompt.contains("work"))
        
        let relationshipPrompt = service.generateOfflinePrompt(for: relationshipGoal)
        XCTAssertTrue(relationshipPrompt.contains("partner") || relationshipPrompt.contains("relationship"))
        
        let healthPrompt = service.generateOfflinePrompt(for: healthGoal)
        XCTAssertTrue(healthPrompt.contains("health") || healthPrompt.contains("fitness"))
        
        let financialPrompt = service.generateOfflinePrompt(for: financialGoal)
        XCTAssertTrue(financialPrompt.contains("financial") || financialPrompt.contains("money"))
        
        // Other goals should get a random fallback prompt
        let otherPrompt = service.generateOfflinePrompt(for: otherGoal)
        XCTAssertFalse(otherPrompt.isEmpty)
    }
    
    func testPromptCaching() async {
        // Create a test goal
        let goal = Goal(text: "Test goal", order: 1)
        goal.userVision = "My vision for this goal"
        
        // Generate a prompt and ensure it's cached
        let prompt1 = await service.generateJournalPrompt(for: goal)
        XCTAssertFalse(prompt1.isEmpty)
        
        // Generate another prompt for the same goal and verify it's the same (cached)
        let prompt2 = await service.generateJournalPrompt(for: goal)
        XCTAssertEqual(prompt1, prompt2)
    }
    
    func testNetworkUnavailable() async {
        // Create a test goal
        let goal = Goal(text: "Test goal", order: 1)
        goal.userVision = "My vision for this goal"
        
        // Force network to be unavailable
        service.isNetworkAvailable = false
        
        // Generate a prompt and ensure we get a fallback
        let prompt = await service.generateJournalPrompt(for: goal)
        XCTAssertFalse(prompt.isEmpty)
        XCTAssertNotNil(service.errorMessage)
        XCTAssertTrue(service.errorMessage?.contains("No internet") ?? false)
    }
    
    func testMissingUserVision() async {
        // Create a test goal with no vision
        let goal = Goal(text: "Test goal", order: 1)
        goal.userVision = nil
        
        // Generate a prompt and ensure we get a fallback
        let prompt = await service.generateJournalPrompt(for: goal)
        XCTAssertFalse(prompt.isEmpty)
    }
}
