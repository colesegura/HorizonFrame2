import SwiftUI
import AuthenticationServices

struct WelcomeView: View {
    @Binding var showOnboarding: Bool
    @State private var isAuthenticated = false
    @AppStorage("isExistingUser") private var isExistingUser = false
    let tag: Int
    var onNext: (() -> Void)?
    
    var body: some View {
        ZStack {
            // Background
            Color.black.ignoresSafeArea()
            
            // Main content
            VStack(spacing: 0) {
                // Top spacing to push image down from top
                Spacer()
                    .frame(height: UIScreen.main.bounds.height * 0.1)
                
                // Image section - takes up most of the screen
                Image("RotatoProgressPage2")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .frame(height: UIScreen.main.bounds.height * 0.55) // Increased from 0.5 to 0.55
                    .clipped()
                
                // Spacer to push content to bottom with specific spacing
                Spacer()
                    .frame(height: UIScreen.main.bounds.height * 0.05)
                
                // Text and buttons at bottom - more compact
                VStack(spacing: 12) {
                    VStack(spacing: 6) {
                        Text("Welcome to HorizonFrame")
                            .font(.title.bold())
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Text("Start building a life aligned with your dreams today.")
                            .font(.body)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    
                    // TEMPORARY: Skip Apple Sign In for testing
                    Button(action: {
                        // Handle successful authorization (testing bypass)
                        print("Apple Sign In bypassed for testing")
                        isAuthenticated = true
                        
                        // Set user as existing for future sessions
                        isExistingUser = true
                        
                        // Proceed to onboarding
                        withAnimation {
                            if let next = onNext {
                                next()
                            }
                        }
                    }) {
                        HStack {
                            Image(systemName: "applelogo")
                                .font(.title3)
                            Text("Continue with Apple")
                                .font(.headline)
                        }
                        .foregroundColor(.black)
                        .frame(width: UIScreen.main.bounds.width * 0.85, height: 50)
                        .background(Color.white)
                        .cornerRadius(15)
                    }
                    .padding(.top, 8)
                }
                .padding(.bottom, 30)
            }
        }
    
        .tag(tag)
    }
}

// Extension to define the notification name
extension Notification.Name {
    static let showExistingAccount = Notification.Name("showExistingAccount")
}

#Preview {
    WelcomeView(showOnboarding: .constant(true), tag: 0)
} 