import SwiftUI

struct NotificationPreferencesView: View {
    @StateObject private var viewModel = NotificationPreferencesViewModel()
    @ObservedObject private var notificationManager = NotificationManager.shared
    @State private var showingPermissionAlert = false
    @Environment(\.dismiss) private var dismiss
    
    // Helper views to break down complex expressions
    private var notificationStatusSection: some View {
        Section {
            Toggle("Enable Notifications", isOn: $viewModel.preferences.isEnabled)
                .onChange(of: viewModel.preferences.isEnabled) { _, newValue in
                    if newValue && !notificationManager.permissionGranted {
                        notificationManager.requestPermission()
                    }
                    viewModel.updatePreferences()
                }
        } header: {
            Text("Notification Status")
        } footer: {
            if !notificationManager.permissionGranted {
                Text("Notification permission is required. Please enable notifications in Settings.")
                    .foregroundColor(.red)
            }
        }
    }
    
    private func timePickerView(for index: Int) -> some View {
        HStack {
            DatePicker("Time \(index + 1)", selection: $viewModel.preferences.notificationTimes[index])
                .onChange(of: viewModel.preferences.notificationTimes[index]) { _, _ in
                    viewModel.updatePreferences()
                }
            
            if viewModel.preferences.notificationTimes.count > 1 {
                Button(action: {
                    viewModel.preferences.notificationTimes.remove(at: index)
                    viewModel.updatePreferences()
                }) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.red)
                }
            }
        }
    }
    
    private var addTimeButton: some View {
        Button(action: {
            // Add a new time 1 hour after the last one
            if let lastTime = viewModel.preferences.notificationTimes.last,
               let newTime = Calendar.current.date(byAdding: .hour, value: 1, to: lastTime) {
                viewModel.preferences.notificationTimes.append(newTime)
            } else {
                // Default to 8pm if no times exist
                if let defaultTime = Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date()) {
                    viewModel.preferences.notificationTimes.append(defaultTime)
                }
            }
            viewModel.updatePreferences()
        }) {
            Label("Add Time", systemImage: "plus.circle")
        }
    }
    
    private var notificationTimesSection: some View {
        Section(header: Text("Notification Times")) {
            ForEach(viewModel.preferences.notificationTimes.indices, id: \.self) { index in
                timePickerView(for: index)
            }
            
            addTimeButton
        }
    }
    
    private var frequencySection: some View {
        Section(header: Text("Frequency")) {
            Picker("Notification Frequency", selection: $viewModel.preferences.frequency) {
                ForEach(NotificationFrequency.allCases) { frequency in
                    Text(frequency.rawValue).tag(frequency)
                }
            }
            .pickerStyle(.menu)
            .onChange(of: viewModel.preferences.frequency) { _, _ in
                viewModel.updatePreferences()
            }
            
            Text(viewModel.preferences.frequency.description)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    
    private var notificationTypesSection: some View {
        Section(header: Text("Notification Types")) {
            notificationTypeToggle(for: .futureVisualization)
            notificationTypeToggle(for: .progressCelebration)
            notificationTypeToggle(for: .gentleAccountability)
            notificationTypeToggle(for: .contextualMotivation)
            notificationTypeToggle(for: .wisdomInsight)
        }
    }

    private func notificationTypeToggle(for type: NotificationType) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Toggle(type.displayName, isOn: viewModel.binding(for: type))
            
            if viewModel.preferences.enabledTypes.contains(type) {
                Text(type.explanation)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.leading, 10)
                    .padding(.bottom, 5)
            }
        }
    }
    
    private var testNotificationSection: some View {
        Section {
            Button("Send Test Notification") {
                sendTestNotification()
            }
            .disabled(!notificationManager.permissionGranted)
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                notificationStatusSection
                
                if viewModel.preferences.isEnabled {
                    notificationTimesSection
                    frequencySection
                    notificationTypesSection
                    testNotificationSection
                }
            }
            .navigationTitle("Notification Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Permission Required", isPresented: $showingPermissionAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
            } message: {
                Text("Notification permission is required. Please enable notifications in Settings.")
            }
            .onAppear {
                notificationManager.checkPermission()
            }
        }
    }
    
    
    private func sendTestNotification() {
        print("NOTIFICATION_TEST: Starting test notification")
        print("NOTIFICATION_TEST: Permission = \(notificationManager.permissionGranted)")
        
        guard notificationManager.permissionGranted else {
            print("NOTIFICATION_TEST: FAILED - No permission, showing alert")
            showingPermissionAlert = true
            return
        }
        
        // Schedule a test notification for 5 seconds from now
        let content = UNMutableNotificationContent()
        content.title = "Test Notification"
        content.body = "Your notification settings are working correctly!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "test-notification-\(Date().timeIntervalSince1970)", content: content, trigger: trigger)
        
        print("NOTIFICATION_TEST: Scheduling with ID: \(request.identifier)")
        
        UNUserNotificationCenter.current().add(request) { error in
            DispatchQueue.main.async {
                if let error = error {
                    print("NOTIFICATION_TEST: FAILED - \(error.localizedDescription)")
                } else {
                    print("NOTIFICATION_TEST: SUCCESS - Notification scheduled!")
                }
            }
        }
    }
}


#Preview {
    NotificationPreferencesView()
}
