import XCTest
import Document

class A11yDescriptionArrayMoveTests: A11yDescriptionArrayTests {
    
    // MARK: Move first
    func test_move0_to0_shouldNotMove() {
        let didMove = sut.move(sut[0], to: 0)
        
        XCTAssertFalse(didMove)
        XCTAssertEqual(sut.map(\.label), ["1", "2", "3"])
    }
    
    func test_move0_to1_shouldNotMove() {
        let didMove = sut.move(sut[0], to: 1)
        
        XCTAssertFalse(didMove)
        XCTAssertEqual(sut.map(\.label), ["1", "2", "3"])
    }
    
    func test_move0_to2_shouldMove() {
        let didMove = sut.move(sut[0], to: 2)

        XCTAssertTrue(didMove)
        XCTAssertEqual(sut.map(\.label), ["2", "1", "3"])
    }

    func test_move0_to3_shouldMoveToLatest() {
        let didMove = sut.move(sut[0], to: 3)

        XCTAssertTrue(didMove)
        XCTAssertEqual(sut.map(\.label), ["2", "3", "1"])
    }

    // MARK: Move second
    func test_move1_to0_shouldMove() {
        let didMove = sut.move(sut[1], to: 0)

        XCTAssertTrue(didMove)
        XCTAssertEqual(sut.map(\.label), ["2", "1", "3"])
    }

    func test_move1_to1_shouldNotMove() {
        let didMove = sut.move(sut[1], to: 1)

        XCTAssertFalse(didMove)
        XCTAssertEqual(sut.map(\.label), ["1", "2", "3"])
    }

    func test_move1_to2_shouldNotMove() {
        let didMove = sut.move(sut[1], to: 2)

        XCTAssertFalse(didMove)
        XCTAssertEqual(sut.map(\.label), ["1", "2", "3"])
    }

    func test_move1_to3_shouldMove() {
        let didMove = sut.move(sut[1], to: 3)

        XCTAssertTrue(didMove)
        XCTAssertEqual(sut.map(\.label), ["1", "3", "2"])
    }
    
    // MARK: Move third
    
    func test_move2_to0_shouldMove() {
        let didMove = sut.move(sut[2], to: 0)
        
        XCTAssertTrue(didMove)
        XCTAssertEqual(sut.map(\.label), ["3", "1", "2"])
    }
    
    func test_move3_to1_shouldMove() {
        let didMove = sut.move(sut[2], to: 1)
        
        XCTAssertTrue(didMove)
        XCTAssertEqual(sut.map(\.label), ["1", "3", "2"])
    }
    
    func test_move2_to2_shouldNotMove() {
        let didMove = sut.move(sut[2], to: 2)
        
        XCTAssertFalse(didMove)
        XCTAssertEqual(sut.map(\.label), ["1", "2", "3"])
    }
    
    func test_move2_to3_shouldMove() {
        let didMove = sut.move(sut[2], to: 3)
        
        XCTAssertFalse(didMove)
        XCTAssertEqual(sut.map(\.label), ["1", "2", "3"])
    }
}
