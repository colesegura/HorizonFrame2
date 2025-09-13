import Foundation
import SwiftData

@Model
final class PersonalCode {
    var createdAt: Date
    var lastModified: Date
    @Relationship(deleteRule: .cascade) var principles: [PersonalCodePrinciple]
    
    init() {
        self.createdAt = Date()
        self.lastModified = Date()
        self.principles = []
    }
}
