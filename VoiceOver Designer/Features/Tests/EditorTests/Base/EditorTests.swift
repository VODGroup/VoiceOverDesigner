import XCTest
@testable import Editor
import Document
import DocumentTestHelpers

class EditorTests: XCTestCase {
    
    var sut: EditorPresenter!
    var controller: EmptyViewController!
    
    override func setUp() {
        super.setUp()
        
        controller = EmptyViewController()
        
        sut = EditorPresenter(document: DocumentFake())
//        VODesignDocument.testDocument(name: "Test",
//                                      saveImmediately: true,
//                                      testCase: self)
    }
    
    override func tearDownWithError() throws {
        try? VODesignDocument.removeTestDocument(name: "Test")
        sut = nil
        controller = nil
        super.tearDown()
    }
    
    let start10 = CGPoint.coord(10)
    let end60   = CGPoint.coord(60)
    let rect10to50  = CGRect(origin: .coord(10), size: .side(50))
}

// MARK: - DSL

extension EditorTests {
    func didLoad() {
        sut.didLoad(ui: controller.controlsView)
    }
    
    
    var drawnControls: [A11yDescription] {
        controller.controlsView.drawnControls.compactMap(\.a11yDescription)
    }
    
    var numberOfDrawnViews: Int {
        drawnControls.count
    }
    
    var documentControls: [A11yDescription] {
        sut.document.controls
    }
    
    func drawRect_10_60(deselect: Bool = true) {
        sut.mouseDown(on: start10)
        sut.mouseUp(on: end60)
        
        sut.deselect()
    }
    
    func drawRect(from: CGPoint, to: CGPoint) {
        sut.mouseDown(on: from)
        sut.mouseUp(on: to)
    }
    
    func awaitSelected() async throws -> A11yDescription? {
        return try await awaitPublisher(sut.selectedPublisher)
    }
}

extension EditorPresenter {
    func click(coordinate: CGPoint) {
        mouseDown(on: coordinate)
        mouseUp(on: coordinate)
    }
}
