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
    

}
