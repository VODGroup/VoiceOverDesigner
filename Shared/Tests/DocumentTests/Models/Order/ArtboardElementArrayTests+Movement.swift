import XCTest
import Document

class ArtboardElementArrayTests_Movement: XCTestCase {
    
    var sut: [A11yDescription]!
    var el1: A11yDescription!
    var el2: A11yDescription!
    var el3: A11yDescription!
    
    override func setUp() {
        super.setUp()
        
        el1 = A11yDescription.make(label: "1")
        el2 = A11yDescription.make(label: "2")
        el3 = A11yDescription.make(label: "3")
        
        sut = [el1, el2, el3]
    }
    
    func assertLabels(_ labels: String..., file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(sut.map(\.label), labels, file: file, line: line)
    }
    
    // MARK: Move first
    func test_move0_to0_shouldNotMove() {
        let didMove = sut.move(sut[0], to: 0)
        
        XCTAssertFalse(didMove)
        assertLabels("1", "2", "3")
    }
    
    func test_move0_to1_shouldNotMove() {
        let didMove = sut.move(sut[0], to: 1)
        
        XCTAssertFalse(didMove)
        assertLabels("1", "2", "3")
    }
    
    func test_move0_to2_shouldMove() {
        let didMove = sut.move(sut[0], to: 2)

        XCTAssertTrue(didMove)
        assertLabels("2", "1", "3")
    }

    func test_move0_to3_shouldMoveToLatest() {
        let didMove = sut.move(sut[0], to: 3)

        XCTAssertTrue(didMove)
        assertLabels("2", "3", "1")
    }

    // MARK: Move second
    func test_move1_to0_shouldMove() {
        let didMove = sut.move(sut[1], to: 0)

        XCTAssertTrue(didMove)
        assertLabels("2", "1", "3")
    }

    func test_move1_to1_shouldNotMove() {
        let didMove = sut.move(sut[1], to: 1)

        XCTAssertFalse(didMove)
        assertLabels("1", "2", "3")
    }

    func test_move1_to2_shouldNotMove() {
        let didMove = sut.move(sut[1], to: 2)

        XCTAssertFalse(didMove)
        assertLabels("1", "2", "3")
    }

    func test_move1_to3_shouldMove() {
        let didMove = sut.move(sut[1], to: 3)

        XCTAssertTrue(didMove)
        assertLabels("1", "3", "2")
    }
    
    // MARK: Move third
    
    func test_move2_to0_shouldMove() {
        let didMove = sut.move(sut[2], to: 0)
        
        XCTAssertTrue(didMove)
        assertLabels("3", "1", "2")
    }
    
    func test_move3_to1_shouldMove() {
        let didMove = sut.move(sut[2], to: 1)
        
        XCTAssertTrue(didMove)
        assertLabels("1", "3", "2")
    }
    
    func test_move2_to2_shouldNotMove() {
        let didMove = sut.move(sut[2], to: 2)
        
        XCTAssertFalse(didMove)
        assertLabels("1", "2", "3")
    }
    
    func test_move2_to3_shouldMove() {
        let didMove = sut.move(sut[2], to: 3)
        
        XCTAssertFalse(didMove)
        assertLabels("1", "2", "3")
    }
}
