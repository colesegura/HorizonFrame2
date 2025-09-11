import Foundation
import SwiftData

struct GoalNotificationSettings: Codable, Identifiable, Equatable {
    var id: UUID
    var goalIdString: String
    var isEnabled: Bool
    var enabledTypes: [NotificationType]
    var frequency: NotificationFrequency
    var preferredTime: Date
    
    init(
        id: UUID = UUID(),
        goalIdString: String,
        isEnabled: Bool = true,
        enabledTypes: [NotificationType] = NotificationType.allCases,
        frequency: NotificationFrequency = .daily,
        preferredTime: Date = Calendar.current.date(bySettingHour: 10, minute: 0, second: 0, of: Date()) ?? Date()
    ) {
        self.id = id
        self.goalIdString = goalIdString
        self.isEnabled = isEnabled
        self.enabledTypes = enabledTypes
        self.frequency = frequency
        self.preferredTime = preferredTime
    }
    
    static func == (lhs: GoalNotificationSettings, rhs: GoalNotificationSettings) -> Bool {
        return lhs.id == rhs.id
    }
}

// Extension to handle UserDefaults storage
extension UserDefaults {
    private static let goalNotificationSettingsKey = "goalNotificationSettings"
    
    func saveGoalNotificationSettings(_ settings: [GoalNotificationSettings]) {
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: UserDefaults.goalNotificationSettingsKey)
        }
    }
    
    func loadGoalNotificationSettings() -> [GoalNotificationSettings] {
        if let data = UserDefaults.standard.data(forKey: UserDefaults.goalNotificationSettingsKey),
           let settings = try? JSONDecoder().decode([GoalNotificationSettings].self, from: data) {
            return settings
        }
        return []
    }
    
    func getGoalNotificationSettings(for goalIdString: String) -> GoalNotificationSettings? {
        let allSettings = loadGoalNotificationSettings()
        return allSettings.first(where: { $0.goalIdString == goalIdString })
    }
    
    func saveGoalNotificationSetting(_ setting: GoalNotificationSettings) {
        var allSettings = loadGoalNotificationSettings()
        
        if let index = allSettings.firstIndex(where: { $0.goalIdString == setting.goalIdString }) {
            allSettings[index] = setting
        } else {
            allSettings.append(setting)
        }
        
        saveGoalNotificationSettings(allSettings)
    }
    
    func removeGoalNotificationSettings(for goalIdString: String) {
        var allSettings = loadGoalNotificationSettings()
        allSettings.removeAll(where: { $0.goalIdString == goalIdString })
        saveGoalNotificationSettings(allSettings)
    }
}
