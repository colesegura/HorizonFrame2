import SwiftUI
import SwiftData
import UIKit

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var goals: [Goal]
    
    @StateObject private var notificationManager = NotificationManager.shared
    @AppStorage("isReminderEnabled") private var isReminderEnabled = false
    @AppStorage("reminderTime") private var reminderTimeInterval: Double = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: .now)?.timeIntervalSinceReferenceDate ?? Date().timeIntervalSinceReferenceDate
    @AppStorage("showOnboarding") private var showOnboarding = false
    @AppStorage("preferredMeditationDuration") private var preferredMeditationDuration: TimeInterval = 300
    
    @State private var showingNotificationTestView = false
    @State private var showingNotificationPreferencesView = false
    @State private var showingActivityScheduleView = false


    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                Form {
                    Section(header: Text("Meditation Duration").foregroundColor(.gray)) {
                        Picker("Duration", selection: $preferredMeditationDuration) {
                            Text("1 min").tag(60.0)
                            Text("3 min").tag(180.0)
                            Text("5 min").tag(300.0)
                            Text("10 min").tag(600.0)
                            Text("15 min").tag(900.0)
                            Text("20 min").tag(1200.0)
                        }
                        .pickerStyle(.segmented)
                        .foregroundColor(.white)
                    }
                    Section(header: Text("Notifications").foregroundColor(.gray)) {
                        Toggle("Daily Reminder", isOn: $isReminderEnabled)
                            .tint(.green)
                        
                        // Activity Schedule button - always visible
                        Button(action: {
                            showingActivityScheduleView = true
                        }) {
                            HStack {
                                Image(systemName: "calendar.badge.clock")
                                Text("Activity Schedule")
                            }
                        }
                        .foregroundColor(.blue)
                        
                        // Test notification button - always visible
                        Button(action: {
                            notificationManager.sendGeneralTestNotification()
                        }) {
                            HStack {
                                Image(systemName: "bell.badge")
                                Text("Send Test Notification")
                            }
                        }
                        .foregroundColor(.blue)
                        
                        if isReminderEnabled {
                            DatePicker("Reminder Time", selection: .init(
                                get: { Date(timeIntervalSinceReferenceDate: self.reminderTimeInterval) },
                                set: { self.reminderTimeInterval = $0.timeIntervalSinceReferenceDate }
                            ), displayedComponents: .hourAndMinute)
                            
                            Button("Send Basic Reminder Test") {
                                sendTestNotification()
                            }
                            
                            Button("Advanced Notification Tests") {
                                showingNotificationTestView = true
                            }
                            
                            Button("Notification Preferences") {
                                showingNotificationPreferencesView = true
                            }
                        }
                    }
                    .listRowBackground(Color.gray.opacity(0.15))
                    
                    Section(header: Text("Invite Friends")) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Share your code with friends. When they join, you'll earn awards.")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            HStack {
                                Text("Coming Soon")
                                    .font(.system(.title3).bold())
                                    .foregroundColor(.gray)
                                    .padding(.horizontal)
                                    .padding(.vertical, 8)
                            }
                        }
                        .padding(.vertical, 5)
                    }
                    
                    Section(header: Text("Support").foregroundColor(.gray)) {
                        Button("Rate on App Store") { /* Add App Store URL */ }
                        Button("Send Feedback") { /* Add mailto link */ }
                    }
                    .listRowBackground(Color.gray.opacity(0.15))
                    
                    Section(header: Text("General")) {
                        Button("Show Onboarding Again") {
                            showOnboarding = true
                        }
                        
                        Button("Sign Out") {
                            signOut()
                        }
                        .foregroundColor(.red)
                    }
                    
                    Section(header: Text("Legal").foregroundColor(.gray)) {
                        Button("Privacy Policy") { /* Add Privacy Policy URL */ }
                    }
                    .listRowBackground(Color.gray.opacity(0.15))
                }
                .foregroundColor(.white)
                .scrollContentBackground(.hidden)
                .navigationTitle("Settings")
                .padding(.bottom, 71)
            }
        }
        .preferredColorScheme(.dark)
        .onChange(of: isReminderEnabled) { _, _ in
            if isReminderEnabled {
                notificationManager.requestPermission()
            } else {
                notificationManager.cancelNotifications()
            }
            updateNotification()
        }
        .onChange(of: reminderTimeInterval) { _, _ in
            updateNotification()
        }
        .sheet(isPresented: $showingNotificationTestView) {
            NotificationTestView()
        }
        .sheet(isPresented: $showingNotificationPreferencesView) {
            NotificationPreferencesView()
        }
        .sheet(isPresented: $showingActivityScheduleView) {
            NotificationScheduleView()
        }
        .onAppear {
            notificationManager.checkPermission()
        }
    }
    
    private func updateNotification() {
        if isReminderEnabled && notificationManager.permissionGranted {
            notificationManager.scheduleDailyReminder(time: Date(timeIntervalSinceReferenceDate: reminderTimeInterval))
        } else {
            notificationManager.cancelNotifications()
        }
    }
    
    private func sendTestNotification() {
        if let goal = goals.first {
            notificationManager.scheduleTestNotification(for: goal)
        } else {
            // Show an alert if no goals are available
            let alert = UIAlertController(
                title: "No Goals Found",
                message: "Please create at least one goal to send a test notification.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController {
                rootVC.present(alert, animated: true)
            }
        }
    }
    
    private func shareCode() {
        let code = ReferralManager.userReferralCode
        let textToShare = "Join me on HorizonFrame and start building your mindfulness streak! Use my code to get started: \(code)"
        
                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let rootVC = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController else { return }
        
        let activityVC = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
        
        // For iPad support
        if let popoverController = activityVC.popoverPresentationController {
            popoverController.sourceView = rootVC.view
            popoverController.sourceRect = CGRect(x: rootVC.view.bounds.midX, y: rootVC.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        rootVC.present(activityVC, animated: true, completion: nil)
    }
    
    private func signOut() {
        // Reset user authentication state
        UserDefaults.standard.set(false, forKey: "isExistingUser")
        
        // Show confirmation alert
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController else { return }
        
        let alert = UIAlertController(
            title: "Signed Out",
            message: "You have been signed out successfully. The app will restart to apply changes.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            // Reset app state and show onboarding
            self.showOnboarding = true
            
            // Post notification to restart app flow
            NotificationCenter.default.post(name: .userDidSignOut, object: nil)
        })
        
        rootVC.present(alert, animated: true)
    }
}

// Extension to define notification names
extension Notification.Name {
    static let userDidSignOut = Notification.Name("userDidSignOut")
}

#Preview {
    SettingsView()
}
