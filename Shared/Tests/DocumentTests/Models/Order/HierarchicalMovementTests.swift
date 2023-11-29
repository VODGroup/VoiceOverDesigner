import Document
import XCTest
import CustomDump
import DocumentTestHelpers

class HierarchicalMovementTests: XCTestCase {
    
    var sut: Artboard!
    var el1: A11yDescription!
    var el2: A11yDescription!
    var el3: A11yDescription!
    
    override func setUp() {
        super.setUp()
        
        el1 = A11yDescription.make(label: "1")
        el2 = A11yDescription.make(label: "2")
        el3 = A11yDescription.make(label: "3")
        
        sut = Artboard(frames: [], controlsWithoutFrames: [
            el1,
            el2,
            el3,
        ])
    }
    
    func test_simpleMove() {
        drag(el1, over: nil, insertionIndex: 2)
        
        sut.assert(labels: "2", "1", "3")
    }
    
    // MARK: - Inside container
    
    func test_correctDescription() {
        sut.wrapInContainer([el1], undoManager: nil)
        
        sut.assert(labels: "Container: 1", "2", "3")
    }
    
    func test_whenMove2IntoContainer_shouldMoveToContainer() {
        let container = wrap([el1])
        
        drag(el2, over: container, insertionIndex: 1)
        
        sut.assert(labels: "Container: 1, 2", "3")
    }
    
    // MARK: Outside containers
    
    func test_whenMove1OutOfContainer_shouldKeepContainerEmpty() {
        let container = wrap([el1])
        
        drag(el1, over: nil, insertionIndex: 1)
        
        sut.assert(labels: "Container", "1", "2", "3")
    }
    
    func test_whenMoveInSameContainer() {
        let container = wrap([el1, el2])
        
        drag(el1, over: container, insertionIndex: 2)
        
        sut.assert(labels: "Container: 2, 1", "3")
    }
    
    func test_whenMoveInSameContainerToBeginning() {
        let container = wrap([el1, el2])
        sut.assert(labels: "Container: 1, 2", "3")
        
        drag(el2, over: container, insertionIndex: 0)
        
        sut.assert(labels: "Container: 2, 1", "3")
    }
    
    func test_whenMoveFromOneContainerToAnother() {
        let container1 = wrap([el1])
        let container2 = wrap([el2])
        
        drag(el1, over: container2, insertionIndex: 0)

        sut.assert(labels: "Container", "Container: 1, 2", "3")
    }
    
    // MARK: - DSL
    @discardableResult
    func wrap(_ elements: [A11yDescription]) -> A11yContainer? {
        return sut.wrapInContainer(elements, undoManager: nil)
    }
    
    func drag(
        _ draggingElement: any ArtboardElement,
        over dropElement: (any ArtboardElement)?,
        insertionIndex: Int
    ) {
        _ = sut.drag(draggingElement, over: dropElement, insertionIndex: insertionIndex, undoManager: nil)
    }
}
