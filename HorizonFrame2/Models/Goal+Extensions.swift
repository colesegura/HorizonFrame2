import Foundation
import SwiftData

extension Goal {
    // Computed properties for goal tracking
    var daysTracking: Int {
        Calendar.current.dateComponents([.day], from: createdAt, to: Date()).day ?? 0
    }
    
    var daysRemaining: Int {
        guard let targetDate = targetDate else { return 0 }
        return Calendar.current.dateComponents([.day], from: Date(), to: targetDate).day ?? 0
    }
    
    var progressPercentage: Double {
        guard let targetDate = targetDate else { return 0 }
        let total = Calendar.current.dateComponents([.day], from: createdAt, to: targetDate).day ?? 1
        return min(1.0, Double(daysTracking) / Double(total))
    }
}
