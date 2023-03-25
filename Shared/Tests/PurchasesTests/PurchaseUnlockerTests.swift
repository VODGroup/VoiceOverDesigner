import XCTest
@testable import Purchases

class PurchaseUnlockerTests: XCTestCase {
    
    func test() async {
        let sut = PurchaseUnlocker()
        addTeardownBlock {
            sut.removePurchase(productId: .textRecognition)
        }
        
        XCTAssertFalse(sut.isUnlocked(productId: .textRecognition))
        await sut.unlock(productId: .textRecognition)
        
        XCTAssertTrue(sut.isUnlocked(productId: .textRecognition))
        
        // Another instance knows about saved data
        let sut2 = PurchaseUnlocker()
        XCTAssertTrue(sut2.isUnlocked(productId: .textRecognition))
    }
}
