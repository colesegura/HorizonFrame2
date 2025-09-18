import Foundation
import SwiftData

class OnboardingDataManager: ObservableObject {
    static let shared = OnboardingDataManager()
    
    // Temporary storage for onboarding data
    @Published var onboardingGoal: String = ""
    @Published var onboardingVisualization: String = ""
    @Published var onboardingActionItem: String = ""
    
    // New properties for interest-based journaling
    @Published var selectedInterests: [InterestType] = []
    @Published var customInterestText: String = ""
    @Published var interestSubcategories: [InterestType: String] = [:]
    @Published var interestCustomTexts: [InterestType: String] = [:]
    
    private init() {}
    
    // Store onboarding data
    func storeOnboardingData(goal: String, visualization: String, actionItem: String) {
        self.onboardingGoal = goal
        self.onboardingVisualization = visualization
        self.onboardingActionItem = actionItem
    }
    
    // Save onboarding data to SwiftData
    func saveToGoals(modelContext: ModelContext) {
        // Save user interests first
        saveUserInterests(modelContext: modelContext)
        
        guard !onboardingGoal.isEmpty else { return }
        
        // Create the goal with visualization
        let newGoal = Goal(
            text: onboardingGoal,
            order: 0, // Place at top
            targetDate: nil, // No target date from onboarding
            isArchived: false,
            visualization: onboardingVisualization,
            isFromOnboarding: true,
            userVision: nil, // User vision can be added later
            isPrimary: false, // Not primary by default
            category: .active
        )
        
        modelContext.insert(newGoal)
        
        // Add the action item if provided
        if !onboardingActionItem.isEmpty {
            let actionItem = ActionItem(
                text: onboardingActionItem,
                order: 0,
                goal: newGoal
            )
            modelContext.insert(actionItem)
        }
        
        // Update order of existing goals
        do {
            let descriptor = FetchDescriptor<Goal>(
                predicate: #Predicate<Goal> { !$0.isFromOnboarding },
                sortBy: [SortDescriptor(\.order)]
            )
            let existingGoals = try modelContext.fetch(descriptor)
            
            for (index, goal) in existingGoals.enumerated() {
                goal.order = index + 1
            }
            
            try modelContext.save()
        } catch {
            print("Error saving onboarding data: \(error)")
        }
        
        // Clear temporary data
        clearOnboardingData()
    }
    
    // Save user interests to SwiftData
    func saveUserInterests(modelContext: ModelContext) {
        for (index, interest) in selectedInterests.enumerated() {
            let subcategory = interestSubcategories[interest]
            let customText = interestCustomTexts[interest]
            
            let userInterest = UserInterest(
                type: interest,
                subcategory: subcategory,
                customDescription: customText,
                priority: index + 1
            )
            
            modelContext.insert(userInterest)
        }
        
        // Handle custom "Other" interest
        if selectedInterests.contains(.other) && !customInterestText.isEmpty {
            let customInterest = UserInterest(
                type: .other,
                customDescription: customInterestText,
                priority: selectedInterests.count
            )
            modelContext.insert(customInterest)
        }
        
        do {
            try modelContext.save()
        } catch {
            print("Error saving user interests: \(error)")
        }
    }
    
    // Clear temporary onboarding data
    func clearOnboardingData() {
        onboardingGoal = ""
        onboardingVisualization = ""
        onboardingActionItem = ""
        selectedInterests = []
        customInterestText = ""
        interestSubcategories = [:]
        interestCustomTexts = [:]
    }
    
    // Check if onboarding data exists
    var hasOnboardingData: Bool {
        !onboardingGoal.isEmpty
    }
}
