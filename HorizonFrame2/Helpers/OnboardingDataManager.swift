import Foundation
import SwiftData

class OnboardingDataManager: ObservableObject {
    static let shared = OnboardingDataManager()
    
    // Temporary storage for onboarding data
    @Published var onboardingGoal: String = ""
    @Published var onboardingVisualization: String = ""
    @Published var onboardingActionItem: String = ""
    
    private init() {}
    
    // Store onboarding data
    func storeOnboardingData(goal: String, visualization: String, actionItem: String) {
        self.onboardingGoal = goal
        self.onboardingVisualization = visualization
        self.onboardingActionItem = actionItem
    }
    
    // Save onboarding data to SwiftData
    func saveToGoals(modelContext: ModelContext) {
        guard !onboardingGoal.isEmpty else { return }
        
        // Create the goal with visualization
        let newGoal = Goal(
            text: onboardingGoal,
            order: 0, // Place at top
            visualization: onboardingVisualization,
            isFromOnboarding: true
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
    
    // Clear temporary onboarding data
    func clearOnboardingData() {
        onboardingGoal = ""
        onboardingVisualization = ""
        onboardingActionItem = ""
    }
    
    // Check if onboarding data exists
    var hasOnboardingData: Bool {
        !onboardingGoal.isEmpty
    }
}
