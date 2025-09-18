import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var userManager: UserManager
    @Binding var showOnboarding: Bool
    @State private var tabSelection = 0
    @AppStorage("isExistingUser") private var isExistingUser = false


    
    private let transition = AnyTransition.asymmetric(
        insertion: .move(edge: .trailing),
        removal: .move(edge: .leading)
    )

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

                VStack {
                    // Navigation buttons (show on all pages except welcome)
                    if tabSelection > 0 {
                        HStack {
                            // Back button
                            Button(action: {
                                withAnimation {
                                    tabSelection -= 1
                                }
                            }) {
                                Image(systemName: "arrow.left")
                                    .font(.title2.bold())
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
                            
                            // Exit button (only for existing users)
                            if isExistingUser {
                                Button(action: {
                                    withAnimation {
                                        showOnboarding = false
                                    }
                                }) {
                                    Text("Exit")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                    }
                    
                    TabView(selection: $tabSelection) {
                        WelcomeView(showOnboarding: $showOnboarding, tag: 0) {
                            withAnimation {
                                tabSelection = 1
                            }
                        }
                        
                        AgeView(showOnboarding: $showOnboarding, tag: 1) {
                            withAnimation {
                                tabSelection = 2
                            }
                        }
                        
                        InterestSelectionView(showOnboarding: $showOnboarding, tag: 2) {
                            withAnimation {
                                tabSelection = 3
                            }
                        }
                        
                        InterestFollowUpView(showOnboarding: $showOnboarding, tag: 3) {
                            withAnimation {
                                tabSelection = 4
                            }
                        }
                        
                        OccupationView(showOnboarding: $showOnboarding, tag: 4) {
                            withAnimation {
                                tabSelection = 5
                            }
                        }
                        
                        GoalReviewFrequencyView(showOnboarding: $showOnboarding, tag: 5) {
                            withAnimation {
                                tabSelection = 6
                            }
                        }
                        
                        BiggestBlockerView(showOnboarding: $showOnboarding, tag: 6) {
                            withAnimation {
                                tabSelection = 7
                            }
                        }
                        
                        NinetyDayMilestoneView(showOnboarding: $showOnboarding, tag: 7) {
                            withAnimation {
                                tabSelection = 8
                            }
                        }
                        
                        ActionableStepView(showOnboarding: $showOnboarding, tag: 8) {
                            withAnimation {
                                tabSelection = 9
                            }
                        }
                        
                        FocusTimeView(showOnboarding: $showOnboarding, tag: 9) {
                            withAnimation {
                                tabSelection = 10
                            }
                        }
                        
                        GoalTrackingToolView(showOnboarding: $showOnboarding, tag: 10) {
                            withAnimation {
                                tabSelection = 11
                            }
                        }
                        
                        FallingShortFrequencyView(showOnboarding: $showOnboarding, tag: 11) {
                            withAnimation {
                                tabSelection = 12
                            }
                        }
                        
                        MindClearingBenefitsView(showOnboarding: $showOnboarding, tag: 12) {
                            withAnimation {
                                tabSelection = 13
                            }
                        }

                        AlignmentReportLoadingView(showOnboarding: $showOnboarding, tag: 13) {
                            withAnimation {
                                tabSelection = 14
                            }
                        }

                        AlignmentHookView(showOnboarding: $showOnboarding, tag: 14) {
                            withAnimation {
                                tabSelection = 15
                            }
                        }

                        AlignmentDriftView(showOnboarding: $showOnboarding, tag: 15) {
                            withAnimation {
                                tabSelection = 16
                            }
                        }

                        PricingOptionsView(showOnboarding: $showOnboarding, tag: 16) {
                            withAnimation {
                                tabSelection = 17
                            }
                        }

                        OnboardingCompletionView(showOnboarding: $showOnboarding, tag: 17)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
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
            
            actionButton

            // Referral code feature coming soon
            Spacer().frame(height: 20)

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
                tag: 14
            )
        case .denied:
            OnboardingPageView(
                imageName: "xmark.circle.fill",
                title: "Reminders Disabled",
                description: "You can enable reminders anytime in the app's Settings tab or your iPhone's Settings.",
                tag: 14
            )
        default:
            OnboardingPageView(
                imageName: "bell.badge.fill",
                title: "Enable Reminders",
                description: "A daily reminder is the best way to stay consistent and build your streak.",
                tag: 14
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
