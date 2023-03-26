import XCTest
@testable import Purchases

class PurchaseUnlockerTests: XCTestCase {
    
    var sut: PurchaseUnlocker!
    override func setUp() {
        super.setUp()
        
        sut = PurchaseUnlocker()
        
        sut.removePurchase(productId: .textRecognition)
        XCTAssertFalse(sut.isUnlocked(productId: .textRecognition))
    }
    
    func test_whenUnlockPurchase_shouldKeepStateAfterRelaunch() async {
        await sut.unlock(productId: .textRecognition)
        XCTAssertTrue(sut.isUnlocked(productId: .textRecognition))
        
        // Another instance knows about saved data
        let sut2 = PurchaseUnlocker()
        XCTAssertTrue(sut2.isUnlocked(productId: .textRecognition))
    }
}
