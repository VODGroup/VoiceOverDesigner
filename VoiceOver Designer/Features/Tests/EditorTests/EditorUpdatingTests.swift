import XCTest
@testable import Editor
import Document
import DocumentTestHelpers

class EditorUpdatingTests: EditorTests {
    
    func test_whenLoadEmptyDocument_shouldDrawNothing() {
        didLoad()
        
        XCTAssertEqual(numberOfDrawnViews, 0)
    }
    
    func test_whenLoadDocumnteWithControls_shouldDrawElements() {
        sut.document.controls = [
            .empty(frame: .zero),
            .empty(frame: .zero),
        ]
        
        didLoad()
        
        XCTAssertEqual(numberOfDrawnViews, 2)
    }
    
    var numberOfDrawnViews: Int {
        controller.controlsView.drawnControls.count
    }
}

