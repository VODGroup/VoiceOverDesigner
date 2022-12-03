import Document
import XCTest
@testable import TextUI
import CustomDump

class A11yDescriptionArrayTests: XCTestCase {
    
    var sut: [any AccessibilityView] = []
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

extension Array where Element == any AccessibilityView {
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
            case .container(let container):
                if container.elements.isEmpty {
                    return container.label
                }
                
                let elementsDescription = (container.elements as [any AccessibilityView])
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

class A11yDescriptionArrayMoveContainerTests: A11yDescriptionArrayTests {
    
    func test_simpleMove() {
        sut.move(el1, fromContainer: nil, toIndex: 2, toContainer: nil)
        sut.assert(labels: "2", "1", "3")
    }
    
    // MARK: - Inside containers
    
    func test_correctDescription() {
        sut.wrapInContainer([el1], label: "Container1")
        sut.assert(labels: "Container1: 1", "2", "3")
    }

    func test_whenMove2IntoContainer_shouldMoveToContainer() {
        let container = sut.wrapInContainer([el1], label: "Container1")
        
        sut.move(el2, fromContainer: nil,
                 toIndex: 1, toContainer: container!)
        
        sut.assert(labels: "Container1: 1, 2", "3")
    }
    
    // MARK: Outside containers
    
    func test_whenMove1OutOfContainer_shouldKeepContainerEmpty() {
        let container = sut.wrapInContainer([el1], label: "Container")
        
        sut.move(el1, fromContainer: container,
                 toIndex: 1, toContainer: nil)
        
        sut.assert(labels: "Container", "1", "2", "3")
    }
    
    func test_whenMoveInSameContainer() {
        let container = sut.wrapInContainer([el1, el2], label: "Container")
        
        sut.move(el1, fromContainer: container,
                 toIndex: 2, toContainer: container)
        
        sut.assert(labels: "Container: 2, 1", "3")
    }
    
    func test_whenMoveInSameContainerToBeginning() {
        let container = sut.wrapInContainer([el2, el1], label: "Container") // TODO: Strange that I should wrap in reverse order
        sut.assert(labels: "Container: 1, 2", "3")
        
        sut.move(el2, fromContainer: container,
                 toIndex: 0, toContainer: container)
        
        sut.assert(labels: "Container: 2, 1", "3")
    }
    
    func test_whenMoveFromOneContainerToAnother() {
        let container1 = sut.wrapInContainer([el1], label: "Container1")
        let container2 = sut.wrapInContainer([el2], label: "Container2")
        
        sut.move(el1, fromContainer: container1,
                 toIndex: 0, toContainer: container2)
        
        sut.assert(labels: "Container1", "Container2: 1, 2", "3")
    }
}

