import SwiftUI

struct ExistingAccountView: View {
    @Binding var showOnboarding: Bool
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoading = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // Title
                Text("Welcome Back")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                // Subtitle
                Text("Sign in to continue your journey")
                    .font(.title3)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                // Login form
                VStack(spacing: 20) {
                    TextField("Email", text: $email)
                        .font(.body)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                    
                    SecureField("Password", text: $password)
                        .font(.body)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                    
                    Button(action: {
                        isLoading = true
                        // TODO: Implement actual login logic
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            isLoading = false
                            showOnboarding = false
                        }
                    }) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                    .scaleEffect(0.8)
                            }
                            Text(isLoading ? "Signing In..." : "Sign In")
                                .font(.headline)
                                .foregroundColor(.black)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(15)
                    }
                    .disabled(email.isEmpty || password.isEmpty || isLoading)
                    .opacity(email.isEmpty || password.isEmpty ? 0.6 : 1.0)
                }
                .padding(.horizontal, 30)
                
                // Forgot password link
                Button(action: {
                    // TODO: Handle forgot password
                }) {
                    Text("Forgot Password?")
                        .font(.body)
                        .foregroundColor(.white)
                        .underline()
                }
                
                Spacer()
                
                // Back to onboarding button
                Button(action: {
                    showOnboarding = true
                }) {
                    Text("Back to Onboarding")
                        .font(.body)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                    .frame(height: 50)
            }
        }
    }
}

#Preview {
    ExistingAccountView(showOnboarding: .constant(true))
} 