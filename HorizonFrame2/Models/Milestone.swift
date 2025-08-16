import Foundation

struct Milestone: Identifiable {
    let id: UUID
    let title: String
    let description: String
    let icon: String
    let isUnlocked: Bool
    
    init(id: UUID = UUID(), title: String, description: String, icon: String, isUnlocked: Bool) {
        self.id = id
        self.title = title
        self.description = description
        self.icon = icon
        self.isUnlocked = isUnlocked
    }
    
    // Convenience initializer for backward compatibility
    init(id: String, title: String, description: String, icon: String, isUnlocked: Bool) {
        self.init(id: UUID(), title: title, description: description, icon: icon, isUnlocked: isUnlocked)
    }
}
