import Foundation
import SwiftData

@Model
final class PersonalCodePrinciple {
    var text: String
    var order: Int
    var createdAt: Date
    var isActive: Bool
    @Relationship var personalCode: PersonalCode?
    
    init(text: String, order: Int, personalCode: PersonalCode? = nil) {
        self.text = text
        self.order = order
        self.createdAt = Date()
        self.isActive = true
        self.personalCode = personalCode
    }
}
