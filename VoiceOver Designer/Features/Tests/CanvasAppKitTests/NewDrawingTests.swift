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
        
        drawingLayer.assertRelativeFrames {
            """
            ControlLayer: (10.0, 10.0, 50.0, 50.0)
            """
        }
        artboard.assertAbsoluteFrames {
            """
            : (10.0, 10.0, 50.0, 50.0)
            """
        }
    }
    
    func test_drawRectangle_onMouseUp() {
        sut.mouseDown(on: start10)
        sut.mouseUp(on: end60)
        
        drawingLayer.assertRelativeFrames {
            """
            ControlLayer: (10.0, 10.0, 50.0, 50.0)
            """
        }
        artboard.assertAbsoluteFrames {
            """
            : (10.0, 10.0, 50.0, 50.0)
            """
        }
    }
    
    func test_drawSmallerThanMinimalWidth_shouldIncreaseSizeToMinimal_andKeepCenter() {
        sut.mouseDown(on: start10)
        sut.mouseUp(on: start10.offset(x: 10, y: 50))
        
        drawingLayer.assertRelativeFrames("Increase minimal frame") {
            """
            ControlLayer: (-7.0, 10.0, 44.0, 50.0)
            """
        }
        artboard.assertAbsoluteFrames("Increase minimal frame") {
            """
            : (-7.0, 10.0, 44.0, 50.0)
            """
        }
    }
    
    func test_drawSmallerThanMinimalHeight_shouldIncreaseSizeToMinimal_andKeepCenter() {
        sut.mouseDown(on: start10)
        sut.mouseUp(on: start10.offset(x: 50, y: 10))
    
        drawingLayer.assertRelativeFrames("Increase minimal frame") {
            """
            ControlLayer: (10.0, -7.0, 50.0, 44.0)
            """
        }
        artboard.assertAbsoluteFrames("Increase minimal frame") {
            """
            : (10.0, -7.0, 50.0, 44.0)
            """
        }
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
        
        drawingLayer.assertRelativeFrames {
            """
            FrameLayer: (0.0, 0.0, 390.0, 180.0)
             ControlLayer: (10.0, 10.0, 50.0, 50.0)
            """
        }
        
        artboard.assertAbsoluteFrames {
            """
            Sample: (0.0, 0.0, 390.0, 180.0):
             Element: (10.0, 10.0, 50.0, 50.0)
            """
        }
    }
    
    func test_noFrame_whenDrawAnElementAtNegativeCoordinates_shouldAddLayerToRoot() {
        drag(-20, -10) // Move by 10
        
        drawingLayer.assertRelativeFrames {
            """
            ControlLayer: (-37.0, -37.0, 44.0, 44.0)
            """
        }
        
        artboard.assertAbsoluteFrames {
            """
            : (-37.0, -37.0, 44.0, 44.0)
            """
        }
    }
    
    func test_noFrame_whenDrawAnElementAtPositiveCoordinates_shouldAddLayerToRoot() {
        drag(10, 60)
        
        drawingLayer.assertRelativeFrames {
            """
            ControlLayer: (10.0, 10.0, 50.0, 50.0)
            """
        }
        
        artboard.assertAbsoluteFrames {
            """
            : (10.0, 10.0, 50.0, 50.0)
            """
        }
    }
    
    func test_offsetedFrame_whenDrawAnElementNotOverFrameWithNegativeCoordinates_shouldAddLayerToRoot() {
        addFrameWithOffset()
        sut.deselect()
        
        // Draw an element
        
        drag(-60, -10)
        
        drawingLayer.assertRelativeFrames {
            """
            FrameLayer: (50.0, 50.0, 390.0, 180.0)
            ControlLayer: (-60.0, -60.0, 50.0, 50.0)
            """
        }
        
        artboard.assertAbsoluteFrames {
            """
            Sample: (50.0, 50.0, 390.0, 180.0)
            : (-60.0, -60.0, 50.0, 50.0)
            """
        }
    }
    
    func test_whenDrawnElementIntersectsFrame_shouldDefineHierarchyByOrigin() {
        addFrameWithOffset()
        sut.deselect()
        
        drag(30, 80)
        
        drawingLayer.assertRelativeFrames {
            """
            FrameLayer: (50.0, 50.0, 390.0, 180.0)
            ControlLayer: (30.0, 30.0, 50.0, 50.0)
            """
        }
        artboard.assertAbsoluteFrames {
            """
            Sample: (50.0, 50.0, 390.0, 180.0)
            : (30.0, 30.0, 50.0, 50.0)
            """
        }
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
    
    func addFrameWithOffset() {
        addFrame()
        drag(10, 60) // Translate frame by 50
        drawingLayer.assertRelativeFrames {
            """
            FrameLayer: (50.0, 50.0, 390.0, 180.0)
            """
        }
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
