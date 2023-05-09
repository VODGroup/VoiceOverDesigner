import XCTest
import Document

final class ArtboardElementArrayDeletionTests: XCTestCase {
    
    var item1: A11yDescription!
    var item2: A11yDescription!
    var item3: A11yDescription!
    var container1: A11yContainer!
    
    var array: [any ArtboardElement]!
    
    override func setUp() {
        super.setUp()
        
        item1 = A11yDescription.testMake()
        item2 = A11yDescription.testMake()
        item3 = A11yDescription.testMake()
    }
    
    func test_simple_element_deletion() throws {
        array = [item1, item2, item3]
        
        XCTAssertEqual(array.count, 3)
        array.delete(item1)
        XCTAssertEqual(array.count, 2)
    }
    
    
    func test_deletion_inside_container() throws {
        container1 = .testMake(elements: [item1, item2])
        array = [container1, item3]
        XCTAssertEqual(array.count, 2)
        
        array.delete(item1)
        XCTAssertEqual(container1.elements.count, 2, "delete only top-level objects for defined undoing")
        XCTAssertEqual(array.count, 2)
    }
    
    func test_container_deletion() throws {
        container1 = .testMake(elements: [item1, item2, item3])
        array = [container1]
        
        XCTAssertEqual(container1.elements.count, 3)
        XCTAssertEqual(array.count, 1)
        array.delete(container1)
        XCTAssertTrue(array.isEmpty)
    }
    
    func test_uncontained_deletion_not_change_array() throws {
        container1 = .testMake(elements: [item1, item2])
        array = [container1]
        
        XCTAssertEqual(container1.elements.count, 2)
        XCTAssertEqual(array.count, 1)
        array.delete(item3)
        XCTAssertEqual(array.count, 1)
    }
}
