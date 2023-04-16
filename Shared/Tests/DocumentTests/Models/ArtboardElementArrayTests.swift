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
        var array = [any ArtboardElement]()
        array.append(A11yContainer(elements: [.testMake(), .testMake()],
                                   frame: .zero, label: "TestName"))
        
        let extracted = array.extractElements()
        XCTAssertEqual(extracted.count, 2)
    }
}
