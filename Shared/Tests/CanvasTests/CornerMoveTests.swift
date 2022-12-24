@testable import Canvas
import XCTest

class CornerMoveTests: XCTestCase {
    let rect = CGRect(origin: .zero, size: CGSize.side(10))
    
    func test_moveTopLeftCorner_shouldInvreaseSize() {
        rect
            .move(corner: .topLeft, to: CGPoint(x: -5, y: -10))
            .assertEqual(CGRect(x: -5, y: -10, width: 15, height: 20))
    }
    
    func test_moveTopRightCorner() {
        rect
            .move(corner: .topRight, to: CGPoint(x: 15, y: -5))
            .assertEqual(CGRect(x: 0, y: -5, width: 15, height: 15))
    }
    
    func test_moveBottomRightCorner_shouldInvreaseSize() {
        rect
            .move(corner: .bottomRight, to: CGPoint(x: 20, y: 20))
            .assertEqual(CGRect(x: 0, y: 0, width: 20, height: 20))
    }
    
    func test_moveBottomRightCorner_shouldDecreaseSize() {
        rect
            .move(corner: .bottomRight, to: CGPoint(x: 5, y: 5))
            .assertEqual(CGRect(x: 0, y: 0, width: 5, height: 5))
    }
    
    func test_moveBottomLeftCorner_shouldInvreaseSize() {
        rect
            .move(corner: .bottomLeft, to: CGPoint(x: -5, y: 15))
            .assertEqual(CGRect(x: -5, y: 0, width: 15, height: 15))
    }
}

extension CGRect {
    func assertEqual(_ expected: Self,
                     file: StaticString = #file,
                     line: UInt = #line) {
        XCTAssertEqual(self, expected, file: file, line: line)
    }
}
