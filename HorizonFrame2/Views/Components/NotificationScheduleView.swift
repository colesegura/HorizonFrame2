import SwiftUI

struct NotificationScheduleView: View {
    @ObservedObject private var notificationManager = NotificationManager.shared
    @Environment(\.dismiss) private var dismiss
    
    // Time settings for the three main activities
    @State private var alignmentTime: Date
    @State private var dailyReviewTime: Date
    @State private var weeklyReviewDay: Int // 1 = Sunday, 2 = Monday, etc.
    @State private var weeklyReviewTime: Date
    
    // UI state
    @State private var showingPermissionAlert = false
    
    init() {
        // Initialize with current settings or defaults
        let preferences = UserDefaults.standard.activityNotificationPreferences
        
        // Set initial state values
        _alignmentTime = State(initialValue: preferences.dailyAlignmentTime)
        _dailyReviewTime = State(initialValue: preferences.dailyReviewTime)
        _weeklyReviewDay = State(initialValue: preferences.weeklyReviewDay)
        _weeklyReviewTime = State(initialValue: preferences.weeklyReviewTime)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Daily Alignment Section
                        activitySection(
                            title: "Daily Alignment",
                            description: "We recommend setting this for the morning to start your day with intention.",
                            timeBinding: $alignmentTime,
                            highlightMorning: true,
                            showDayPicker: false
                        )
                        
                        // Daily Review Section
                        activitySection(
                            title: "Daily Review",
                            description: "We recommend setting this for the evening to reflect on your day.",
                            timeBinding: $dailyReviewTime,
                            highlightMorning: false,
                            showDayPicker: false
                        )
                        
                        // Weekly Review Section
                        activitySection(
                            title: "Weekly Review",
                            description: "A time to reflect on your week and plan for the next one.",
                            timeBinding: $weeklyReviewTime,
                            highlightMorning: true,
                            showDayPicker: true,
                            dayBinding: $weeklyReviewDay
                        )
                        
                        // Test notification button
                        Button(action: {
                            notificationManager.sendGeneralTestNotification()
                        }) {
                            Text("Send Test Notification")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue.opacity(0.6))
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                    }
                    .padding(.vertical, 20)
                }
            }
            .navigationTitle("Activity Schedule")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveSettings()
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .preferredColorScheme(.dark)
            .alert("Notification Permission Required", isPresented: $showingPermissionAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
            } message: {
                Text("Please enable notifications in Settings to receive activity reminders.")
            }
            .onAppear {
                notificationManager.checkPermission()
            }
        }
    }
    
    @ViewBuilder
    private func activitySection(
        title: String,
        description: String,
        timeBinding: Binding<Date>,
        highlightMorning: Bool,
        showDayPicker: Bool,
        dayBinding: Binding<Int>? = nil
    ) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(description)
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.bottom, 5)
            
            // Day picker for weekly review
            if showDayPicker, let dayBinding = dayBinding {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Day of Week")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Picker("Day", selection: dayBinding) {
                        Text("Sunday").tag(1)
                        Text("Monday").tag(2)
                        Text("Tuesday").tag(3)
                        Text("Wednesday").tag(4)
                        Text("Thursday").tag(5)
                        Text("Friday").tag(6)
                        Text("Saturday").tag(7)
                    }
                    .pickerStyle(.segmented)
                }
                .padding(.bottom, 10)
            }
            
            // Time selection
            VStack(alignment: .leading, spacing: 10) {
                Text("Time")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
                
                // Custom time slider
                timeSlider(binding: timeBinding, highlightMorning: highlightMorning)
                
                // Time display
                HStack {
                    Spacer()
                    Text(timeBinding.wrappedValue.formatted(date: .omitted, time: .shortened))
                        .font(.system(.title3, design: .monospaced))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.top, 5)
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(15)
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private func timeSlider(binding: Binding<Date>, highlightMorning: Bool) -> some View {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: binding.wrappedValue)
        let minute = calendar.component(.minute, from: binding.wrappedValue)
        
        // Convert to minutes since midnight (0-1439)
        let totalMinutes = hour * 60 + minute
        
        // Binding for the slider
        let sliderBinding = Binding<Double>(
            get: { Double(totalMinutes) },
            set: { newValue in
                // Round to nearest 15 minutes
                let roundedMinutes = Int(round(newValue / 15) * 15) % 1440
                let newHour = roundedMinutes / 60
                let newMinute = roundedMinutes % 60
                
                if let newDate = calendar.date(bySettingHour: newHour, minute: newMinute, second: 0, of: binding.wrappedValue) {
                    binding.wrappedValue = newDate
                }
            }
        )
        
        return VStack(spacing: 0) {
            // Time markers
            HStack {
                Text("12 AM")
                    .font(.caption2)
                    .foregroundColor(.gray)
                Spacer()
                Text("6 AM")
                    .font(.caption2)
                    .foregroundColor(.gray)
                Spacer()
                Text("12 PM")
                    .font(.caption2)
                    .foregroundColor(.gray)
                Spacer()
                Text("6 PM")
                    .font(.caption2)
                    .foregroundColor(.gray)
                Spacer()
                Text("12 AM")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            // Highlighted time ranges
            ZStack(alignment: .leading) {
                // Background track
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 8)
                    .cornerRadius(4)
                
                // Morning highlight (4am-10am)
                if highlightMorning {
                    Rectangle()
                        .fill(Color.green.opacity(0.3))
                        .frame(width: UIScreen.main.bounds.width * 0.25, height: 8)
                        .offset(x: UIScreen.main.bounds.width * 0.17) // 4am position
                } else {
                    // Evening highlight (4pm-12am)
                    Rectangle()
                        .fill(Color.purple.opacity(0.3))
                        .frame(width: UIScreen.main.bounds.width * 0.33, height: 8)
                        .offset(x: UIScreen.main.bounds.width * 0.67) // 4pm position
                }
                
                // Slider
                Slider(value: sliderBinding, in: 0...1439, step: 15)
                    .accentColor(.white)
            }
        }
    }
    
    private func saveSettings() {
        // Check if we have notification permission
        if !notificationManager.permissionGranted {
            showingPermissionAlert = true
            return
        }
        
        // Create new preferences object
        var preferences = UserDefaults.standard.activityNotificationPreferences
        preferences.dailyAlignmentTime = alignmentTime
        preferences.dailyReviewTime = dailyReviewTime
        preferences.weeklyReviewDay = weeklyReviewDay
        preferences.weeklyReviewTime = weeklyReviewTime
        
        // Save to UserDefaults
        UserDefaults.standard.activityNotificationPreferences = preferences
        
        // Schedule notifications
        notificationManager.scheduleActivityNotifications(preferences: preferences)
    }
}

#Preview {
    NotificationScheduleView()
}
