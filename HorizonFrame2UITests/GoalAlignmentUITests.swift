import XCTest

final class GoalAlignmentUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UITesting"]
        app.launch()
    }
    
    func testGoalAlignmentViewNavigation() throws {
        // Navigate to Today tab
        app.tabBars.buttons["Today"].tap()
        
        // Find and tap the "Begin Alignment" button
        let beginAlignmentButton = app.buttons["Begin Alignment"]
        XCTAssertTrue(beginAlignmentButton.exists, "Begin Alignment button should exist")
        beginAlignmentButton.tap()
        
        // Verify we're on the GoalAlignmentView
        let alignmentTitle = app.staticTexts["Goal Alignment"]
        XCTAssertTrue(alignmentTitle.waitForExistence(timeout: 2), "Goal Alignment title should exist")
        
        // Verify the prompt is displayed
        let promptText = app.staticTexts.element(matching: .any, identifier: "promptText")
        XCTAssertTrue(promptText.waitForExistence(timeout: 5), "Prompt text should be visible")
        XCTAssertFalse(promptText.label.isEmpty, "Prompt should not be empty")
        
        // Test journal entry input
        let journalTextEditor = app.textViews["journalTextEditor"]
        XCTAssertTrue(journalTextEditor.exists, "Journal text editor should exist")
        
        journalTextEditor.tap()
        journalTextEditor.typeText("This is my test journal entry for goal alignment testing.")
        
        // Submit the journal entry
        let submitButton = app.buttons["Submit"]
        XCTAssertTrue(submitButton.exists, "Submit button should exist")
        submitButton.tap()
        
        // Verify we return to the Today view
        let todayTitle = app.navigationBars["Today"]
        XCTAssertTrue(todayTitle.waitForExistence(timeout: 2), "Should return to Today view")
    }
    
    func testGoalAlignmentViewErrorHandling() throws {
        // Set up the app to simulate network error (using launch argument)
        let offlineApp = XCUIApplication()
        offlineApp.launchArguments = ["UITesting", "SimulateOffline"]
        offlineApp.launch()
        
        // Navigate to Today tab
        offlineApp.tabBars.buttons["Today"].tap()
        
        // Find and tap the "Begin Alignment" button
        let beginAlignmentButton = offlineApp.buttons["Begin Alignment"]
        XCTAssertTrue(beginAlignmentButton.exists, "Begin Alignment button should exist")
        beginAlignmentButton.tap()
        
        // Verify we're on the GoalAlignmentView
        let alignmentTitle = offlineApp.staticTexts["Goal Alignment"]
        XCTAssertTrue(alignmentTitle.waitForExistence(timeout: 2), "Goal Alignment title should exist")
        
        // Verify error message is displayed
        let errorMessage = offlineApp.staticTexts.element(matching: .any, identifier: "errorMessage")
        XCTAssertTrue(errorMessage.waitForExistence(timeout: 5), "Error message should be visible")
        XCTAssertTrue(errorMessage.label.contains("internet"), "Error should mention internet connection")
        
        // Verify the retry button is displayed
        let retryButton = offlineApp.buttons["Retry"]
        XCTAssertTrue(retryButton.exists, "Retry button should exist")
        
        // Verify the fallback prompt is still displayed
        let promptText = offlineApp.staticTexts.element(matching: .any, identifier: "promptText")
        XCTAssertTrue(promptText.waitForExistence(timeout: 2), "Fallback prompt should be visible")
        XCTAssertFalse(promptText.label.isEmpty, "Prompt should not be empty")
    }
    
    func testAddGoalView() throws {
        // Navigate to Goals tab
        app.tabBars.buttons["Goals"].tap()
        
        // Find and tap the "Add Goal" button
        let addGoalButton = app.buttons["Add Goal"]
        XCTAssertTrue(addGoalButton.exists, "Add Goal button should exist")
        addGoalButton.tap()
        
        // Verify we're on the AddGoalView
        let addGoalTitle = app.staticTexts["Add New Goal"]
        XCTAssertTrue(addGoalTitle.waitForExistence(timeout: 2), "Add New Goal title should exist")
        
        // Enter goal text
        let goalTextField = app.textFields["goalTextField"]
        XCTAssertTrue(goalTextField.exists, "Goal text field should exist")
        goalTextField.tap()
        goalTextField.typeText("Run a marathon")
        
        // Enter vision text
        let visionTextEditor = app.textViews["visionTextEditor"]
        XCTAssertTrue(visionTextEditor.exists, "Vision text editor should exist")
        visionTextEditor.tap()
        visionTextEditor.typeText("I see myself crossing the finish line, feeling accomplished and strong.")
        
        // Set target date (tap to open date picker)
        let dateField = app.buttons["targetDateField"]
        XCTAssertTrue(dateField.exists, "Target date field should exist")
        dateField.tap()
        
        // Select a date 3 months from now (simplified - just confirming the picker)
        let datePicker = app.datePickers.firstMatch
        XCTAssertTrue(datePicker.exists, "Date picker should exist")
        
        // Tap "Done" to confirm date selection
        app.buttons["Done"].tap()
        
        // Save the goal
        let saveButton = app.buttons["Save"]
        XCTAssertTrue(saveButton.exists, "Save button should exist")
        saveButton.tap()
        
        // Verify we return to the Goals view
        let goalsTitle = app.navigationBars["Goals"]
        XCTAssertTrue(goalsTitle.waitForExistence(timeout: 2), "Should return to Goals view")
        
        // Verify the new goal appears in the list
        let newGoalText = app.staticTexts["Run a marathon"]
        XCTAssertTrue(newGoalText.exists, "New goal should appear in the list")
    }
}
