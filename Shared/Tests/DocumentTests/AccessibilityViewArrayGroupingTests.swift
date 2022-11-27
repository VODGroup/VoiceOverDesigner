import XCTest
import Document

final class AccessibilityViewArrayGroupingTests: XCTestCase {
    
    func test_wrapSingleElementInContainer() {
        var array = [any AccessibilityView]()
        array.append(A11yDescription.testMake())
        
        array.wrapInContainer(indexes: [0])
        
        XCTAssertEqual(array.count, 1)
        XCTAssertTrue(array.first is A11yContainer)
    }
    
    func test_wrapTwoElementsInContainer() {
        var array = [any AccessibilityView]()
        array.append(A11yDescription.testMake())
        array.append(A11yDescription.testMake())
        
        array.wrapInContainer(indexes: [0, 1])
        
        XCTAssertEqual(array.count, 1)
        XCTAssertTrue(array.first is A11yContainer)
    }
    
    func test_wrapTwoElementsOfThree_shouldPlaceContainerToFirstPosition() {
        var array = [any AccessibilityView]()
        array.append(A11yDescription.testMake())
        array.append(A11yDescription.testMake())
        array.append(A11yDescription.testMake())
        
        array.wrapInContainer(indexes: [0, 1])
        
        XCTAssertEqual(array.count, 2)
        XCTAssertTrue(array.first is A11yContainer)
    }
    
    func test_wrapTwoElements_shouldUnionFrames() {
        var array = [any AccessibilityView]()
        array.append(A11yDescription.testMake(
            frame: CGRect(x: 10, y: 10, width: 10, height: 10)))
        array.append(A11yDescription.testMake(
            frame: CGRect(x: 20, y: 20, width: 10, height: 10)))
        
        array.wrapInContainer(indexes: [0, 1])
        
        XCTAssertTrue(array.first is A11yContainer)
        XCTAssertEqual(array.first?.frame,
                      CGRect(x: 10, y: 10, width: 20, height: 20))
    }
    
    // TODO: Index inside container
}
