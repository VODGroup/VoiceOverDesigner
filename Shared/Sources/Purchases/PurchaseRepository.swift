import StoreKit

public enum ProductId: String, CaseIterable {
    case textRecognition = "com.akaDuality.VoiceOverDesigner.TextRecognition"
    
    static var allIdentifiers: [String] {
        ProductId.allCases.map(\.rawValue)
    }
}

/// https://developer.apple.com/help/app-store-connect/configure-in-app-purchase-settings/overview-for-configuring-in-app-purchases
/// https://developer.apple.com/documentation/storekit/in-app_purchase/original_api_for_in-app_purchase/offering_completing_and_restoring_in-app_purchases
/// https://wwdcbysundell.com/2021/working-with-in-app-purchases-in-storekit2/
actor PurchaseRepository {
    
    private let unlocker: PurchaseUnlocker
    
    init(unlocker: PurchaseUnlocker) {
        self.unlocker = unlocker
    }
    
    deinit {
        // Cancel the update handling task when you deinitialize the class.
        updates?.cancel()
    }
    
    /// Call it on app's start
    private var updates: Task<Void, Never>? = nil
    func listenForUpdates() {
        updates = newTransactionListenerTask()
    }
    
    private func newTransactionListenerTask() -> Task<Void, Never> {
        Task(priority: .background) {
            for await verificationResult in Transaction.updates {
                Task { // TODO: It's strange to wrap to another task
                    await unlockAndFinish(try verificationResult.payloadValue)
                }
            }
        }
    }
    
    // MARK: - Fetch
    var products: [Product] = []
    
    func product(id: ProductId) async throws -> Product? {
        if products.isEmpty {
            try await fetchProducts()
        }
        
        let product = products.first { product in
            product.id == id.rawValue
        }
        
        return product
    }
    
    func fetchProducts() async throws {
        products = try await Product
            .products(for: ProductId.allIdentifiers)
    }
    
    // MARK: - Purchase
    func purchase(product: Product) async throws {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verificationResult):
            await unlockAndFinish(try verificationResult.payloadValue)
        case .pending:
            break // TODO: What to do here? Not our case, probably.  https://developer.apple.com/documentation/storekit/transaction/3851206-updates
        case .userCancelled:
            break
        @unknown default:
            break
        }
    }
    
    private func unlockAndFinish(_ transaction: Transaction) async {
        guard let productId = ProductId(rawValue: transaction.productID) else { return }
        guard transaction.revocationDate == nil else { return } // Do not restore revoked transactions
        
        await unlocker.unlock(productId: productId)
        
        await transaction.finish()
    }
    
    // MARK: - Restore
    func restore() async throws {
        if #available(macOS 13.0, *) {
            Task {
                migrateAppPurchaseToFullUnlock()
            }
        }
        
        for await verification in Transaction.currentEntitlements {
            if case let .verified(transaction) = verification {
                print("Found transaction to restore \(transaction.productID)")
                await unlockAndFinish(transaction)
            }
        }
    }
    
    @available(macOS 13.0, *)
    func migrateAppPurchaseToFullUnlock() {
        Task {
            if try await FirstInstallService().isGreatPersonWhoBoughtOurAppFirst() {
                await unlocker.unlockEverything()
            }
        }
    }
    
    // TODO: call it somewhere
    var isAuthorizedForPayments: Bool {
        return SKPaymentQueue.canMakePayments()
    }
}
