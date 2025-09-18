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
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 70, height: 32)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white.opacity(0.5), lineWidth: 1)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.black)
                            )
                    )
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
