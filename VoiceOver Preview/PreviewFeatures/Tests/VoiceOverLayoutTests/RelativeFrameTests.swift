import Foundation
import XCTest
@testable import VoiceOverLayout

class RelativeFrameTests: XCTestCase {
    func test() {
        let parent = CGRect(origin: .zero, size: CGSize(width: 100, height: 100))
        let child = CGRect(origin: CGPoint(x: 10, y: 10), size: CGSize(width: 20, height: 20))
        XCTAssertEqual(child.relative(to: parent), child)
    }
    
    func test2() {
        let parent = CGRect(origin: CGPoint(x: 10, y: 10), size: CGSize(width: 100, height: 100))
        let child = CGRect(origin: CGPoint(x: 20, y: 20), size: CGSize(width: 20, height: 20))
        let result = CGRect(origin: CGPoint(x: 10, y: 10), size: CGSize(width: 20, height: 20))
        XCTAssertEqual(child.relative(to: parent), result)
    }
}
