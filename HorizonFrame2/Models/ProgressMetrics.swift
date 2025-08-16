import Foundation

struct ProgressMetrics {
    let timeProgress: Double        // 0.0 to 1.0
    let entryConsistency: Double    // entries/expected entries
    let currentStreak: Int
    let longestStreak: Int
    let totalEntries: Int
    let averageEntryLength: TimeInterval
    let milestones: [Milestone]
}

// Extension to clamp values within a range
extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        return min(max(self, range.lowerBound), range.upperBound)
    }
}
