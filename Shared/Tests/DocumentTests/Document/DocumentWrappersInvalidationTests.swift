import XCTest
@testable import Document
import DocumentTestHelpers

class DocumentWrappersInvalidationTests: XCTestCase {
    
    func test_documentWithImage_matchesContentAfterReading() throws {
        let document = try Sample().document(name: .artboard, testCase: self)
        
        let path = try XCTUnwrap(Sample().documentPath(name: .artboard))
        
        XCTAssertTrue(document.documentWrapper.matchesContents(of: path))
    }
    
    func test_documentWithImage_whenUpdateImage_shouldInvalidateQuickLookFile() throws {
        let document = try Sample().document(name: .artboard, testCase: self)
        
        document.addFrame(with: Image(), origin: .zero)
        
        XCTAssertNil(document.frameWrappers[0][FolderName.quickLook], "quickLook is invalidated")
    }
    
    func test_documentWithImage_whenUpdateImage_shouldInvalidateWrapper() throws {
        // Arrange
        let document = try Sample().document(name: .artboard, testCase: self)
        
        // Act: update frame's image
        let frame = try XCTUnwrap(document.artboard.frames.first)
        document.update(image: .tmp(name: "NewImage", data: Data()), for: frame)
        try document.saveAndRemoveAtTearDown(name: "ImageInvalidation", testCase: self)
        
        // Assert: shouldInvalidate previous image
        assertFolder(document)
    }
}

extension FileWrapper {
    subscript(_ name: String) -> FileWrapper? {
        return fileWrappers?[name]
    }
}
