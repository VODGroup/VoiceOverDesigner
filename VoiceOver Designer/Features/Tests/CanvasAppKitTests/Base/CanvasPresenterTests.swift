import XCTest
@testable import Canvas
import Document
import DocumentTestHelpers

class CanvasPresenterTests: XCTestCase {
    
    var sut: CanvasPresenter!
    var controller: EmptyViewController!
    var document: VODesignDocumentProtocol!
    
    override func setUp() {
        super.setUp()
        
        controller = EmptyViewController()
        document = DocumentFake()
        document.image = Image()
        
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
    func didLoad() {
        sut.didLoad(ui: controller.controlsView,
                    initialScale: 1)
    }
    
    var drawnControls: [any AccessibilityView] {
        controller.controlsView.drawnControls.compactMap(\.model)
    }
    
    var numberOfDrawnViews: Int {
        drawnControls.count
    }
    
    var documentControls: [any AccessibilityView] {
        sut.document.controls
    }
    
    func move(from: CGPoint, to: CGPoint) {
        sut.mouseDown(on: from)
        sut.mouseUp(on: to)
    }
    
    func drawRect(from: CGPoint, to: CGPoint) {
        sut.mouseDown(on: from)
        sut.mouseUp(on: to)
    }
    
    func drawRect_10_60(deselect: Bool = true) {
        sut.mouseDown(on: start10)
        sut.mouseUp(on: end60)
        
        sut.deselect()
    }
    
    func drag(_ start: CGFloat, _ otherPoints: CGFloat...) {
        sut.mouseDown(on: .coord(start))
        for point in otherPoints {
            sut.mouseDragged(on: .coord(point))
        }
    }
    
    func awaitSelected(file: StaticString = #file,
                       line: UInt = #line
    ) async throws -> (any AccessibilityView)? {
        return try await awaitPublisher(sut.selectedPublisher,
                                        file: file, line: line)
    }
    
    func removeImage() {
        document.image = nil
    }
}

extension CanvasPresenter {
    func click(coordinate: CGPoint) {
        mouseDown(on: coordinate)
        mouseUp(on: coordinate)
    }
}
