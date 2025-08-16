import Foundation
import Foundation

struct APIConfig {
    // MARK: - OpenAI API Configuration

    // Retrieves the OpenAI API key from the app's Info.plist.
    // The Info.plist is populated by the `Secrets.xcconfig` file.
    static var openAIAPIKey: String {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "OPENAI_API_KEY") as? String else {
            fatalError("OPENAI_API_KEY not found in Info.plist. Make sure it's set in Secrets.xcconfig.")
        }
        return apiKey
    }
}
