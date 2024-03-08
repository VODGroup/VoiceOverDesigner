import XCTest
@testable import Canvas
import Document
import DocumentTestHelpers

class NewDrawingTests: CanvasAfterDidLoadTests {
    func test_rectangleDrawnOnTheFly() {
        sut.mouseDown(on: start10)
        
        XCTContext.runActivity(named: "draw on drag") { _ in
            sut.mouseDragged(on: end60)
            
            XCTAssertEqual(drawnControls.first?.frame,
                           rect10to50, "Draw")
            
            XCTAssertNil(documentControls.first, "but not saved yet")
        }
        
        XCTContext.runActivity(named: "saved on release") { _ in
            sut.mouseUp(on: end60)
            XCTAssertEqual(drawnControls.first?.frame,
                           rect10to50)
        }
    }
    
    func test_drawRectangle_onMouseUp() {
        sut.mouseDown(on: start10)
        sut.mouseUp(on: end60)
        
        XCTAssertEqual(drawnControls.first?.frame,
                       rect10to50)
    }
    
    func test_drawSmallerThanMinimalWidth_shouldIncreaseSizeToMinimal_andKeepCenter() {
        sut.mouseDown(on: start10)
        sut.mouseUp(on: start10.offset(x: 10, y: 50))
        
        XCTAssertEqual(drawnControls.first?.frame,
                       CGRect(origin: CGPoint(x: 10 + 5 - 44/2,
                                              y: 10),
                              size: CGSize(width: 44, height: 50)))
    }
    
    func test_drawSmallerThanMinimalHeight_shouldIncreaseSizeToMinimal_andKeepCenter() {
        sut.mouseDown(on: start10)
        sut.mouseUp(on: start10.offset(x: 50, y: 10))
        
        XCTAssertEqual(drawnControls.first?.frame,
                       CGRect(origin: CGPoint(x: 10,
                                              y: 10 +  5 - 44/2),
                              size: CGSize(width: 50, height: 44)))
    }
    
    func test_notDrawIfSizeIsSmallerThan5px() {
        sut.mouseDown(on: start10)
        sut.mouseUp(on: start10.offset(x: 4, y: 4))
        
        XCTAssertNil(drawnControls.first)
    }
    
    func test_drawInReverseDirection() {
        sut.mouseDown(on: end60)
        sut.mouseUp(on: start10)
        
        XCTAssertEqual(drawnControls.first?.frame,
                       rect10to50)
    }
    
    // MARK: - Artboard
    func test_whenAddImage_shouldAddFrame() {
        addFrame()
        XCTAssertNotNil(document.artboard.frames.first)
    }
    
    func test_frameOnScreen_whenAddElementInsideFrame_shouldAddElementToFrame() throws {
        addFrame()
        sut.deselect()
        
        drawRect(from: start10, to: end60)
        
        let frame = try XCTUnwrap(document.artboard.frames.first)
        XCTAssertEqual(frame.elements.count, 1)
        XCTAssertEqual(document.artboard.elements.count, 1,
                       "Only frame should be on top level")
    }
    
    func test_frameOnScreen_whenDrawAnElementOverScreen_shouldAddLayerToFrameLayer() {
        addFrame()
        sut.deselect()
        
        move(from: .coord(10), to: .coord(20)) // Move by 10
        
        XCTAssertEqual(sut.uiContent?.layer?.sublayers?.count, 1,
                       "Should draw an element inside frame")
        XCTAssertEqual(
            sut.uiContent?.layer?.sublayers?.first?.sublayers?.count, 1,
            "Should draw an element inside frame")
    }
    
    func test_createControlsWhenDocumentImageNil() {
        // TODO: Remove image?
        sut.mouseDown(on: start10)
        sut.mouseUp(on: end60)
        XCTAssertNotNil(drawnControls.first, "Should create control")
    }
    
    func addFrame() {
        let image = Sample().image3x()
        sut.add(image: image, name: "Sample")
    }
    
    // MARK: - Frame drawing
    func test_whenDrawFrame_shouldAddFrameLayer() {
        addFrame()
        
        XCTAssertEqual(numberOfDrawnLayers, 1)
    }
    
    func test_whenDraw2Frames_shouldAddFrameLayer() {
        addFrame()
        addFrame()
        
        XCTAssertEqual(numberOfDrawnLayers, 2)
    }
    
}

extension CGPoint {
    func offset(x: CGFloat, y: CGFloat) -> Self {
        return CGPoint(x: self.x + x,
                       y: self.y + y)
    }
}
