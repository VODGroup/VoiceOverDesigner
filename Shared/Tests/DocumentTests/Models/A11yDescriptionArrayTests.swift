import Document
import XCTest
import CustomDump

class A11yDescriptionArrayTests: XCTestCase {
    
    var sut: [any ArtboardElement] = []
    var el1: A11yDescription!
    var el2: A11yDescription!
    var el3: A11yDescription!
    
    override func setUp() {
        super.setUp()
        
        el1 = A11yDescription.make(label: "1")
        el2 = A11yDescription.make(label: "2")
        el3 = A11yDescription.make(label: "3")
        
        sut = [
            el1,
            el2,
            el3,
        ]
    }
}

extension Array where Element == any ArtboardElement {
    func assert(
        labels: String...,
        file: StaticString = #file, line: UInt = #line
    ) {
        XCTAssertNoDifference(recursiveDescription(),
                              labels,
                              file: file, line: line)
    }
    
    func recursiveDescription() -> [String] {
        map { view in
            switch view.cast {
            case .frame(let frame):
                return frame.label // TODO: Make full description
            case .container(let container):
                if container.elements.isEmpty {
                    return container.label
                }
                
                let elementsDescription = (container.elements as [any ArtboardElement])
                    .recursiveDescription()
                    .joined(separator: ", ")
                return "\(container.label): \(elementsDescription)"
            case .element(let element):
                return element.label
            }
        }
    }
}

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

// TODO: Remove duplicate
extension A11yDescription {
    static func make(label: String) -> A11yDescription {
        A11yDescription(
            isAccessibilityElement: true,
            label: label,
            value: "",
            hint: "",
            trait: [],
            frame: .zero,
            adjustableOptions: AdjustableOptions(options: []),
            customActions: A11yCustomActions(names: [])
        )
    }
}
