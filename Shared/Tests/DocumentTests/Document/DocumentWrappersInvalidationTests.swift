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
        let image = Sample().image3x()
        
        // Act: update frame's image
        let frame = try XCTUnwrap(document.artboard.frames.first)
        
        document.update(image: image, for: frame)
        
        try document.saveAndRemoveAtTearDown(name: "ImageInvalidation", testCase: self)
        
        // Assert: shouldInvalidate previous image
        assertFolder(document)
    }
    
    func test_whenUpdateImage_shouldUpdateFrameSize() throws {
        let document = try Sample().document(name: .artboard, testCase: self)
        
        let frame1 = try XCTUnwrap(document.artboard.frames.first)
        XCTAssertEqual(frame1.frame, CGRect(x: 2340, y: 0, width: 1170, height: 3407))
        
        let frame2 = try XCTUnwrap(document.artboard.frames.last)
        let image = document.artboard.imageLoader.image(for: frame2)!
        document.update(image: image, for: frame1)

        XCTAssertEqual(frame1.frame, CGRect(x: 2340, y: 0, width: 1170, height: 3272)) // Height is different
    }
}

extension FileWrapper {
    subscript(_ name: String) -> FileWrapper? {
        return fileWrappers?[name]
    }
}
