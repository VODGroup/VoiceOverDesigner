import XCTest
import Document

final class ArtboardElementArrayTests: XCTestCase {
    
    func test_onlyElements_shouldExtactAllOfThem() {
        var array = [any ArtboardElement]()
        array.append(A11yDescription.testMake())
        array.append(A11yDescription.testMake())
        
        let extracted = array.extractElements()
        XCTAssertEqual(extracted.count, 2)
    }
    
    func testExample() throws {
        let container = A11yContainer(elements: [A11yDescription.testMake(),
                                                 A11yDescription.testMake()],
                                      frame: .zero,
                                      label: "TestName")
        
        var array = [any ArtboardElement]()
        array.append(container)
        
        let extracted = array.extractElements()
        XCTAssertEqual(extracted.count, 2)
    }
}
