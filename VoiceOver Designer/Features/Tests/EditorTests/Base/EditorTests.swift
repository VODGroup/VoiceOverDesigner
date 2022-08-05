import XCTest
@testable import Editor
import Document
import DocumentTestHelpers

class EditorTests: XCTestCase {
    
    var sut: EditorPresenter!
    var router: RouterMock!
    var delegate: EditorDelegateMock!
    var controller: EmptyViewController!
    
    override func setUp() {
        super.setUp()
        
        controller = EmptyViewController()
        
        sut = EditorPresenter()
        sut.document = DocumentFake()
        //        VODesignDocument.testDocument(name: "Test",
        //                                      saveImmediately: true,
        //                                      testCase: self)
        
        router = RouterMock()
        delegate = EditorDelegateMock()
    }
    
    override func tearDownWithError() throws {
        try? VODesignDocument.removeTestDocument(name: "Test")
        sut = nil
        router = nil
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
        sut.didLoad(ui: controller.controlsView,
                    router: router,
                    delegate: delegate)
    }
    
    
    var drawnControls: [A11yDescription] {
        controller.controlsView.drawnControls.compactMap(\.a11yDescription)
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
}

extension EditorPresenter {
    func click(coordinate: CGPoint) {
        mouseDown(on: coordinate)
        mouseUp(on: coordinate)
    }
}
