import XCTest
@testable import Canvas
import Document
import DocumentTestHelpers

class CanvasUpdatingTests: CanvasPresenterTests {
    
    func test_emptyDocument_whenLoad_shouldDrawNothing() {
        didLoadAndAppear()
        
        XCTAssertEqual(numberOfDrawnViews, 0)
    }

    func test_documentWithControls_whenUpdateElements_shouldDrawNew() throws {
        XCTContext.runActivity(named: "Open document") { _ in
            setControls(count: 2)
            
            didLoadAndAppear()
            
            XCTAssertEqual(numberOfDrawnViews, 2)
        }
        
        let control = try XCTUnwrap(sut.drawingController.view.drawnControls.first)
        sut.select(control: control)
        
        XCTContext.runActivity(named: "Modify document by another source") { _ in
            setControls(count: 3)
            
            XCTAssertEqual(numberOfDrawnViews, 3)
            
            XCTAssertNotNil(sut.selectedControl)
            XCTAssertNotEqual(sut.selectedControl, control,
                              "should select another control")
        }
    }
    
    func setControls(count: Int) {
        var controls = [A11yDescription]()
        for _ in 0..<count {
            controls.append(.empty(frame: .zero))
        }
        
        sut.update(elements: controls)
    }
}
