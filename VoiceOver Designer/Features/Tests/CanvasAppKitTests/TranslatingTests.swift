import XCTest
@testable import Canvas
import Document
import DocumentTestHelpers

@MainActor
class TranslatingTests: CanvasAfterDidLoadTests {
    
    // MARK: Editing
    func test_movementFor5px_shouldTranslateRect() async throws {
        drawRect_10_60()
        
        drag(15, 17, 18, 20) // 5px from start
        
        XCTAssertEqual(drawnControls.count, 1)
        XCTAssertEqual(drawnControls.first?.frame,
                       rect10to50.offsetBy(dx: 5, dy: 5))
    }
    
    func test_movementFor5px_shouldSelect() async throws {
        drawRect_10_60()
        
        drag(15, 17, 18, 20) // 5px from start
        
        let selected = try await awaitSelected()
        XCTAssertNotNil(selected, "should keep selection after translation")
    }
    
    func test_translateToNegativeCoordinates_shouldTranslate() async throws {
        drawRect_10_60()
        
        drag(15, 5)
        
        XCTAssertEqual(drawnControls.first?.frame,
                       rect10to50.offsetBy(dx: -10, dy: -10))
    }
    
    func test_translateToNegativeCoordinates_shouldSelect() async throws {
        drawRect_10_60()
        
        drag(15, 5)

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
    @discardableResult
    private func createContainerWithElement10_60() throws -> (A11yDescription, A11yContainer?) {
        sut.disableUndoRegistration()
        let element = try drawElement(from: start10, to: end60)
        let container = wrapInContainer([element])
        sut.enableUndoRegistration()
        
        return (element, container)
    }
    
    func test_whenMoveContainer_shouldMoveContainerAndElements() throws {
        try createContainerWithElement10_60()
        artboard.assertAbsoluteFrames {
            """
            Container: (-10.0, -10.0, 90.0, 90.0):
             Element: (10.0, 10.0, 50.0, 50.0)
            """
        }
        
        drag(0, 10) // Move by 10
        
        artboard.assertAbsoluteFrames {
            """
            Container: (0.0, 0.0, 90.0, 90.0):
             Element: (20.0, 20.0, 50.0, 50.0)
            """
        }
    }
    
    // MARK: Frames
    @discardableResult
    private func createFrameAtZeroOrigin() -> Frame {
        sut.disableUndoRegistration()
        let frame = sut.add(image: Sample().image3x())
        frame.label = "Frame"
        sut.enableUndoRegistration()
        
        return frame
    }
    private func createFrameWithElement10_60() throws -> (A11yDescription, Frame) {
        sut.disableUndoRegistration()
        let frame = createFrameAtZeroOrigin()
        sut.deselect() // Frame
        let element = try drawElement(from: start10, to: end60)
        sut.enableUndoRegistration()
        
        return (element, frame)
    }

    func test_emptyFrame_whenMove_shouldMoveFrame_layer() throws {
        createFrameAtZeroOrigin()
        
        drag(10, 20)
        
        drawingLayer.assertRelativeFrames {
            """
            ImageLayer: (10.0, 10.0, 390.0, 180.0)
            """
        }
    }
    
    func test_emptyFrame_whenMove_shouldMoveFrame_model() throws {
        createFrameAtZeroOrigin()

        drag(10, 20)
        
        artboard.assertAbsoluteFrames {
            """
            Frame: (10.0, 10.0, 390.0, 180.0)
            """
        }
    }
    
    func test_frameWithElements_whenMoveFrame_shouldMoveElementsInsideFrame_layer() throws {
        let (_, frame) = try createFrameWithElement10_60()
        sut.select(frame) // Select frame to pass movement to frame
        
        drag(10, 12, 15, 18, 20) // 10 offset

        drawingLayer.assertRelativeFrames {
            """
            ImageLayer: (10.0, 10.0, 390.0, 180.0)
             A11yControlLayer: (10.0, 10.0, 50.0, 50.0)
            """
        }
    }
    
    func test_frameWithElements_whenMove_shouldMoveElementsInsideFrame_model() throws {
        let (_, frame) = try createFrameWithElement10_60()
        sut.select(frame) // Select frame to pass movement to frame
        
        drag(10, 12, 15, 18, 20) // 10 offset
        
        artboard.assertAbsoluteFrames {
            """
            Frame: (10.0, 10.0, 390.0, 180.0):
             Element: (20.0, 20.0, 50.0, 50.0)
            """
            }
    }
    
    func test_frameWithElements_whenMove_andUndo_shouldRestore() throws {
        let (_, frame) = try createFrameWithElement10_60()
        sut.select(frame) // Select frame to pass movement to frame
        
        drag(10, 12, 15, 18, 20) // 10 offset
        sut.undo()
        
        artboard.assertAbsoluteFrames {
            """
            Frame: (0.0, 0.0, 390.0, 180.0):
             Element: (10.0, 10.0, 50.0, 50.0)
            """
        }
    }
    
    func test_whenMoveFrameTwoTimes_shouldMoveFrame_layer() throws {
        let (_, frame) = try createFrameWithElement10_60()
        sut.select(frame) // Select frame to pass movement to frame
        
        drag(10, 20)
        drag(20, 30) // 20 offset in total
        
        drawingLayer.assertRelativeFrames {
            """
            ImageLayer: (20.0, 20.0, 390.0, 180.0)
             A11yControlLayer: (10.0, 10.0, 50.0, 50.0)
            """
        }
    }
    
    func test_whenMoveFrameTwoTimes_shouldMoveFrame_model() throws {
        let (_, frame) = try createFrameWithElement10_60()
        sut.select(frame) // Select frame to pass movement to frame
        
        drag(10, 20)
        drag(20, 30) // 20 offset in total
        
        artboard.assertAbsoluteFrames {
            """
            Frame: (20.0, 20.0, 390.0, 180.0):
             Element: (30.0, 30.0, 50.0, 50.0)
            """
        }
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

// MARK: CALayer snapshotting
import InlineSnapshotTesting
extension CALayer {
    public func assertRelativeFrames(
        _ message: String = "",
        matches expected: (() -> String)? = nil,
        file: StaticString = #filePath,
        function: StaticString = #function,
        line: UInt = #line,
        column: UInt = #column
    ) {
        let actual = sublayersDescription(keyPath: \.frameDescription) ?? "No layers"
            
        assertInlineSnapshot(
            of: actual,
            as: .lines,
            message: message,
            matches: expected,
            file: file, function: function, line: line, column: column)
    }
    
    var frameDescription: String {
        "\(Self.self): \(frame.debugDescription)"
    }
}

extension CALayer {
    public func recursiveDescription(
        insetLevel: Int = 0,
        keyPath: KeyPath<CALayer, String>
    ) -> String {
        let inset = String(repeating: " ", count: insetLevel)
        
        if let sublayersDescription = sublayersDescription(insetLevel: insetLevel + 1, keyPath: keyPath) {
            return self[keyPath: keyPath] + "\n" + sublayersDescription
        } else {
            return inset + self[keyPath: keyPath]
        }
    }
    
    private func sublayersDescription(
        insetLevel: Int = 0,
        keyPath: KeyPath<CALayer, String>
    ) -> String? {
        sublayers?
            .compactMap { sublayer in
                sublayer.recursiveDescription(
                    insetLevel: insetLevel,
                    keyPath: keyPath)
            }.joined(separator: "\n")
    }
}
