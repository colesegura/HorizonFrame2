import Foundation
import SwiftData

@Model
final class Goal {
    var text: String
    var order: Int
    var createdAt: Date
    
    init(text: String, order: Int) {
        self.text = text
        self.order = order
        self.createdAt = Date()
    }
}
