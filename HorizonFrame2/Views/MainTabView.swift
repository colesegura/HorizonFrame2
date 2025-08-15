import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Int = 0
    @AppStorage("showOnboarding") private var showOnboarding: Bool = true

    var body: some View {
        // TODO: Implement custom tab bar
        ZStack(alignment: .bottom) {
            // Content
            Group {
                if selectedTab == 0 {
                    TodayView()
                } else if selectedTab == 1 {
                    GoalsView()
                } else if selectedTab == 2 {
                    ProgressView()
                } else {
                    SettingsView()
                }
            }.frame(maxWidth: .infinity, maxHeight: .infinity)

            // Custom Tab Bar
            CustomTabBar(selectedTab: $selectedTab)
                .padding(.bottom, 10)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingView(showOnboarding: $showOnboarding)
        }
        .onReceive(NotificationCenter.default.publisher(for: .userDidSignOut)) { _ in
            // Reset to first tab
            selectedTab = 0
            
            // Show onboarding
            showOnboarding = true
        }
    }
}

// Placeholder Views








#Preview {
    MainTabView()
}
