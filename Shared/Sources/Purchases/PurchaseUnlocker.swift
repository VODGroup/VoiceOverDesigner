@MainActor
public protocol UnlockerDelegate: AnyObject {
    func didChangeUnlockStatus(productId: ProductId)
}

import Document
class PurchaseUnlocker {
    
    public weak var delegate: UnlockerDelegate?
    
    func unlock(productId: ProductId) async {
        print("will unlock \(productId)")
        isTextRecognitionUnlocked = true
        
        await delegate?.didChangeUnlockStatus(productId: productId)
    }
    
    func unlockEverything() async {
        for product in ProductId.allCases {
            await unlock(productId: product)
        }
    }
    
    func isUnlocked(productId: ProductId) -> Bool {
        switch productId {
        case .textRecognition:
            return isTextRecognitionUnlocked
        }
    }
    
    func removePurchase(productId: ProductId) {
        isTextRecognitionUnlocked = false
    }
    
    @KeychainBool(key: "isTextRecognitionUnlocked")
    private var isTextRecognitionUnlocked
}
