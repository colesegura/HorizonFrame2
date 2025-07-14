import Foundation
import SwiftUI

class ReferralManager {
    @AppStorage("userReferralCode") static var userReferralCode: String = ""
    
    static func generateReferralCode() -> String {
        if !userReferralCode.isEmpty {
            return userReferralCode
        }
        
        let newCode = randomString(length: 8).uppercased()
        userReferralCode = newCode
        return newCode
    }
    
    private static func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyz0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
}
