import Foundation
import Combine

class UserManager: ObservableObject {
    // Onboarding Data
    @Published var age: Int = 0
    @Published var occupation: String = ""
    @Published var goalReviewFrequency: String = ""
    @Published var biggestBlocker: String = ""
    @Published var ninetyDayMilestone: String = ""
    @Published var actionableStep: String = ""
    @Published var focusTime: String = ""
    @Published var alignmentDrift: String = ""

    // Other User Properties
    @Published var isExistingUser: Bool = false
    
    init() {}
}
