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
    
    func didLoad() {
        sut.didLoad(ui: controller.controlsView,
                    router: router,
                    delegate: delegate)
    }
}

