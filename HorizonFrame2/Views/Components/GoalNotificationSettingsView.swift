import SwiftUI
import SwiftData

struct GoalNotificationSettingsView: View {
    var goal: Goal
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var notificationManager = NotificationManager.shared
    
    @State private var isEnabled: Bool = true
    @State private var enabledTypes: Set<NotificationType> = Set(NotificationType.allCases)
    @State private var frequency: NotificationFrequency = .daily
    @State private var preferredTime: Date = Calendar.current.date(bySettingHour: 10, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var showingPermissionAlert = false
    
    private let goalIdString: String
    
    init(goal: Goal) {
        self.goal = goal
        self.goalIdString = String(describing: goal.id)
        
        // Load existing settings if available
        if let settings = UserDefaults.standard.getGoalNotificationSettings(for: self.goalIdString) {
            _isEnabled = State(initialValue: settings.isEnabled)
            _enabledTypes = State(initialValue: Set(settings.enabledTypes))
            _frequency = State(initialValue: settings.frequency)
            _preferredTime = State(initialValue: settings.preferredTime)
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                Form {
                    Section(header: Text("Goal Notifications").foregroundColor(.gray)) {
                        Toggle("Enable Notifications for this Goal", isOn: $isEnabled)
                            .onChange(of: isEnabled) { _, newValue in
                                if newValue && !notificationManager.permissionGranted {
                                    showingPermissionAlert = true
                                    isEnabled = false
                                }
                            }
                        
                        if isEnabled {
                            DatePicker("Notification Time", selection: $preferredTime, displayedComponents: .hourAndMinute)
                            
                            Picker("Frequency", selection: $frequency) {
                                ForEach(NotificationFrequency.allCases, id: \.self) { freq in
                                    Text(freq.description).tag(freq)
                                }
                            }
                            
                            Section(header: Text("Notification Types").foregroundColor(.gray)) {
                                ForEach(NotificationType.allCases, id: \.self) { type in
                                    Toggle(type.displayName, isOn: Binding(
                                        get: { enabledTypes.contains(type) },
                                        set: { isOn in
                                            if isOn {
                                                enabledTypes.insert(type)
                                            } else {
                                                enabledTypes.remove(type)
                                            }
                                        }
                                    ))
                                }
                            }
                            
                            Button("Send Test Notification") {
                                notificationManager.scheduleTestNotification(for: goal)
                            }
                            .foregroundColor(.blue)
                        }
                    }
                    .listRowBackground(Color.gray.opacity(0.15))
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Notification Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveSettings()
                        dismiss()
                    }
                }
            }
            .alert("Notification Permission Required", isPresented: $showingPermissionAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
            } message: {
                Text("Please enable notifications in Settings to receive goal updates.")
            }
            .onAppear {
                notificationManager.checkPermission()
            }
        }
    }
    
    private func saveSettings() {
        // Create settings object
        let settings = GoalNotificationSettings(
            goalIdString: goalIdString,
            isEnabled: isEnabled,
            enabledTypes: Array(enabledTypes),
            frequency: frequency,
            preferredTime: preferredTime
        )
        
        // Save to NotificationManager
        notificationManager.updateGoalNotificationSettings(settings)
    }
}

#Preview {
    GoalNotificationSettingsView(goal: Goal(text: "Test Goal", order: 0))
}
