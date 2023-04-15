import XCTest
import Document
import DocumentTestHelpers

final class DocumentPresenterTests: XCTestCase {

    var sut: DocumentPresenter!
    var document: VODesignDocumentProtocol!
    
    var element1: A11yDescription!
    var element2: A11yDescription!
    
    override func setUp() {
        super.setUp()

        document = DocumentFake()
        document.image = Image()
        
        sut = DocumentPresenter(document: document)
        
        element1 = A11yDescription.testMake(label: "1")
        element2 = A11yDescription.testMake(label: "2")
    }
    
    override func tearDownWithError() throws {
        try? VODesignDocument.removeTestDocument(name: "Test")
        document = nil
        sut = nil
        super.tearDown()
    }
    
    func test_appendElement() {
        sut.append(control: element1)
        XCTAssertEqual(sut.document.controls.count, 1)
        
        sut.document.undo?.undo()
        XCTAssertTrue(sut.document.controls.isEmpty)
    }
    
    // MARK: - Container
    func test_whenWrapsInContainer_shouldWrap() {
        sut.append(control: element1)
        sut.append(control: element2)
        
        let container = sut.wrapInContainer([element1, element2])
        
        XCTAssertEqual(sut.document.controls.count, 1)
        XCTAssertTrue(sut.document.controls.first is A11yContainer)
        XCTAssertEqual(container?.elements.count, 2)
    }
    
    // MARK: - Delete
    // MARK: Elements
    func test_delete1Element() {
        sut.append(control: element1)
        sut.append(control: element2)
        
        sut.remove(element1)
        XCTAssertEqual(sut.document.controls.count, 1)
    }
    
    func test_delete2Element() {
        sut.append(control: element1)
        sut.append(control: element2)
        
        sut.remove(element2)
        
        XCTAssertEqual(sut.document.controls.count, 1)
    }
    
    // MARK: Containers
    func test_container_whenRemove1stElementInContainer_shouldRemove() {
        sut.append(control: element1)
        sut.append(control: element2)
        let container = sut.wrapInContainer([element1, element2])

        sut.remove(element1)
        XCTAssertEqual(container?.elements.count, 1)
        
        sut.undo()
        XCTAssertEqual(container?.elements.count, 2)
    }
    
    func test_container_whenRemoveContainer_shouldRemoveEverything() throws {
        sut.document.undo?.disableUndoRegistration()
        sut.append(control: element1)
        sut.append(control: element2)

        let container = try XCTUnwrap(sut.wrapInContainer([element1, element2]))
        sut.document.undo?.enableUndoRegistration()
        
        sut.remove(container)
        XCTAssertTrue(sut.document.controls.isEmpty)
        
        sut.undo()
        XCTAssertEqual(sut.document.controls.count, 1)
    }
}

extension DocumentPresenter {
    func undo() {
        document.undo?.undo()
    }
}
