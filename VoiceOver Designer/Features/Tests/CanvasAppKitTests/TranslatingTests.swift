import XCTest
@testable import Canvas
import Document

@MainActor
class TranslatingTests: CanvasAfterDidLoadTests {
    
    // MARK: Editing
    func test_movementFor5px_shouldTranslateRect() async throws {
        drawRect_10_60()
        
        drag(15, 17, 18, 20) // 5px from start
        
        XCTAssertEqual(drawnControls.count, 1)
        XCTAssertEqual(drawnControls.first?.frame,
                       rect10to50.offsetBy(dx: 5, dy: 5))
        
        let selected = try await awaitSelected()
        XCTAssertNil(selected, "should not select after translation")
    }
    
    func test_translateToNegativeCoordinates_shouldTranslate() async throws {
        drawRect_10_60()
        move(from: .coord(15), to: .coord(5))
        
        XCTAssertEqual(drawnControls.first?.frame,
                       rect10to50.offsetBy(dx: -10, dy: -10))
        
        let selected = try await awaitSelected()
        XCTAssertNotNil(selected, "should select after translation")
    }
    
    func test_whenMoveNearLeftEdgeOnAnyElement_shouldPinToLeftEdge() throws {
        drawRect(from: start10, to: end60)
        drawRect(from: .coord(200),
                 to: .coord(300))
        XCTAssertEqual(drawnControls.count, 2)
        
        let resizingOffset = (Config().resizeMarkerSize / 3)
        sut.mouseDown(on: .coord(200+resizingOffset)) // 2nd rect
        sut.mouseDragged(on: .coord(10+1))
        
        XCTAssertEqual(drawnControls.count, 2, "not draw new element")
        XCTAssertEqual(drawnControls[1].frame,
                       CGRect(origin: .coord(10), size: .side(290)))
    }
    
    // TODO:
    // - aligned vertically
    // - aligned to 3rd element
    
    func test_whenCopyControl_shouldDraw2ndControl() {
        drawRect_10_60()
        
        copy(from: .coord(15), to: .coord(15+35))
        
        XCTAssertEqual(drawnControls.count, 2)
        XCTAssert(documentControls[0] !== documentControls[1], "create another instance")
        XCTAssertEqual(
            documentControls[1].frame,
            rect10to50.offsetBy(dx: 35, dy: 35))
    }
    
    @MainActor
    func test_whenCopyControl_shouldSelectCopy() async throws {
        drawRect_10_60()
        
        copy(from: .coord(15), to: .coord(15+35))
        
        let selected = try await awaitSelected() as! A11yDescription
        XCTAssertEqual(selected, documentControls[1] as! A11yDescription)
    }
    
    func test_copyControl_whenUndo_shouldRemoveCopy(){
        sut.disableUndoRegistration()
        drawRect_10_60()
        sut.enableUndoRegistration()
        
        copy(from: .coord(15), to: .coord(15+35))
        
        // Undo
        sut.document.undo?.undo()
        XCTAssertEqual(drawnControls.count, 1, "should remove copy")
    }
    
    // MARK: Containers
    private func createContainerWithElement10_60() throws -> (A11yDescription, A11yContainer?) {
        sut.disableUndoRegistration()
        let element = try drawElement(from: start10, to: end60)
        let container = wrapInContainer([element])
        sut.enableUndoRegistration()
        
        return (element, container)
    }
    
    func test_whenMoveContainer_shouldMoveContainer() throws {
        let (_, container) = try createContainerWithElement10_60()
        let containerFrame = CGRect(x: -10, y: -10, width: 90, height: 90)
        XCTAssertEqual(container?.frame, containerFrame)
        
        move(from: .coord(0), to: .coord(10)) // Move by 10
        
        XCTAssertEqual(container?.frame, containerFrame.offsetBy(dx: 10, dy: 10), "Move container")
    }
    
    func test_whenMoveContainer_shouldMoveAllElementsInsideIt() throws {
        let (element, _) = try createContainerWithElement10_60()
        let elementFrame = CGRect(x: 10, y: 10, width: 50, height: 50)
        XCTAssertEqual(element.frame, elementFrame)
        
        move(from: .coord(0), to: .coord(10)) // Move by 10
        
        XCTAssertEqual(element.frame, elementFrame.offsetBy(dx: 10, dy: 10), "Move element inside container")
    }
    
    // MARK: - Resizing
    func test_whenMoveBottomRightCorner_shouldResize() {
        drawRect(from: start10, to: end60)
        XCTAssertEqual(drawnControls.count, 1)
        
        sut.mouseDown(on: .coord(60)) // Not include border
        sut.mouseDragged(on: .coord(20))
        
        XCTAssertEqual(drawnControls.count, 1)
        XCTAssertEqual(drawnControls[0].frame,
                       CGRect(origin: start10, size: .side(10)))
    }
}

// TODO: Move to test helpers. Duplicate at DocumentPresenterTests
extension DocumentPresenter {
    func disableUndoRegistration() {
        document.undo?.disableUndoRegistration()
    }
    
    func enableUndoRegistration() {
        document.undo?.enableUndoRegistration()
    }
    func undo() {
        document.undo?.undo()
    }
}
