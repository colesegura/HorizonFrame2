import SwiftUI

struct OnboardingView: View {
    @Binding var showOnboarding: Bool
    @State private var tabSelection = 0
    
    private let transition = AnyTransition.asymmetric(
        insertion: .move(edge: .trailing),
        removal: .move(edge: .leading)
    )

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack {
                TabView(selection: $tabSelection) {
                    OnboardingPageView(
                        imageName: "text.book.closed.fill",
                        title: "Set Your Focus",
                        description: "Define your goals and intentions. What do you want to achieve today?",
                        tag: 0
                    )

                    OnboardingPageView(
                        imageName: "wind",
                        title: "Align Daily",
                        description: "Take a few minutes to breathe and visualize your goals, turning them into reality.",
                        tag: 1
                    )

                    OnboardingPageView(
                        imageName: "flame.fill",
                        title: "Build Your Streak",
                        description: "Consistency is key. Complete your alignment each day to build a powerful habit.",
                        tag: 2
                    )
                    
                    OnboardingCompletionView(showOnboarding: $showOnboarding, tag: 3)
                        .tag(3)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // Custom Page Indicator
                HStack(spacing: 8) {
                    ForEach(0..<4) { index in
                        Capsule()
                            .fill(tabSelection == index ? Color.white : Color.gray.opacity(0.5))
                            .frame(width: tabSelection == index ? 24 : 8, height: 8)
                    }
                }
                .animation(.spring(), value: tabSelection)
                .padding(.bottom, 30)

                Button(action: {
                    withAnimation {
                        if tabSelection < 3 {
                            tabSelection += 1
                        } else {
                            // This is handled by the completion view's button
                        }
                    }
                }) {
                    Text(tabSelection < 3 ? "Next" : "Get Started")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(15)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 50)
                .opacity(tabSelection == 3 ? 0 : 1) // Hide button on last page
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct OnboardingPageView: View {
    let imageName: String
    let title: String
    let description: String
    let tag: Int

    var body: some View {
        VStack(spacing: 40) {
            Image(systemName: imageName)
                .font(.system(size: 80))
                .foregroundColor(.white)
                .shadow(color: .white.opacity(0.3), radius: 10)

            VStack(spacing: 15) {
                Text(title)
                    .font(.largeTitle.bold())
                Text(description)
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 40)
        .tag(tag)
    }
}

import UserNotifications

struct OnboardingCompletionView: View {
    @Binding var showOnboarding: Bool
    @State private var referralCode: String = ""
    @State private var notificationStatus: UNAuthorizationStatus = .notDetermined
    let tag: Int
    
    var body: some View {
        VStack(spacing: 30) {
            
            pageContent
            
            TextField("Enter referral code (optional)", text: $referralCode)
                .font(.body)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            actionButton

            Spacer().frame(height: 50) // To push content up a bit
        }
        .onAppear(perform: checkNotificationStatus)
    }
    
    @ViewBuilder
    private var pageContent: some View {
        switch notificationStatus {
        case .authorized:
            OnboardingPageView(
                imageName: "checkmark.circle.fill",
                title: "Reminders Enabled",
                description: "You're all set! We'll help you stay on track.",
                tag: 3
            )
        case .denied:
            OnboardingPageView(
                imageName: "xmark.circle.fill",
                title: "Reminders Disabled",
                description: "You can enable reminders anytime in the app's Settings tab or your iPhone's Settings.",
                tag: 3
            )
        default:
            OnboardingPageView(
                imageName: "bell.badge.fill",
                title: "Enable Reminders",
                description: "A daily reminder is the best way to stay consistent and build your streak.",
                tag: 3
            )
        }
    }
    
    @ViewBuilder
    private var actionButton: some View {
        Button(action: {
            if notificationStatus == .notDetermined {
                NotificationManager.shared.requestPermission()
            }
            // TODO: Add logic to save referral code
            showOnboarding = false
        }) {
            Text("Get Started")
                .font(.headline)
                .foregroundColor(.black)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(15)
        }
        .padding(.horizontal, 40)
    }
    
    private func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.notificationStatus = settings.authorizationStatus
            }
        }
    }
}

#Preview {
    OnboardingView(showOnboarding: .constant(true))
}
