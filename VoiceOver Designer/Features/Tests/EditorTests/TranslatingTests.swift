import XCTest
@testable import Editor
import Document

class TranslatingTests: EditorAfterDidLoadTests {
    
    // MARK: Editing
    func test_movementFor5px_shouldTranslateRect() async throws {
        drawRect_10_60()
        
        // Move
        sut.mouseDown(on: .coord(15))
        sut.mouseDragged(on: .coord(17))
        sut.mouseDragged(on: .coord(18))
        sut.mouseDragged(on: .coord(20)) // 5px from start
        
        XCTAssertEqual(drawnControls.count, 1)
        XCTAssertEqual(drawnControls.first?.frame,
                       rect10to50.offsetBy(dx: 5, dy: 5))
        
        let selected = try await awaitSelected()
        XCTAssertNil(selected, "should not select after translation")
    }
    
    func test_translateToNegativeCoordinates_shouldTranslate() async throws {
        drawRect_10_60()
        
        // Move
        sut.mouseDown(on: .coord(15))
        sut.mouseUp(on: .coord(5))
        
        XCTAssertEqual(drawnControls.first?.frame,
                       rect10to50.offsetBy(dx: -10, dy: -10))
        
        let selected = try await awaitSelected()
        XCTAssertNil(selected, "should not select after translation")
    }
    
    func test_whenMoveNearLeftEdgeOnAnyElement_shouldPinToLeftEdge() {
        drawRect(from: start10, to: end60)
        drawRect(from: .coord(100),
                 to: .coord(150))
        XCTAssertEqual(drawnControls.count, 2)
        
        sut.mouseDown(on: .coord(101)) // 2nd rect
        sut.mouseDragged(on: .coord(11))
        
        XCTAssertEqual(drawnControls[1].frame,
                       CGRect(origin: .coord(10), size: .side(50)))
    }
    
    // TODO:
    // - aligned vertically
    // - aligned to 3rd element
    
    func test_CopyControlShouldDrawNewControlAndHaveSameProperties() async throws {
        let copyCommand = ManualCopyCommand()
        
        await MainActor.run {
            controller.controlsView.copyListener = copyCommand
            drawRect_10_60()
        }
        
        // Copy
        copyCommand.isCopyHold = true
        sut.mouseDown(on: .coord(15))
        sut.mouseUp(on: .coord(50))
        
        XCTAssertEqual(sut.document.controls.count, 2)
        XCTAssert(sut.document.controls[0] !== sut.document.controls[1], "Not same objects")
        XCTAssertEqual(sut.document.controls[1].frame, rect10to50.offsetBy(dx: 35,
                                                                           dy: 35))
        
        let selected = try await awaitSelected()
        XCTAssertNil(selected, "should not select after translation")
        
        
        // Undo
        sut.document.undoManager?.undo()
        XCTAssertEqual(sut.document.controls.count, 1, "should remove copy")
    }
}
