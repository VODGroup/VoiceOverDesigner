import XCTest
@testable import Document
import DocumentTestHelpers

class DocumentWrappersInvalidationTests: XCTestCase {
    
    var document: VODesignDocument!
    var path: URL!

    // MARK: - DSL
    private var framePath: URL {
        path.appendingPathComponent(defaultFrameName)
    }
    
    private func pathInFrame(_ fileName: String) -> URL {
        path
            .appendingPathComponent(defaultFrameName)
            .appendingPathComponent(fileName)
    }
    
    var firstFrame: FileWrapper? {
        document.frameWrappers[0]
    }
    
    private func assertMatchContentInFrame(
        _ fileName: String,
        file: StaticString = #file, line: UInt = #line
    ) throws {
        let wrapper = try XCTUnwrap(firstFrame?[fileName], file: file, line: line)
        let path = pathInFrame(fileName)
        XCTAssertTrue(wrapper.matchesContents(of: path), file: file, line: line)
    }
    
    private func assertNotMatchContentInFrame(
        _ fileName: String,
        file: StaticString = #file, line: UInt = #line
    ) throws {
        let wrapper = try XCTUnwrap(firstFrame?[fileName], file: file, line: line)
        let path = pathInFrame(fileName)
        XCTAssertFalse(wrapper.matchesContents(of: path), file: file, line: line)
    }
    
    // MARK: - Tests
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        let documentName = String.artboard
        document = try Sample().document(name: documentName, testCase: self)
        
        path = try XCTUnwrap(Sample().documentPath(name: documentName))
    }
    
    func test_matchesContentAfterReading() {
        XCTAssertTrue(document.documentWrapper.matchesContents(of: path))
    }
    
    func test_whenUpdateImage_shouldInvalidateQuickLookFile() throws {
        document.addFrame(with: Image(), origin: .zero)
        
        XCTAssertNil(firstFrame?[FolderName.quickLook], "quickLook is invalidated")
    }
    
    func test_whenUpdateImage_shouldInvalidateWrapper() throws {
        // Arrange: has a document with frame's image
        document.addFrame(with: Image(), origin: .zero)
        try document.saveAndRemoveAtTearDown(name: "ImageInvalidation", testCase: self)
        let imageFileWrappers = try XCTUnwrap(document.imagesFolderWrapper.fileWrappers?.values)
        
        // Act: update frame's image
        let frame = try XCTUnwrap(document.artboard.frames.first)
        document.update(image: .tmp(name: "NewImage", data: Data()), for: frame)
        
        try document.save(name: "ImageInvalidation", testCase: self)
        
        // Assert: shouldInvalidate previous image
        assertFolder(document)
        
        // TODO: Test size invalidating
    }
}

extension FileWrapper {
    subscript(_ name: String) -> FileWrapper? {
        return fileWrappers?[name]
    }
}
