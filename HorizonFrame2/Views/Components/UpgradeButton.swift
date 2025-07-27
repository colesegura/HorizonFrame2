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
                    .font(.system(.caption, design: .rounded).bold())
                    .foregroundColor(.black)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        LinearGradient(
                            colors: [.yellow, .orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
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
