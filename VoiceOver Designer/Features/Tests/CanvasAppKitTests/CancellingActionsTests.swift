import Foundation
@testable import Canvas
import XCTest
import Document

class CancellingActionsTests: CanvasAfterDidLoadTests {
    
    func pressEsc() {
        sut.cancelOperation()
    }
    
    @MainActor
    func test_CancelCopyActionShouldDeleteCopiedControlAndResetFrame() async throws {
        let copyCommand = setupManualCopyCommand()
        drawRect_10_60()
        
        // Copy
        copyCommand.isModifierActive = true
        sut.mouseDown(on: .coord(15))
        pressEsc()
        sut.mouseUp(on: .coord(50))
        
        XCTAssertEqual(documentControls.count, 1)
        XCTAssertEqual(documentControls[0].frame, rect10to50)
    }
    
    @MainActor
    func test_CancelTranslateActionShouldResetFrame() async throws {
        drawRect_10_60()
        
        // Copy
        sut.mouseDown(on: .coord(15))
        pressEsc()
        sut.mouseUp(on: .coord(50))
        
        XCTAssertEqual(documentControls.count, 1)
        XCTAssertEqual(documentControls[0].frame, rect10to50)
    }
    
    @MainActor
    func test_CancelNewControlActionShouldDeleteNewControl() async throws {
        sut.mouseDown(on: start10)
        pressEsc()
        sut.mouseUp(on: start10.offset(x: 10, y: 50))
        
        XCTAssertEqual(documentControls.count, 0)
        XCTAssertTrue(documentControls.isEmpty)
    }
    
    @MainActor
    func test_CancelResizeActionShouldResetFrameSize() async throws {
        drawRect(from: start10, to: end60)
        XCTAssertEqual(drawnControls.count, 1)
        
        sut.mouseDown(on: .coord(60-1)) // Not inclued border
        pressEsc()
        sut.mouseDragged(on: .coord(20))
        
        let element = try XCTUnwrap(drawnControls.first)
        XCTAssertEqual(element.frame, rect10to50)
    }
}
