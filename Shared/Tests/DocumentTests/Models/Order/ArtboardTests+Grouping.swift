import XCTest
import Document
import Artboard

final class ArtboardTests_Grouping: XCTestCase {
    
    var item1: A11yDescription!
    var item2: A11yDescription!
    var item3: A11yDescription!
    
    var elements: [any ArtboardElement]! {
        set {
            artboard = Artboard(elements: newValue)
        }
        
        get {
            artboard.elements
        }
    }
    
    var artboard: Artboard!
    
    override func setUp() {
        super.setUp()
        
        item1 = A11yDescription.testMake(label: "1")
        item2 = A11yDescription.testMake(label: "2")
        item3 = A11yDescription.testMake(label: "3")
    }
    
    func wrap(_ elements: [A11yDescription], label: String = "Test") {
        artboard.wrapInContainer(elements, dropElement: nil, undoManager: nil)
    }
    
    func test_wrapSingleElementInContainer() throws {
        elements = [item1]
        
        wrap([item1])
        
        artboard.assert {
"""
Container:
 1
"""
        }
    }
    
    func test_wrapTwoElementsInContainer() {
        elements = [item1, item2]
        
        wrap([item1, item2])
        
        artboard.assert {
"""
Container:
 1
 2
"""
        }
    }

    func test_wrapTwoElementsOfThree_shouldPlaceContainerToFirstPosition() {
        elements = [item1, item2, item3]
        
        wrap([item1, item2])
        
        artboard.assert {
"""
Container:
 1
 2
3
"""
        }
    }
        
    
    func test_wrapTwoLastElementsOfThree_shouldPlaceContainerToSecondPosition() {
        elements = [item1, item2, item3]
        
        wrap([item2, item3])
        
        artboard.assert {
"""
1
Container:
 2
 3
"""
        }
    }
    
    // MARK: - Containers
    func test_wrapElementFromOneContainer_shouldMoveItFromContainer() throws {
        elements = [item1, A11yContainer(elements: [item2, item3], frame: .zero, label: "Test")]
        
        wrap([item1, item2], label: "Test")
        
        artboard.assert {
"""
Container:
 1
 2
Test:
 3
"""
        }
    }
    
    func test_whenExtractLastElementFromContainer_shouldRemoveContainer() throws {
        elements = [item1, A11yContainer(elements: [item2, item3], frame: .zero, label: "Test")]
        
        wrap([item1, item2, item3],
             label: "Test2")
        
        artboard.assert {
"""
Container:
 1
 2
 3
"""
        }
    }
    
    func test_unwrapContainer_addsElementsCorrectly_andRemovesContainer() throws {
        
        let container: A11yContainer = .testMake(elements: [item2, item3])
        
        elements = [item1, container]
        XCTAssertEqual(elements.count, 2)
        artboard.unwrapContainer(container)
        
        artboard.assert {
"""
1
3
2
"""
        }
    }
    
    // MARK: - Frame
    func test_wrapTwoElements_shouldUnionFrames() {
        let item1 = A11yDescription.testMake(
            frame: CGRect(x: 10, y: 10, width: 10, height: 10))
        let item2 = A11yDescription.testMake(
            frame: CGRect(x: 20, y: 20, width: 10, height: 10))
        elements = [item1, item2]

        wrap([item1, item2])

        XCTAssertTrue(elements.first is A11yContainer)
        let uninFrame = CGRect(x: 10, y: 10, width: 20, height: 20)
        XCTAssertEqual(elements.first?.frame,
                       uninFrame.insetBy(dx: -20, dy: -20))
    }
}

class A11yContainerTest: XCTestCase {
    
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
