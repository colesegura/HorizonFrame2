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
                    FocusesView()
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
    }
}

// Placeholder Views








#Preview {
    MainTabView()
}
