import SwiftUI

struct SettingsView: View {
    @StateObject private var notificationManager = NotificationManager.shared
    @AppStorage("isReminderEnabled") private var isReminderEnabled = false
    @AppStorage("reminderTime") private var reminderTimeInterval: Double = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: .now)?.timeIntervalSinceReferenceDate ?? Date().timeIntervalSinceReferenceDate
    @AppStorage("showOnboarding") private var showOnboarding = false
    @AppStorage("preferredMeditationDuration") private var preferredMeditationDuration: TimeInterval = 300


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
                        
                        if isReminderEnabled {
                                                        DatePicker("Reminder Time", selection: .init(
                                get: { Date(timeIntervalSinceReferenceDate: self.reminderTimeInterval) },
                                set: { self.reminderTimeInterval = $0.timeIntervalSinceReferenceDate }
                            ), displayedComponents: .hourAndMinute)
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
                    }
                    
                    Section(header: Text("Legal").foregroundColor(.gray)) {
                        Button("Privacy Policy") { /* Add Privacy Policy URL */ }
                    }
                    .listRowBackground(Color.gray.opacity(0.15))
                }
                .foregroundColor(.white)
                .scrollContentBackground(.hidden)
                .navigationTitle("Settings")
            }
        }
        .preferredColorScheme(.dark)
        .onChange(of: isReminderEnabled) { _, newValue in
            if newValue {
                notificationManager.requestPermission()
            } else {
                notificationManager.cancelNotifications()
            }
            updateNotification()
        }
        .onChange(of: reminderTimeInterval) {
            updateNotification()
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
}




#Preview {
    SettingsView()
}
