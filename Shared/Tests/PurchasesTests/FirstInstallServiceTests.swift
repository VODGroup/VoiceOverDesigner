import XCTest
@testable import Purchases

@available(macOS 13.0, *)
class FirstInstallServiceTests: XCTestCase {
    
    func test_1_0_shouldBePaid() {
        let sut = FirstInstallService()
        let isPaid = sut.isPaidPurchase(originalAppVersion: "1.0")
        XCTAssertTrue(isPaid)
    }
    func test_1_1_shouldBeFree() {
        let sut = FirstInstallService()
        let isPaid = sut.isPaidPurchase(originalAppVersion: "1.1")
        XCTAssertFalse(isPaid)
    }
}

