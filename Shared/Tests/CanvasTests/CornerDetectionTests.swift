@testable import Canvas
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

class CornerMoveTests: XCTestCase {
    let rect = CGRect(origin: .zero, size: CGSize.side(10))
    
    func test_moveTopRightCorner_shouldDecreaseSize() {
        let actualFrame = rect.move(corner: .topRight, to: CGPoint(x: 20, y: 20))
        let expectedFrame = CGRect(x: 0, y: 0, width: 20, height: 20)
        XCTAssertEqual(actualFrame, expectedFrame)
    }
    
    func test_moveTopRightCorner_shouldInvreaseSize() {
        let actualFrame = rect.move(corner: .topRight, to: CGPoint(x: 5, y: 5))
        let expectedFrame = CGRect(x: 0, y: 0, width: 5, height: 5)
        XCTAssertEqual(actualFrame, expectedFrame)
    }
    
    func test_moveTopLeftCorner_shouldInvreaseSize() {
        let actualFrame = rect.move(corner: .topLeft, to: CGPoint(x: -5, y: -5))
        let expectedFrame = CGRect(x: -5, y: -5, width: 15, height: 15)
        XCTAssertEqual(actualFrame, expectedFrame)
    }
}
