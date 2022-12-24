import XCTest
@testable import Canvas
import Document

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
        XCTAssertNil(selected, "should not select after translation")
    }
    
    func test_whenMoveNearLeftEdgeOnAnyElement_shouldPinToLeftEdge() throws {
        drawRect(from: start10, to: end60)
        drawRect(from: .coord(200),
                 to: .coord(300))
        XCTAssertEqual(drawnControls.count, 2)
        
        sut.mouseDown(on: .coord(200+30)) // 2nd rect
        sut.mouseDragged(on: .coord(10+1))
        
        XCTAssertEqual(drawnControls[1].frame,
                       CGRect(origin: .coord(10), size: .side(290)))
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
        sut.mouseUp(on: .coord(15+35))
        
        XCTAssertEqual(drawnControls.count, 2)
        XCTAssert(sut.document.controls[0] !== sut.document.controls[1], "Not same objects")
        XCTAssertEqual(sut.document.controls[1].frame, rect10to50.offsetBy(dx: 35,
                                                                           dy: 35))
        
        let selected = try await awaitSelected()
        XCTAssertNil(selected, "should not select after translation")
        
        
        // Undo
        sut.document.undo?.undo()
        XCTAssertEqual(drawnControls.count, 1, "should remove copy")
    }
    
    // MARK: - Resizing
    func test_whenMoveBottomRightCorner_shouldResize() {
        drawRect(from: start10, to: end60)
        XCTAssertEqual(drawnControls.count, 1)
        
        sut.mouseDown(on: .coord(60)) // Not include border
        sut.mouseDragged(on: .coord(20))
        
        XCTAssertEqual(drawnControls.count, 1)
        XCTAssertEqual(drawnControls[0].frame,
                       CGRect(origin: .coord(10), size: .side(10)))
    }
}
