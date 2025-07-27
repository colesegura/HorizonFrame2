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
        return "$49.99"
    }
    
    private var yearlyWeeklyEquivalent: String {
        // Calculate weekly equivalent: $49.99 / 52 weeks = ~$0.96
        if let product = subscriptionManager.availableProducts.first(where: { $0.id == "com.horizonframe.yearly" }) {
            // Extract numeric value from display price and calculate weekly equivalent
            let priceString = product.displayPrice.replacingOccurrences(of: "$", with: "").replacingOccurrences(of: "/year", with: "")
            if let yearlyAmount = Double(priceString) {
                let weeklyAmount = yearlyAmount / 52.0
                return String(format: "$%.2f", weeklyAmount)
            }
        }
        return "$0.96"
    }
    
    private var weeklyPrice: String {
        if let product = subscriptionManager.availableProducts.first(where: { $0.id == "com.horizonframe.weekly" }) {
            return product.displayPrice
        }
        return "$1.99"
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with restore purchases and close button
                HStack {
                    Button(action: {
                        Task {
                            await subscriptionManager.restorePurchases()
                        }
                    }) {
                        Text("Restore")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Button("✕") {
                        dismiss()
                    }
                    .foregroundColor(.gray)
                    .font(.title2)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                .padding(.bottom, 20)
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Title
                        VStack(spacing: 16) {
                            Text("Start your Free Trial and gain clarity")
                                .font(.title.bold())
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            
                            Text("Build a life aligned with your dreams")
                                .font(.title2)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 10)
                        
                        // Pricing Options
                        VStack(spacing: 16) {
                            // Yearly Plan
                            CustomPricingCard(
                                title: "Yearly",
                                price: yearlyPrice,
                                weeklyEquivalent: "only \(yearlyWeeklyEquivalent)/week",
                                freeTrialText: "Free for 1 week",
                                isSelected: selectedPlan == "yearly",
                                showBadge: true,
                                badgeText: "60% OFF"
                            ) {
                                selectedPlan = "yearly"
                            }
                            
                            // Weekly Plan
                            CustomPricingCard(
                                title: "Weekly",
                                price: "\(weeklyPrice)/week",
                                weeklyEquivalent: "",
                                freeTrialText: "Free for 3 days",
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
                            Text(selectedPlan == "yearly" ? "Start Your First Week" : "Start Your Free 3 Days")
                                .font(.headline.bold())
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(25)
                        }
                        .disabled(isPurchasing)
                        .padding(.horizontal, 20)
                        
                        // No payment due now text with checkmark
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.gray)
                                .font(.caption)
                            
                            Text("No payment due now!")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 4)
                        
                        // Features
                        VStack(spacing: 16) {
                            Text("What's included:")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            VStack(spacing: 12) {
                                FeatureRow(icon: "target", title: "Unlimited Goals")
                                FeatureRow(icon: "photo.fill", title: "Aligned Wallpapers")
                                FeatureRow(icon: "bell.fill", title: "Motivational Reminders")
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .padding(.horizontal, 20)
                        
                        // Terms and Privacy - moved up
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
                        
                        Spacer(minLength: 30)
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
                .foregroundColor(.white)
                .frame(width: 24)
            
            Text(title)
                .font(.body)
                .foregroundColor(.white)
        }
    }
}

struct CustomPricingCard: View {
    let title: String
    let price: String
    let weeklyEquivalent: String
    let freeTrialText: String
    let isSelected: Bool
    let showBadge: Bool
    let badgeText: String
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                VStack(spacing: 8) {
                    HStack {
                        // Left side - title and price
                        VStack(alignment: .leading, spacing: 4) {
                            Text(title)
                                .font(.title2)
                                .foregroundColor(.white)
                                .fontWeight(.regular)
                            
                            // Price - same size as free trial text but white
                            Text(price)
                                .font(.subheadline)
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        // Right side - weekly equivalent and free trial
                        VStack(alignment: .trailing, spacing: 4) {
                            // Weekly equivalent (only for yearly)
                            if !weeklyEquivalent.isEmpty {
                                Text(weeklyEquivalent)
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                            }
                            
                            // Free trial text - grey
                            Text(freeTrialText)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(isSelected ? 0.2 : 0.1))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color.white : Color.clear, lineWidth: 2)
                )
                
                // Badge - positioned to align with border
                if showBadge {
                    VStack {
                        HStack {
                            Spacer()
                            Text(badgeText)
                                .font(.caption.bold())
                                .foregroundColor(.black)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.white)
                                .cornerRadius(8)
                                .offset(x: -8, y: -8)
                        }
                        Spacer()
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// PricingPlan is defined in OnboardingPages.swift and used here

#Preview {
    PaywallView()
}
