import SwiftUI
import StoreKit

struct PaywallView: View {
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPlan: String = "yearly"
    @State private var isPurchasing = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    private var yearlyPrice: String {
        if let product = subscriptionManager.availableProducts.first(where: { $0.id == "com.horizonframe.yearly" }) {
            return product.displayPrice
        }
        return "$59.99/year"
    }
    
    private var weeklyPrice: String {
        if let product = subscriptionManager.availableProducts.first(where: { $0.id == "com.horizonframe.weekly" }) {
            return product.displayPrice
        }
        return "$4.99/week"
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with close button
                HStack {
                    Spacer()
                    Button("✕") {
                        dismiss()
                    }
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding()
                }
                
                ScrollView {
                    VStack(spacing: 40) {
                        // Title
                        VStack(spacing: 16) {
                            Text("Start Your Free Trial")
                                .font(.largeTitle.bold())
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            
                            Text("Activate Your Ritual Plan")
                                .font(.title2)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 20)
                        
                        // Pricing Options
                        VStack(spacing: 16) {
                            // Yearly Plan
                            PricingPlan(
                                title: "Yearly",
                                price: yearlyPrice,
                                detail: "7-day free trial",
                                isRecommended: true,
                                isSelected: selectedPlan == "yearly",
                                showBadge: true,
                                badgeText: "60% OFF"
                            ) {
                                selectedPlan = "yearly"
                            }
                            
                            // Weekly Plan
                            PricingPlan(
                                title: "Weekly",
                                price: weeklyPrice,
                                detail: "3-day free trial",
                                isRecommended: false,
                                isSelected: selectedPlan == "weekly",
                                showBadge: false,
                                badgeText: ""
                            ) {
                                selectedPlan = "weekly"
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Start Free Trial Button
                        Button(action: {
                            Task {
                                await startFreeTrial()
                            }
                        }) {
                            VStack(spacing: 8) {
                                Text("Start Free Trial")
                                    .font(.headline.bold())
                                    .foregroundColor(.black)
                                
                                Text("No payment due now")
                                    .font(.caption)
                                    .foregroundColor(.black.opacity(0.7))
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(
                                    colors: [.white, .gray.opacity(0.9)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .cornerRadius(25)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .disabled(isPurchasing)
                        .padding(.horizontal, 20)
                        
                        // Features
                        VStack(spacing: 16) {
                            Text("What's included:")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            VStack(spacing: 12) {
                                FeatureRow(icon: "target", title: "Unlimited Goals")
                                FeatureRow(icon: "eye.fill", title: "Advanced Visualizations")
                                FeatureRow(icon: "chart.line.uptrend.xyaxis", title: "Detailed Analytics")
                                FeatureRow(icon: "bell.fill", title: "Smart Reminders")
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Restore Purchases
                        Button(action: {
                            Task {
                                await subscriptionManager.restorePurchases()
                            }
                        }) {
                            Text("Restore Purchases")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        // Terms and Privacy
                        VStack(spacing: 8) {
                            Text("By continuing, you agree to our")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            HStack(spacing: 20) {
                                Link("Terms of Service", destination: URL(string: "https://yourapp.com/terms")!)
                                Link("Privacy Policy", destination: URL(string: "https://yourapp.com/privacy")!)
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                        
                        Spacer(minLength: 50)
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
        .alert("Purchase Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func startFreeTrial() async {
        isPurchasing = true
        
        // Find the selected product
        let productID = selectedPlan == "yearly" ? "com.horizonframe.yearly" : "com.horizonframe.weekly"
        
        if let product = subscriptionManager.availableProducts.first(where: { $0.id == productID }) {
            let success = await subscriptionManager.purchase(product)
            
            if success {
                dismiss()
            } else {
                errorMessage = "Purchase failed. Please try again."
                showError = true
            }
        } else {
            errorMessage = "Product not available. Please try again."
            showError = true
        }
        
        isPurchasing = false
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.white)
            
            Spacer()
        }
    }
}

// PricingPlan is defined in OnboardingPages.swift and used here

#Preview {
    PaywallView()
}
