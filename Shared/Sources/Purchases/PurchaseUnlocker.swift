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
    
    func isUnlocked(productId: ProductId) -> Bool {
        return isTextRecognitionUnlocked
    }
    
    @Storage(key: "isTextRecognitionUnlocked", defaultValue: false) // TODO: Define default value by first install
    var isTextRecognitionUnlocked
}
