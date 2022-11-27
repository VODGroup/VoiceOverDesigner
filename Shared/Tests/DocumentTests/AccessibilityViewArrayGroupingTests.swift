import XCTest
import Document

final class AccessibilityViewArrayGroupingTests: XCTestCase {
    
    var item1: A11yDescription!
    var item2: A11yDescription!
    var item3: A11yDescription!
    
    override func setUp() {
        super.setUp()
        
        item1 = A11yDescription.testMake()
        item2 = A11yDescription.testMake()
        item3 = A11yDescription.testMake()
    }
    
    func test_wrapSingleElementInContainer() throws {
        var array = [any AccessibilityView]()
        array.append(item1)
        
        array.wrapInContainer([item1], label: "Test")
        
        XCTAssertEqual(array.count, 1)
        let container = try XCTUnwrap(array.first as? A11yContainer)
        XCTAssertEqual(container.label, "Test")
        XCTAssertEqual(container.elements.count, 1)
    }
    
    func test_wrapTwoElementsInContainer() {
        var array = [any AccessibilityView]()
        array.append(item1)
        array.append(item2)

        array.wrapInContainer([item1, item2], label: "Test")

        XCTAssertEqual(array.count, 1)
        XCTAssertTrue(array.first is A11yContainer)
    }

    func test_wrapTwoElementsOfThree_shouldPlaceContainerToFirstPosition() {
        var array = [any AccessibilityView]()
        array.append(item1)
        array.append(item2)
        array.append(item3)

        array.wrapInContainer([item1, item2], label: "Test")

        XCTAssertEqual(array.count, 2)
        XCTAssertTrue(array.first is A11yContainer)
    }

    func test_wrapTwoElements_shouldUnionFrames() {
        let item1 = A11yDescription.testMake(
            frame: CGRect(x: 10, y: 10, width: 10, height: 10))
        let item2 = A11yDescription.testMake(
            frame: CGRect(x: 20, y: 20, width: 10, height: 10))
        var array = [any AccessibilityView]()
        array.append(item1)
        array.append(item2)

        array.wrapInContainer([item1, item2], label: "Test")

        XCTAssertTrue(array.first is A11yContainer)
        XCTAssertEqual(array.first?.frame,
                      CGRect(x: 10, y: 10, width: 20, height: 20))
    }
    
    // TODO: Index inside container
}
