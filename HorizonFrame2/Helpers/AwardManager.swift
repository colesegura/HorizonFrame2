import Foundation
import SwiftData

class AwardManager {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func checkAllAwards(stats: (currentStreak: Int, longestStreak: Int, total: Int), totalFocuses: Int) {
        checkStreakAwards(currentStreak: stats.currentStreak)
        checkTotalAlignmentAwards(total: stats.total)
        checkFocusAwards(total: totalFocuses)
    }
    
    private func checkStreakAwards(currentStreak: Int) {
        if currentStreak >= 3 { unlockAward(id: "streak_3") }
        if currentStreak >= 7 { unlockAward(id: "streak_7") }
        if currentStreak >= 30 { unlockAward(id: "streak_30") }
        if currentStreak >= 100 { unlockAward(id: "streak_100") }
    }
    
    private func checkTotalAlignmentAwards(total: Int) {
        if total >= 1 { unlockAward(id: "total_1") }
        if total >= 10 { unlockAward(id: "total_10") }
        if total >= 50 { unlockAward(id: "total_50") }
    }
    
    private func checkFocusAwards(total: Int) {
        if total >= 1 { unlockAward(id: "focus_1") }
        if total >= 5 { unlockAward(id: "focus_5") }
    }
    
    private func unlockAward(id: String) {
        // Check if the award is already unlocked to avoid duplicates
        let predicate = #Predicate<UnlockedAward> { $0.id == id }
        let descriptor = FetchDescriptor(predicate: predicate)
        
        do {
            let existing = try modelContext.fetch(descriptor)
            if existing.isEmpty {
                let newAward = UnlockedAward(id: id, unlockedDate: .now)
                modelContext.insert(newAward)
                print("Award unlocked: \(id)")
            }
        } catch {
            print("Failed to fetch existing awards: \(error)")
        }
    }
}
