import Foundation
import UserNotifications
import SwiftUI
import SwiftData

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    @Published var permissionGranted = false
    @Published var scheduledNotifications: [NotificationContent] = []
    @Published var preferences: NotificationPreferences = UserDefaults.standard.notificationPreferences
    @Published var goalNotificationSettings: [GoalNotificationSettings] = UserDefaults.standard.loadGoalNotificationSettings()
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    init() {
        // Load preferences from UserDefaults
        self.preferences = UserDefaults.standard.notificationPreferences
        checkPermission()
    }
    
    // MARK: - Permission Management
    
    func requestPermission() {
        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                self.permissionGranted = granted
                if granted {
                    print("Notification permission granted")
                } else if let error = error {
                    print("Error requesting notification permission: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func checkPermission() {
        notificationCenter.getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.permissionGranted = (settings.authorizationStatus == .authorized)
                print("NOTIFICATION_TEST: Permission status = \(settings.authorizationStatus.rawValue)")
                print("NOTIFICATION_TEST: Permission granted = \(self.permissionGranted)")
            }
        }
    }
    
    // MARK: - Basic Notifications
    
    func scheduleDailyReminder(time: Date) {
        guard permissionGranted else { return }
        
        // Cancel any existing daily reminders
        notificationCenter.removePendingNotificationRequests(withIdentifiers: ["daily-alignment-reminder"])
        
        let content = UNMutableNotificationContent()
        content.title = "Time for Your Daily Alignment"
        content.body = "Let's get your mind right for the day."
        content.sound = .default
        
        // Set up the trigger based on notification frequency
        let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(identifier: "daily-alignment-reminder", content: content, trigger: trigger)
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling daily reminder: \(error.localizedDescription)")
            } else {
                print("Daily reminder scheduled for \(time)")
            }
        }
        
        // Save the time to preferences
        updatePreferences(with: time)
    }
    
    // MARK: - Goal-Specific Notifications
    
    func scheduleGoalNotification(for goal: Goal, type: NotificationType, time: Date, useGoalSettings: Bool = false) {
        // If using goal settings, check if this notification type is enabled for this goal
        if useGoalSettings {
            let goalIdString = String(describing: goal.id)
            guard let goalSettings = UserDefaults.standard.getGoalNotificationSettings(for: goalIdString) else { return }
            guard goalSettings.isEnabled else { return }
            guard goalSettings.enabledTypes.contains(type) else { return }
        }
        
        guard permissionGranted else { return }
        guard preferences.isEnabled else { return }
        guard preferences.enabledTypes.contains(type) else { return }
        
        let notificationContent = createNotificationContent(for: goal, type: type)
        
        let content = UNMutableNotificationContent()
        content.title = notificationContent.title
        content.body = notificationContent.body
        content.sound = .default
        // Convert PersistentIdentifier to string for storage in userInfo
        let goalIdString = String(describing: goal.id)
        content.userInfo = [
            "goalId": goalIdString,
            "notificationType": type.rawValue
        ]
        
        let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let identifier = "goal-notification-\(String(describing: goal.id))-\(type.rawValue)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling goal notification: \(error.localizedDescription)")
            } else {
                print("Goal notification scheduled for \(goal.text) at \(time)")
                
                // Store the scheduled notification
                // Create a UUID from the string representation of the PersistentIdentifier
                let notification = NotificationContent(
                    title: notificationContent.title,
                    body: notificationContent.body,
                    type: type,
                    goalId: goal.id // Pass the goal.id directly
                )
                
                DispatchQueue.main.async {
                    self.scheduledNotifications.append(notification)
                }
            }
        }
    }
    
    func scheduleAllGoalNotifications(goals: [Goal]) {
        // Cancel existing notifications first
        notificationCenter.removeAllPendingNotificationRequests()
        
        guard preferences.isEnabled else { return }
        
        // Schedule notifications for each goal based on preferences
        for goal in goals {
            let goalIdString = String(describing: goal.id)
            
            // Check if this goal has specific notification settings
            if let goalSettings = UserDefaults.standard.getGoalNotificationSettings(for: goalIdString) {
                // Use goal-specific settings
                if goalSettings.isEnabled {
                    for type in goalSettings.enabledTypes {
                        scheduleGoalNotification(for: goal, type: type, time: goalSettings.preferredTime, useGoalSettings: true)
                    }
                }
            } else {
                // Use global settings
                if preferences.isEnabled {
                    // Schedule for each notification time in preferences
                    for notificationTime in preferences.notificationTimes {
                        for type in preferences.enabledTypes {
                            scheduleGoalNotification(for: goal, type: type, time: notificationTime)
                        }
                    }
                }
            }
        }
    }
    
    func scheduleTestNotification(for goal: Goal) {
        guard permissionGranted else {
            print("Notification permission not granted")
            requestPermission()
            return
        }
        
        let notificationContent = createNotificationContent(for: goal, type: .futureVisualization)
        
        let content = UNMutableNotificationContent()
        content.title = "Test: " + notificationContent.title
        content.body = notificationContent.body
        content.sound = .default
        
        // Schedule for 5 seconds from now
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let request = UNNotificationRequest(identifier: "test-notification-\(UUID().uuidString)", content: content, trigger: trigger)
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling test notification: \(error.localizedDescription)")
            } else {
                print("Test notification scheduled for 5 seconds from now")
            }
        }
    }
    
    func sendGeneralTestNotification() {
        guard permissionGranted else {
            print("Notification permission not granted")
            requestPermission()
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Test Notification"
        content.body = "This is a test notification to verify your settings are working correctly."
        content.sound = .default
        
        // Schedule for 5 seconds from now
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let request = UNNotificationRequest(identifier: "general-test-notification-\(UUID().uuidString)", content: content, trigger: trigger)
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling general test notification: \(error.localizedDescription)")
            } else {
                print("General test notification scheduled for 5 seconds from now")
            }
        }
    }
    
    // MARK: - Notification Management
    
    func cancelNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
        scheduledNotifications.removeAll()
    }
    
    // MARK: - Preference Management
    
    func updatePreferences(with newPreferences: NotificationPreferences, goals: [Goal]? = nil) {
        preferences = newPreferences
        UserDefaults.standard.saveNotificationPreferences(preferences)
        
        // Reschedule notifications with new preferences if goals are provided
        if let goals = goals {
            scheduleAllGoalNotifications(goals: goals)
        }
    }
    
    private func updatePreferences(with reminderTime: Date) {
        var updatedPreferences = preferences
        updatedPreferences.dailyReminderTime = reminderTime
        updatePreferences(with: updatedPreferences)
    }
    
    func toggleNotificationType(_ type: NotificationType, enabled: Bool) {
        var updatedPreferences = preferences
        
        if enabled {
            updatedPreferences.enabledTypes.insert(type)
        } else {
            updatedPreferences.enabledTypes.remove(type)
        }
        
        updatePreferences(with: updatedPreferences)
    }
    
    func setNotificationFrequency(_ frequency: NotificationFrequency) {
        var updatedPreferences = preferences
        updatedPreferences.frequency = frequency
        updatePreferences(with: updatedPreferences)
    }
    
    func updateGoalNotificationSettings(_ settings: GoalNotificationSettings) {
        // Save to UserDefaults
        UserDefaults.standard.saveGoalNotificationSetting(settings)
        
        // Update local cache
        if let index = goalNotificationSettings.firstIndex(where: { $0.goalIdString == settings.goalIdString }) {
            goalNotificationSettings[index] = settings
        } else {
            goalNotificationSettings.append(settings)
        }
    }
    
    func cancelGoalNotifications(for goalId: UUID) {
        notificationCenter.getPendingNotificationRequests { requests in
            let identifiersToRemove = requests
                .filter { $0.content.userInfo["goalId"] as? String == String(describing: goalId) }
                .map { $0.identifier }
            
            self.notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
            
            DispatchQueue.main.async {
                self.scheduledNotifications.removeAll { $0.goalIdString == String(describing: goalId) }
            }
        }
    }
    
    // MARK: - Content Generation
    
    private func createNotificationContent(for goal: Goal, type: NotificationType) -> SimpleNotificationContent {
        // This is a simple implementation that will be enhanced with AI-generated content later
        switch type {
        case .futureVisualization:
            return SimpleNotificationContent(
                title: "Visualize Your Future",
                body: "Imagine achieving your goal: \(goal.text). How does it feel?"
            )
            
        case .progressCelebration:
            return SimpleNotificationContent(
                title: "Celebrate Your Progress",
                body: "You're making great progress toward \(goal.text). Keep going!"
            )
            
        case .gentleAccountability:
            return SimpleNotificationContent(
                title: "A Gentle Reminder",
                body: "Your goal '\(goal.text)' is waiting for your attention today."
            )
            
        case .contextualMotivation:
            return SimpleNotificationContent(
                title: "Stay Motivated",
                body: "Remember why you started working toward \(goal.text)."
            )
            
        case .wisdomInsight:
            return SimpleNotificationContent(
                title: "Goal Achievement Insight",
                body: "Small daily actions lead to big results for your goal: \(goal.text)."
            )
        }
    }
}
