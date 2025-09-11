import Foundation
import SwiftData

struct NotificationContent: Codable, Identifiable, Equatable {
    var id: UUID
    var title: String
    var body: String
    var type: NotificationType
    var goalIdString: String? // Store goal ID as string
    var createdAt: Date
    
    init(
        id: UUID = UUID(),
        title: String,
        body: String,
        type: NotificationType,
        goalId: Any? = nil, // Accept any type for goalId
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.body = body
        self.type = type
        
        // Handle different types of goal IDs
        if let goalId = goalId {
            self.goalIdString = String(describing: goalId)
        } else {
            self.goalIdString = nil
        }
        
        self.createdAt = createdAt
    }
    
    static func == (lhs: NotificationContent, rhs: NotificationContent) -> Bool {
        return lhs.id == rhs.id
    }
}

// Simple version for basic notifications
struct SimpleNotificationContent: Codable, Equatable {
    var title: String
    var body: String
    
    init(title: String, body: String) {
        self.title = title
        self.body = body
    }
}
