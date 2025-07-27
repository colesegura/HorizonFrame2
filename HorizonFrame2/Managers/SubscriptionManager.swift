import Foundation
import StoreKit

@MainActor
class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()
    
    @Published var isSubscribed = false
    @Published var currentSubscription: Product?
    @Published var availableProducts: [Product] = []
    
    // Product IDs - these should match your App Store Connect setup
    private let productIDs = [
        "com.horizonframe.yearly",
        "com.horizonframe.weekly"
    ]
    
    private init() {
        Task {
            await loadProducts()
            await checkSubscriptionStatus()
        }
    }
    
    // MARK: - Product Loading
    func loadProducts() async {
        do {
            let products = try await Product.products(for: productIDs)
            self.availableProducts = products.sorted { product1, product2 in
                // Sort yearly first
                if product1.id.contains("yearly") { return true }
                if product2.id.contains("yearly") { return false }
                return product1.price > product2.price
            }
        } catch {
            print("Failed to load products: \(error)")
        }
    }
    
    // MARK: - Purchase
    func purchase(_ product: Product) async -> Bool {
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    // Transaction is verified, grant access
                    await transaction.finish()
                    await checkSubscriptionStatus()
                    return true
                case .unverified:
                    // Transaction failed verification
                    return false
                }
            case .userCancelled:
                return false
            case .pending:
                // Transaction is pending (e.g., parental approval)
                return false
            @unknown default:
                return false
            }
        } catch {
            print("Purchase failed: \(error)")
            return false
        }
    }
    
    // MARK: - Subscription Status
    func checkSubscriptionStatus() async {
        for await result in Transaction.currentEntitlements {
            switch result {
            case .verified(let transaction):
                if productIDs.contains(transaction.productID) {
                    self.isSubscribed = true
                    // Find the current product
                    self.currentSubscription = availableProducts.first { $0.id == transaction.productID }
                    return
                }
            case .unverified:
                break
            }
        }
        self.isSubscribed = false
        self.currentSubscription = nil
    }
    
    // MARK: - Restore Purchases
    func restorePurchases() async {
        try? await AppStore.sync()
        await checkSubscriptionStatus()
    }
    
    // MARK: - Subscription Management
    func manageSubscriptions() async {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            try? await AppStore.showManageSubscriptions(in: windowScene)
        }
    }
}

// MARK: - Product Extensions
extension Product {
    var formattedPrice: String {
        return self.displayPrice
    }
    
    var isYearly: Bool {
        return id.contains("yearly")
    }
    
    var isWeekly: Bool {
        return id.contains("weekly")
    }
}
