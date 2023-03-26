import Foundation

public class UnlockPresenter {
    
    enum PaymentError: Error {
        case canNotFetchProducts
    }
    
    let productId: ProductId
    let unlocker: PurchaseUnlocker
    let purchaseRepository: PurchaseRepository
    
    public init(
        productId: ProductId,
        unlockerDelegate: UnlockerDelegate
    ) {
        self.productId = productId
        
        let unlocker = PurchaseUnlocker()
        unlocker.delegate = unlockerDelegate
        self.unlocker = unlocker
        self.purchaseRepository = PurchaseRepository(unlocker: unlocker)
    }

    public func prefetch() {
        guard !unlocker.isUnlockedEverything else {
            return
        }
        
        Task {
            await purchaseRepository.listenForUpdates()
            try? await purchaseRepository.fetchProducts()
            
            await migrateAppPurchaseToFullUnlock()
        }
    }
    
    public func fetchProduct() async throws -> String {
        let product = try await purchaseRepository
            .product(id: productId)
        
        if let price = product?.displayPrice {
            return price
        } else {
            throw PaymentError.canNotFetchProducts
        }
    }
    
    public func purchase() async throws {
        guard let product = try await purchaseRepository.product(id: productId)
        else { return }
        
        try await purchaseRepository.purchase(product: product)
    }
    
    public func restore() async throws {
        try await purchaseRepository.restore()
    }
    
    public func isUnlocked() -> Bool {
        unlocker.isUnlocked(productId: productId)
    }
    
    private func migrateAppPurchaseToFullUnlock() async {
        if #available(macOS 13.0, *) {
            await purchaseRepository
                .migrateAppPurchaseToFullUnlock()
        }
    }
}
