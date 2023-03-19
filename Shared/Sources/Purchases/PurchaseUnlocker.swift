@MainActor
public protocol UnlockerDelegate: AnyObject {
    func didChangeUnlockStatus(productId: ProductId)
}

class PurchaseUnlocker {
    
    public weak var delegate: UnlockerDelegate?
    
    func unlock(productId: ProductId) async {
        print("will unlock \(productId)")
        isUnlocked = true // TODO: Use keychain
        
        await MainActor.run {
            delegate?.didChangeUnlockStatus(productId: productId)
        }
    }
    
    func isUnlocked(productId: ProductId) -> Bool {
        return isUnlocked // TODO: Check unlocker
    }
    
    var isUnlocked = false
}
