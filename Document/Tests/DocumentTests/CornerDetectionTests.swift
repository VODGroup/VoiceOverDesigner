@testable import Document
import XCTest

class CornerDetectionTests: XCTestCase {
    
    let rect = CGRect(origin: .zero, size: CGSize.side(10))
    
    func test_topLeftCorner_shouldNowAllowResize() {
        let point = CGPoint.zero
        
        XCTAssertFalse(point.nearBottomRightCorner(of: rect))
    }
    
    func test_exactCornerPoint_shouldAllowResize() {
        let point = CGPoint(x: 10, y: 10)
        
        XCTAssertTrue(point.nearBottomRightCorner(of: rect))
    }
}
