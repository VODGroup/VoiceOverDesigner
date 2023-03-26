@MainActor
public protocol UnlockerDelegate: AnyObject {
    func didChangeUnlockStatus(productId: ProductId)
}

import Document
class PurchaseUnlocker {
    
    let keychain = Keychain()
    public weak var delegate: UnlockerDelegate?
    
    func unlock(productId: ProductId) async {
        print("will unlock \(productId)")
        keychain.save(true, for: productId.rawValue)
        
        await delegate?.didChangeUnlockStatus(productId: productId)
    }
    
    func unlockEverything() async {
        for product in ProductId.allCases {
            await unlock(productId: product)
        }
    }
    
    func isUnlocked(productId: ProductId) -> Bool {
        keychain.readValue(for: productId.rawValue) ?? false
    }
    
    func removePurchase(productId: ProductId) {
        keychain.remove(key: productId.rawValue)
    }
    
    @KeychainBool(key: ProductId.textRecognition.rawValue)
    private var isTextRecognitionUnlocked
}
