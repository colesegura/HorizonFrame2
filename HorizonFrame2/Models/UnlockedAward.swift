import Foundation
import SwiftData

@Model
final class UnlockedAward {
    @Attribute(.unique) var id: String
    var unlockedDate: Date
    
    init(id: String, unlockedDate: Date) {
        self.id = id
        self.unlockedDate = unlockedDate
    }
}
