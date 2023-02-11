import Foundation
import XCTest

class RelativeFrameTests: XCTestCase {
    func test() {
        let parent = CGRect(origin: .zero, size: CGSize(width: 100, height: 100))
        let child = CGRect(origin: CGPoint(x: 10, y: 10), size: CGSize(width: 20, height: 20))
//        let result = CGRect(origin: CGPoint(x: 10, y: 10), size: <#T##CGSize#>)
        XCTAssertEqual(child.relative(to: parent), child)
    }
}
