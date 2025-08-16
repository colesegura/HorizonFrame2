import SwiftUI

struct UpgradeButton: View {
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State private var showPaywall = false
    
    var body: some View {
        if !subscriptionManager.isSubscribed {
            Button(action: {
                showPaywall = true
            }) {
                Text("Upgrade")
                    .font(.system(.headline, design: .rounded).bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(20)
            }
            .buttonStyle(PlainButtonStyle())
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }
}

#Preview {
    HStack {
        UpgradeButton()
        StreakCounterView()
    }
    .background(Color.black)
}
