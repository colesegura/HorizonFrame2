import Foundation

struct ActivityNotificationPreferences: Codable, Equatable {
    var dailyAlignmentTime: Date
    var dailyReviewTime: Date
    var weeklyReviewDay: Int // 1 = Sunday, 2 = Monday, etc.
    var weeklyReviewTime: Date
    
    init(
        dailyAlignmentTime: Date = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date(),
        dailyReviewTime: Date = Calendar.current.date(bySettingHour: 17, minute: 0, second: 0, of: Date()) ?? Date(),
        weeklyReviewDay: Int = 1, // Sunday
        weeklyReviewTime: Date = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date()
    ) {
        self.dailyAlignmentTime = dailyAlignmentTime
        self.dailyReviewTime = dailyReviewTime
        self.weeklyReviewDay = weeklyReviewDay
        self.weeklyReviewTime = weeklyReviewTime
    }
    
    static func == (lhs: ActivityNotificationPreferences, rhs: ActivityNotificationPreferences) -> Bool {
        let calendar = Calendar.current
        
        // Check if times match to the minute
        let alignmentTimesMatch = calendar.isDate(lhs.dailyAlignmentTime, equalTo: rhs.dailyAlignmentTime, toGranularity: .minute)
        let reviewTimesMatch = calendar.isDate(lhs.dailyReviewTime, equalTo: rhs.dailyReviewTime, toGranularity: .minute)
        let weeklyTimesMatch = calendar.isDate(lhs.weeklyReviewTime, equalTo: rhs.weeklyReviewTime, toGranularity: .minute)
        
        return alignmentTimesMatch &&
               reviewTimesMatch &&
               weeklyTimesMatch &&
               lhs.weeklyReviewDay == rhs.weeklyReviewDay
    }
}

// Extension to store and retrieve activity notification preferences using UserDefaults
extension UserDefaults {
    private enum ActivityKeys {
        static let activityNotificationPreferences = "activityNotificationPreferences"
    }
    
    var activityNotificationPreferences: ActivityNotificationPreferences {
        get {
            guard let data = data(forKey: ActivityKeys.activityNotificationPreferences),
                  let preferences = try? JSONDecoder().decode(ActivityNotificationPreferences.self, from: data) else {
                return ActivityNotificationPreferences()
            }
            return preferences
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                set(data, forKey: ActivityKeys.activityNotificationPreferences)
            }
        }
    }
}
