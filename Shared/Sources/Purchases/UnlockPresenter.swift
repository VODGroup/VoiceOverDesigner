//
//  File.swift
//  
//
//  Created by Mikhail Rubanov on 19.03.2023.
//

import Foundation

public class UnlockPresenter {
    
    enum PaymentError: Error {
        case canNotFetchProducts
    }
    
    let productId: ProductId
    let unlocker: PurchaseUnlocker
    let purchaseRepository: PurchaseRepository
    
    public init(productId: ProductId, unlockerDelegate: UnlockerDelegate) {
        self.productId = productId
        
        let unlocker = PurchaseUnlocker()
        unlocker.delegate = unlockerDelegate
        self.unlocker = unlocker
        self.purchaseRepository = PurchaseRepository(unlocker: unlocker)
    }
    
    public func isUnlocked() -> Bool {
        unlocker.isUnlocked(productId: productId)
    }
    
    public func fetchProduct() async throws -> String {
        await purchaseRepository.listenForUpdates()
        
        let product = try await purchaseRepository.product(id: productId)
        
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
}
