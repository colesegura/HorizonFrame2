import SwiftUI

class NotificationPreferencesViewModel: ObservableObject {
    @Published var preferences: NotificationPreferences
    private var notificationManager = NotificationManager.shared

    init() {
        self.preferences = NotificationManager.shared.preferences
    }

    func updatePreferences() {
        notificationManager.updatePreferences(with: preferences)
    }

    func binding(for type: NotificationType) -> Binding<Bool> {
        Binding<Bool>(
            get: { self.preferences.enabledTypes.contains(type) },
            set: { newValue in
                if newValue {
                    self.preferences.enabledTypes.insert(type)
                } else {
                    self.preferences.enabledTypes.remove(type)
                }
                self.updatePreferences()
            }
        )
    }
}
