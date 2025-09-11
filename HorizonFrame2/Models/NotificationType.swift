import Foundation

enum NotificationType: String, Codable, CaseIterable {
    case futureVisualization
    case progressCelebration
    case gentleAccountability
    case contextualMotivation
    case wisdomInsight
    
    var displayName: String {
        switch self {
        case .futureVisualization:
            return "Future Self Visualizations"
        case .progressCelebration:
            return "Progress Celebrations"
        case .gentleAccountability:
            return "Gentle Accountability"
        case .contextualMotivation:
            return "Contextual Motivation"
        case .wisdomInsight:
            return "Wisdom & Insights"
        }
    }
    
    var explanation: String {
        switch self {
        case .futureVisualization:
            return "Help you mentally rehearse your success and maintain emotional connection to goals"
        case .progressCelebration:
            return "Acknowledge effort and maintain momentum through positive reinforcement"
        case .gentleAccountability:
            return "Encourage engagement without guilt or pressure"
        case .contextualMotivation:
            return "Connect daily moments to long-term goals"
        case .wisdomInsight:
            return "Share goal psychology insights and motivation techniques"
        }
    }
}
