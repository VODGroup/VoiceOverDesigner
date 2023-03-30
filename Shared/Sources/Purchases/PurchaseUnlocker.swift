@MainActor
public protocol PurchaseUnlockerDelegate: AnyObject {
    func didChangeUnlockStatus(productId: ProductId)
}

class PurchaseUnlocker {
    
    let userDefaults = UserDefaults()
    
    public weak var delegate: PurchaseUnlockerDelegate?
    
    func unlock(productId: ProductId) async {
        print("will unlock \(productId)")
        userDefaults.unlock(productId: productId)
        
        await delegate?.didChangeUnlockStatus(productId: productId)
    }
    
    func unlockEverything() async {
        for product in ProductId.allCases {
            await unlock(productId: product)
        }
    }
    
    func isUnlocked(productId: ProductId) -> Bool {
        userDefaults.isUnlocked(productId: productId)
    }
    
    func removePurchase(productId: ProductId) {
        userDefaults.remove(productId: productId)
    }
    
    lazy var isUnlockedEverything: Bool = {
        for productId in ProductId.allCases {
            let isUnlocked = userDefaults.isUnlocked(productId: productId)
            
            if !isUnlocked {
                return false
            }
        }
        
        return true
    }()
}

import Foundation
extension UserDefaults {
    func isUnlocked(productId: ProductId) -> Bool {
        bool(forKey: productId.rawValue)
    }
    
    func unlock(productId: ProductId) {
        set(true, forKey: productId.rawValue)
    }
    
    func remove(productId: ProductId) {
        removeObject(forKey: productId.rawValue)
    }
}
