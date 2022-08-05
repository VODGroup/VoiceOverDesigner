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
}

