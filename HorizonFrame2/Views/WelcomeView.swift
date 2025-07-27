import SwiftUI

struct WelcomeView: View {
    @Binding var showOnboarding: Bool
    let tag: Int
    var onNext: (() -> Void)?
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                // Top 3/4 of screen - space for app screenshot
                Spacer()
                    .frame(maxHeight: .infinity)
                
                // Bottom 1/4 of screen - content
                VStack(spacing: 20) {
                    // Title and subtitle
                    VStack(spacing: 8) {
                        Text("Welcome to HorizonFrame")
                            .font(.largeTitle.bold())
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Text("Start building a life aligned with your dreams today.")
                            .font(.title3)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    
                    // Get Started button
                    Button(action: {
                        withAnimation {
                            onNext?()
                        }
                    }) {
                        Text("Get Started")
                            .font(.headline)
                            .foregroundColor(.black)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(15)
                    }
                    .padding(.horizontal, 30)
                    
                    // Already have an account link
                    Button(action: {
                        NotificationCenter.default.post(name: .showExistingAccount, object: nil)
                    }) {
                        Text("Already have an account?")
                            .font(.body)
                            .foregroundColor(.white)
                            .underline()
                    }
                    
                    Spacer()
                        .frame(height: 20)
                }
                .padding(.bottom, 50)
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