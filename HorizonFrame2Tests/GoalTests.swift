import XCTest
import SwiftData
@testable import HorizonFrame2

final class GoalTests: XCTestCase {
    
    func testGoalInitialization() {
        let text = "Complete a marathon"
        let order = 1
        let goal = Goal(text: text, order: order)
        
        XCTAssertEqual(goal.text, text)
        XCTAssertEqual(goal.order, order)
        XCTAssertFalse(goal.isArchived)
        XCTAssertNil(goal.targetDate)
        XCTAssertNil(goal.userVision)
        XCTAssertNil(goal.currentPrompt)
        XCTAssertTrue(goal.journalEntries.isEmpty)
    }
    
    func testGoalWithTargetDate() {
        let text = "Complete a marathon"
        let order = 1
        let targetDate = Calendar.current.date(byAdding: .month, value: 3, to: Date())!
        
        let goal = Goal(text: text, order: order)
        goal.targetDate = targetDate
        
        XCTAssertEqual(goal.targetDate, targetDate)
    }
    
    func testGoalWithUserVision() {
        let text = "Complete a marathon"
        let order = 1
        let vision = "I see myself crossing the finish line, feeling strong and accomplished."
        
        let goal = Goal(text: text, order: order)
        goal.userVision = vision
        
        XCTAssertEqual(goal.userVision, vision)
    }
    
    func testGoalWithCurrentPrompt() {
        let text = "Complete a marathon"
        let order = 1
        let prompt = "Imagine you've just crossed the finish line of your first marathon."
        
        let goal = Goal(text: text, order: order)
        goal.currentPrompt = prompt
        
        XCTAssertEqual(goal.currentPrompt, prompt)
    }
    
    func testDaysTracking() {
        let goal = Goal(text: "Test goal", order: 1)
        
        // Set the creation date to 5 days ago
        let fiveDaysAgo = Calendar.current.date(byAdding: .day, value: -5, to: Date())!
        goal.createdAt = fiveDaysAgo
        
        XCTAssertEqual(goal.daysTracking, 5)
    }
    
    func testDaysRemaining() {
        let goal = Goal(text: "Test goal", order: 1)
        
        // Set the target date to 10 days from now
        let tenDaysFromNow = Calendar.current.date(byAdding: .day, value: 10, to: Date())!
        goal.targetDate = tenDaysFromNow
        
        XCTAssertEqual(goal.daysRemaining, 10)
    }
    
    func testProgressPercentage() {
        let goal = Goal(text: "Test goal", order: 1)
        
        // Set the creation date to 5 days ago
        let fiveDaysAgo = Calendar.current.date(byAdding: .day, value: -5, to: Date())!
        goal.createdAt = fiveDaysAgo
        
        // Set the target date to 15 days from the creation date (10 days from now)
        let tenDaysFromNow = Calendar.current.date(byAdding: .day, value: 10, to: Date())!
        goal.targetDate = tenDaysFromNow
        
        // Progress should be 5/15 = 33.3%
        XCTAssertEqual(goal.progressPercentage, 5.0/15.0, accuracy: 0.01)
    }
    
    func testJournalEntries() {
        let goal = Goal(text: "Test goal", order: 1)
        
        // Create and add journal entries
        let entry1 = JournalEntry(prompt: "Test prompt 1", response: "Test response 1")
        let entry2 = JournalEntry(prompt: "Test prompt 2", response: "Test response 2")
        
        goal.journalEntries.append(entry1)
        goal.journalEntries.append(entry2)
        
        XCTAssertEqual(goal.journalEntries.count, 2)
        XCTAssertEqual(goal.journalEntries[0].prompt, "Test prompt 1")
        XCTAssertEqual(goal.journalEntries[1].response, "Test response 2")
    }
}
