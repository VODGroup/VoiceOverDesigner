import XCTest
@testable import Settings

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
