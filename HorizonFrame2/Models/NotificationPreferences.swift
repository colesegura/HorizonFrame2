import Foundation
import SwiftUI

struct NotificationPreferences: Codable, Equatable {
    var isEnabled: Bool
    var notificationTimes: [Date]
    var enabledTypes: Set<NotificationType>
    var frequency: NotificationFrequency
    
    // For backward compatibility
    var dailyReminderTime: Date {
        get {
            return notificationTimes.first ?? Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date()
        }
        set {
            if notificationTimes.isEmpty {
                notificationTimes = [newValue]
            } else {
                notificationTimes[0] = newValue
            }
        }
    }
    
    init(
        isEnabled: Bool = true,
        notificationTimes: [Date] = [
            Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date(),
            Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date()) ?? Date()
        ],
        enabledTypes: Set<NotificationType> = Set(NotificationType.allCases),
        frequency: NotificationFrequency = .daily
    ) {
        self.isEnabled = isEnabled
        self.notificationTimes = notificationTimes
        self.enabledTypes = enabledTypes
        self.frequency = frequency
    }
    
    static func == (lhs: NotificationPreferences, rhs: NotificationPreferences) -> Bool {
        // Check if notification times arrays have the same count
        guard lhs.notificationTimes.count == rhs.notificationTimes.count else {
            return false
        }
        
        // Check if all notification times match to the minute
        let timesMatch = zip(lhs.notificationTimes, rhs.notificationTimes).allSatisfy { lhsTime, rhsTime in
            Calendar.current.isDate(lhsTime, equalTo: rhsTime, toGranularity: .minute)
        }
        
        return lhs.isEnabled == rhs.isEnabled &&
               timesMatch &&
               lhs.enabledTypes == rhs.enabledTypes &&
               lhs.frequency == rhs.frequency
    }
}

enum NotificationFrequency: String, Codable, CaseIterable, Identifiable {
    case daily = "Daily"
    case weekdays = "Weekdays Only"
    case weekends = "Weekends Only"
    case custom = "Custom Days"
    
    var id: String { self.rawValue }
    
    var description: String {
        switch self {
        case .daily:
            return "Receive notifications every day"
        case .weekdays:
            return "Receive notifications Monday through Friday"
        case .weekends:
            return "Receive notifications on Saturday and Sunday"
        case .custom:
            return "Select specific days to receive notifications"
        }
    }
    
    func shouldSendNotification(on date: Date) -> Bool {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        
        switch self {
        case .daily:
            return true
        case .weekdays:
            // 1 = Sunday, 2 = Monday, ..., 6 = Friday, 7 = Saturday
            return weekday >= 2 && weekday <= 6
        case .weekends:
            return weekday == 1 || weekday == 7
        case .custom:
            // This would require additional user configuration
            return true
        }
    }
}

// Extension to store and retrieve notification preferences using UserDefaults
extension UserDefaults {
    private enum Keys {
        static let notificationPreferences = "notificationPreferences"
    }
    
    var notificationPreferences: NotificationPreferences {
        get {
            guard let data = data(forKey: Keys.notificationPreferences),
                  let preferences = try? JSONDecoder().decode(NotificationPreferences.self, from: data) else {
                return NotificationPreferences()
            }
            return preferences
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                set(data, forKey: Keys.notificationPreferences)
            }
        }
    }
    
    func loadNotificationPreferences() -> NotificationPreferences {
        return notificationPreferences
    }
    
    func saveNotificationPreferences(_ preferences: NotificationPreferences) {
        notificationPreferences = preferences
    }
}
