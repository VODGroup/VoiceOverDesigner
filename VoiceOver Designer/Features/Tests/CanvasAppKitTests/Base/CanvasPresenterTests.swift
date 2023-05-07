import XCTest
@testable import Canvas
import Document
import DocumentTestHelpers

class CanvasPresenterTests: XCTestCase {
    
    var sut: CanvasPresenter!
    var controller: EmptyViewController!
    var document: VODesignDocumentProtocol!
    var uiScrollSpy: CanvasScrollViewSpy!
    
    override func setUp() {
        super.setUp()
        
        controller = EmptyViewController()
        uiScrollSpy = CanvasScrollViewSpy()
        
        document = DocumentFake()
        
        sut = CanvasPresenter(document: document)
    }
    
    override func tearDownWithError() throws {
        try? VODesignDocument.removeTestDocument(name: "Test")
        document = nil
        sut = nil
        controller = nil
        super.tearDown()
    }
    
    let start10 = CGPoint.coord(10)
    let end60   = CGPoint.coord(60)
    let rect10to50  = CGRect(origin: .coord(10), size: .side(50))
}

// MARK: - DSL

extension CanvasPresenterTests {
    
    var drawnControls: [any ArtboardElement] {
        controller.controlsView.drawnControls.compactMap(\.model)
    }
    
    var documentControls: [any ArtboardElement] {
        sut.document.artboard.controlsWithoutFrames
    }
    
    var numberOfDrawnViews: Int {
        drawnControls.count
    }
    
    func didLoad() {
        sut.didLoad(uiContent: controller.controlsView,
                    uiScroll: uiScrollSpy,
                    initialScale: 1,
                    previewSource: PreviewSourceDummy())
    }
    
    @discardableResult
    func move(from: CGPoint, to: CGPoint) -> A11yControlLayer? {
        sut.mouseDown(on: from)
        return sut.mouseUp(on: to)
    }
   
    @discardableResult
    func drawRect(from: CGPoint, to: CGPoint) -> A11yControlLayer? {
        sut.mouseDown(on: from)
        return sut.mouseUp(on: to)
    }
    
    func drawRect_10_60(deselect: Bool = true) {
        sut.mouseDown(on: start10)
        sut.mouseUp(on: end60)
        
        if deselect {
            sut.deselect()
        }
    }
    
    func setupManualCopyCommand() -> ManualCopyCommand {
        let copyCommand = ManualCopyCommand()
        controller.controlsView.copyListener = copyCommand
        return copyCommand
    }
    
    func copy(from: CGPoint, to: CGPoint) {
        let copyCommand = setupManualCopyCommand()
        copyCommand.isModifierActive = true
        sut.mouseDown(on: from)
        sut.mouseUp(on: to)
    }
    
    func drag(_ start: CGFloat, _ otherPoints: CGFloat...) {
        sut.mouseDown(on: .coord(start))
        for point in otherPoints {
            sut.mouseDragged(on: .coord(point))
        }
    }
    
    func click(_ coordinate: CGPoint) {
        sut.mouseDown(on: coordinate)
        sut.mouseUp(on: coordinate)
    }
    
    func awaitSelected(file: StaticString = #file,
                       line: UInt = #line
    ) async throws -> (any ArtboardElement)? {
        return try await awaitPublisher(sut.selectedPublisher,
                                        file: file, line: line)
    }
}

extension CanvasPresenter {
    func click(coordinate: CGPoint) {
        mouseDown(on: coordinate)
        mouseUp(on: coordinate)
    }
}

class PreviewSourceDummy: PreviewSourceProtocol {
    func previewImage() -> Image? {
        nil
    }
}

class CanvasScrollViewSpy: CanvasScrollViewProtocol {
    func fitToWindow(animated: Bool) {
        
    }
}
