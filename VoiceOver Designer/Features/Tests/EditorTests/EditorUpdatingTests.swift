import XCTest
@testable import Editor
import Document
import DocumentTestHelpers

class EditorUpdatingTests: EditorTests {
    
    func test_emptyDocument_whenLoad_shouldDrawNothing() {
        didLoad()
        
        XCTAssertEqual(numberOfDrawnViews, 0)
    }

    func test_documentWithControls_whenUpdateElements_shouldDrawNew() {
        XCTContext.runActivity(named: "Open document") { _ in
            sut.document.controls = [
                .empty(frame: .zero),
                .empty(frame: .zero),
            ]
            
            didLoad()
            
            XCTAssertEqual(numberOfDrawnViews, 2)
        }
        
        XCTContext.runActivity(named: "Modify document by another source") { _ in
            updateControls([
                .empty(frame: .zero),
                .empty(frame: .zero),
                .empty(frame: .zero),
            ])
            
            XCTAssertEqual(numberOfDrawnViews, 3)
        }
    }
    
    func updateControls(_ controls: [A11yDescription]) {
        sut.document.controls = controls
    }
}

