import SwiftUI
import SwiftData

/*
struct NotificationTestView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var goals: [Goal]
    
    @StateObject private var notificationManager = NotificationManager.shared
    @State private var selectedGoal: Goal?
    @State private var selectedType: NotificationType = .futureVisualization
    @State private var showingPermissionAlert = false
    @State private var showingSuccessMessage = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Select Goal")) {
                    if goals.isEmpty {
                        Text("No goals available. Please create a goal first.")
                            .foregroundColor(.secondary)
                    } else {
                        Picker("Goal", selection: $selectedGoal) {
                            Text("Select a goal").tag(nil as Goal?)
                            ForEach(goals) { goal in
                                Text(goal.title).tag(goal as Goal?)
                            }
                        }
                    }
                }
                
                Section(header: Text("Notification Type")) {
                    Picker("Type", selection: $selectedType) {
                        ForEach(NotificationType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    Text(selectedType.explanation)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section {
                    Button("Send Test Notification") {
                        sendTestNotification()
                    }
                    .disabled(selectedGoal == nil || !notificationManager.permissionGranted)
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.borderedProminent)
                }
                
                if !notificationManager.permissionGranted {
                    Section {
                        Button("Request Notification Permission") {
                            notificationManager.requestPermission()
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .navigationTitle("Test Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Notification Sent", isPresented: $showingSuccessMessage) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("A test notification has been scheduled and will appear in a few seconds.")
            }
            .alert("Permission Required", isPresented: $showingPermissionAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
            } message: {
                Text("Notification permission is required to send test notifications. Please enable notifications in Settings.")
            }
        }
    }
    
    private func sendTestNotification() {
        guard notificationManager.permissionGranted else {
            showingPermissionAlert = true
            return
        }
        
        guard let goal = selectedGoal else {
            return
        }
        
        notificationManager.scheduleTestNotification(for: goal)
        showingSuccessMessage = true
    }
}

*/

// Temporary simplified version to isolate compilation issues
struct NotificationTestView: View {
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("Notification test temporarily disabled")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Test Notifications")
        }
    }
}

#Preview {
    NotificationTestView()
}
