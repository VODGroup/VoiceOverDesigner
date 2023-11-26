import XCTest
import Document
import Artboard

final class GroupingTests: XCTestCase {
    
    var item1: A11yDescription!
    var item2: A11yDescription!
    var item3: A11yDescription!
    
    var array: [any ArtboardElement]!
    
    override func setUp() {
        super.setUp()
        
        item1 = A11yDescription.testMake()
        item2 = A11yDescription.testMake()
        item3 = A11yDescription.testMake()
    }
    
    func wrap(_ elements: [A11yDescription], label: String = "Test") {
        array.wrap(in: A11yContainer.self, elements, label: label)
    }
    
    func test_wrapSingleElementInContainer() throws {
        array = [item1]
        
        wrap([item1])
        
        XCTAssertEqual(array.count, 1)
        let container = try XCTUnwrap(array.first as? A11yContainer)
        XCTAssertEqual(container.label, "Test")
        XCTAssertEqual(container.elements.count, 1)
    }
    
    func test_wrapTwoElementsInContainer() {
        array = [item1, item2]

        wrap([item1, item2])

        XCTAssertEqual(array.count, 1)
        XCTAssertTrue(array.first is A11yContainer)
    }

    func test_wrapTwoElementsOfThree_shouldPlaceContainerToFirstPosition() {
        array = [item1, item2, item3]

        wrap([item1, item2])

        XCTAssertEqual(array.count, 2)
        XCTAssertTrue(array.first is A11yContainer)
    }
    
    func test_wrapTwoLastElementsOfThree_shouldPlaceContainerToSecondPosition() {
        array = [item1, item2, item3]
        
        wrap([item2, item3])
        
        XCTAssertEqual(array.count, 2)
        XCTAssertFalse(array.first is A11yContainer)
        XCTAssertTrue(array.last is A11yContainer)
    }
    
    // MARK: - Containers
    func test_wrapElementFromOneContainer_shouldMoveItFromContainer() throws {
        array = [item1, A11yContainer(elements: [item2, item3], frame: .zero, label: "Test")]
        
        wrap([item1, item2], label: "Test")
        
        XCTAssertEqual(array.count, 2)
        let container1 = try XCTUnwrap(array.first as? A11yContainer)
        XCTAssertEqual(container1.controls, [item1, item2])
        
        let container2 = try XCTUnwrap(array.last as? A11yContainer)
        XCTAssertEqual(container2.controls, [item3])
    }
    
    func test_whenExtractLastElementFromContainer_shouldRemoveContainer() throws {
        array = [item1, A11yContainer(elements: [item2, item3], frame: .zero, label: "Test")]
        
        wrap([item1, item2, item3],
             label: "Test2")
        
        XCTAssertEqual(array.count, 1)
        let container1 = try XCTUnwrap(array.first as? A11yContainer)
        XCTAssertEqual(container1.controls, [item1, item2, item3])
    }
    
    func test_unwrapContainer_addsElementsCorrectly_andRemovesContainer() throws {
        
        let container: A11yContainer = .testMake(elements: [item2, item3])
        
        array = [item1, container]
        XCTAssertEqual(array.count, 2)
        array.unwrapContainer(container)
        
        XCTAssertEqual(array.count, 3)
        XCTAssertEqual(array[1] as? A11yDescription, item3)
        XCTAssertEqual(array[2] as? A11yDescription, item2)
        
        XCTAssertFalse(array.contains(where: {
            $0 === container
        }))
    }
    
    // MARK: - Frame
    func test_wrapTwoElements_shouldUnionFrames() {
        let item1 = A11yDescription.testMake(
            frame: CGRect(x: 10, y: 10, width: 10, height: 10))
        let item2 = A11yDescription.testMake(
            frame: CGRect(x: 20, y: 20, width: 10, height: 10))
        array = [item1, item2]

        wrap([item1, item2])

        XCTAssertTrue(array.first is A11yContainer)
        let uninFrame = CGRect(x: 10, y: 10, width: 20, height: 20)
        XCTAssertEqual(array.first?.frame,
                       uninFrame.insetBy(dx: -20, dy: -20))
    }
}

class A11YContainerTest: XCTestCase {
    
    func test_containerWithSingleButton_cantTraitAsAdjustable() {
        let container = A11yContainer.testMake(
            elements: [
                .testMake(label: "Small", trait: .button),
            ], label: "Size")
        
        XCTAssertFalse(container.canTraitAsAdjustable)
        
        container.treatButtonsAsAdjustable = true
        XCTAssertFalse(container.canTraitAsAdjustable, "No affect")
        
        let proxy = container.adjustableProxy
        XCTAssertNil(proxy)
    }
    
    func test_containerHas3Buttons_whenTraitAsAdjustable_shouldGenerateProxyWith3Options() {
        let container = A11yContainer.testMake(
            elements: [
                .testMake(label: "Small", trait: .button),
                .testMake(label: "Middle", trait: .button),
                .testMake(label: "Large", trait: .button),
            ], label: "Size")
        
        container.treatButtonsAsAdjustable = true
        
        let proxy = container.adjustableProxy
        XCTAssertNotNil(proxy)
        
        XCTAssertEqual(proxy?.adjustableOptions.options.count, 3)
        XCTAssertEqual(proxy?.adjustableOptions.currentIndex, 0)
    }
}
