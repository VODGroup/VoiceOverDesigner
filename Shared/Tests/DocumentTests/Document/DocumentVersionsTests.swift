import XCTest
@testable import Document
import DocumentTestHelpers

import InlineSnapshotTesting
import FolderSnapshot

final class DocumentVersionsTests: XCTestCase {

#if os(macOS)
    
    // MARK: - Beta format
    func test_betaDocument_whenRead_shouldKeepStructure() throws {
        let document = try Sample().document(name: .beta, testCase: self)
        
        // Read on file creation

        assertFolder(document) {
"""
▿ QuickView
  - Preview.png
- controls.json
- screen.png
"""
        }
    }
    
    func test_betaDocument_whenSave_shouldUpdateStructure() throws {
        let document = try Sample().document(name: .beta, testCase: self)

        try document.saveAndRemoveAtTearDown(name: "BetaFormatNewStructure", testCase: self)
        
        assertFolder(document) {
"""
▿ Images
  - Frame.png
- document.json
"""
        }
    }
    
    func test_betaDocument_whenRead_shouldMoveElementsToFirstFrame() throws {
        let document = try Sample().document(name: .beta, testCase: self)
        
        let frame = try XCTUnwrap(document.artboard.frames.first)
        
        assert(
            frame: frame, at: document,
            numberOfElements: 12,
            rect: CGRect(x: 0, y: 0, width: 390, height: 844)
        )
    }
    
    func test_betaDocument_whenOpen_shouldLoadImage() throws {
        let document = try Sample().document(name: .beta, testCase: self)
        
        XCTAssertNotNil(try document.imageFromFirstFrame())
    }
    
    func test_betaDocument_whenOpenAndSaveWithSameName_shouldLoadImage() throws {
        let document = try Sample().document(name: .beta, testCase: self)
        
        try document.saveAndRemoveAtTearDown(name: .beta, testCase: self)
        
        XCTAssertNotNil(try document.imageFromFirstFrame())
    }
    
    // MARK: - Frame version
    func test_frameDocument_whenRead_shouldKeepStructure() throws {
        let document = try Sample().document(name: .frame, testCase: self)
        
        // Read on file creation
        
        assertFolder(document) {
"""
▿ Frame
  - controls.json
  - screen.png
  - info.json
▿ QuickView
  - Preview.png
"""
        }
    }
    
    func test_frameDocument_whenSave_shouldUpdateStructure() throws {
        let document = try Sample().document(name: .frame, testCase: self)

        try document.saveAndRemoveAtTearDown(name: "FrameFormatNewStructure", testCase: self)
        
        assertFolder(document) {
"""
▿ Images
  - Frame.png
- document.json
"""
        }
    }
    
    func test_frameDocument_whenReadAfterMigration_shouldKeepStructure() throws {
        let document = try Sample().document(name: .frame, testCase: self)
        
        try document.saveAndRemoveAtTearDown(name: "FrameVersionFormat", testCase: self)
        
        XCTAssertNotNil(try document.imageFromFirstFrame())
    }
    
    func test_frameDocument_whenRead_shouldReadAsFirstFrame() throws {
        let document = try Sample().document(name: .frame, testCase: self)
        
        let frame = try XCTUnwrap(document.artboard.frames.first)
        
        assert(
            frame: frame, at: document,
            numberOfElements: 12,
            rect: CGRect(x: 0, y: 0, width: 390, height: 844)
        )
    }
    
    func test_frameDocument_whenOpen_shouldLoadImage() throws {
        let document = try Sample().document(name: .frame, testCase: self)
        
        XCTAssertNotNil(try document.imageFromFirstFrame())
    }
    
    func test_frameDocument_whenOpenAndSaveWithSameName_shouldLoadImage() throws {
        let document = try Sample().document(name: .frame, testCase: self)
        
        try document.saveAndRemoveAtTearDown(name: .frame, testCase: self)
        
        XCTAssertNotNil(try document.imageFromFirstFrame())
    }
    
    // MARK: Artboard version
    func test_artboardDocument_whenRead_shouldUpdateStructure() throws {
        let document = try Sample().document(name: .artboard, testCase: self)
        
        // Read on file creation
        
        assertFolder(document) {
"""
▿ Images
  - Frame2.png
  - Frame.png
▿ QuickView
  - Preview.heic
- document.json
"""
        }
    }
    
    func test_artboardDocument_whenSave_shouldUpdateStructure() throws {
        let document = try Sample().document(name: .artboard, testCase: self)

        try document.saveAndRemoveAtTearDown(name: "ArtboardFormatNewStructure", testCase: self)
        
        assertFolder(document) {
"""
▿ Images
  - Frame2.png
  - Frame.png
- document.json
"""
        }
    }
    
    func test_artboardDocument_whenRead_shouldReadContent() throws {
        let document = try Sample().document(name: .artboard, testCase: self)
        
        let artboard = document.artboard
        XCTAssertEqual(artboard.frames.count, 2)
        XCTAssertEqual(artboard.controlsOutsideOfFrames.count, 0)
        
        let frame1 = try XCTUnwrap(artboard.frames.first)
        assert(
            frame: frame1, at: document,
            numberOfElements: 10,
            rect: CGRect(x: 2340, y: 0, width: 1170, height: 3407)
        )
        
        let frame2 = try XCTUnwrap(artboard.frames.last)
        
        assert(
            frame: frame2, at: document,
            numberOfElements: 8,
            rect: CGRect(x: 0, y: 0, width: 1170, height: 3372)
        )

        assertFolder(document) {
"""
▿ Images
  - Frame2.png
  - Frame.png
▿ QuickView
  - Preview.heic
- document.json
"""
        }
    }
    
    func test_artboardDocument_whenOpen_shouldLoadImage() throws {
        let document = try Sample().document(name: .artboard, testCase: self)
        
        XCTAssertNotNil(try document.imageFromFirstFrame())
    }
    
    func test_artboardDocument_whenOpenAndSaveWithSameName_shouldLoadImage() throws {
        let document = try Sample().document(name: .artboard, testCase: self)
        
        try document.saveAndRemoveAtTearDown(name: .artboard, testCase: self)
        
        XCTAssertNotNil(try document.imageFromFirstFrame())
    }
    
    // TODO: Test that we can rename document, but image should keep relative path
    
    // MARK: - Restoration DSL

    func assert(
        frame: Frame, at document: VODesignDocument,
        numberOfElements: Int, rect: CGRect,
        file: StaticString = #filePath, line: UInt = #line
    ) {
        XCTAssertEqual(frame.elements.count, numberOfElements, file: file, line: line)
        XCTAssertNotNil(document.artboard.imageLoader.image(for: frame), "should have image", file: file, line: line)
        XCTAssertEqual(frame.frame, rect, "should scale frame", file: file, line: line)
    }
    
#elseif os(iOS) || os(visionOS)
    
    func test_canReadDocumentWithoutFrameFolder() async throws {
        let document = try Sample().document(name: .beta, testCase: self)
        
        await document.read()

        await MainActor.run(body: {
            XCTAssertEqual(document.elements.count, 12)
            XCTAssertNotNil(document.image)
            XCTAssertEqual(document.frameInfo.imageScale, 1, "Old format doesn't know about scale")
        })
    }
    
    func test_canReadFrameFileFormat() async throws {
        let document = try Sample().document(name: .frame, testCase: self)
        
        await document.read()

        await MainActor.run(body: {
            XCTAssertEqual(document.elements.count, 12)
            XCTAssertNotNil(document.image)
            XCTAssertEqual(document.frameInfo.imageScale, 3)
        })
    }
#endif
}

#if os(iOS) || os(visionOS)
extension AppleDocument {
    func read() async {
        await withCheckedContinuation({ continuation in
            open(completionHandler: { _ in
                continuation.resume()
            })
        })
    }
}
#endif

func assertFolder(
    _ document: VODesignDocument,
    matches expected: (() -> String)? = nil,
    file: StaticString = #filePath,
    function: StaticString = #function,
    line: UInt = #line,
    column: UInt = #column
) {
    let url: URL
#if os(macOS)
    url = document.fileURL!
#elseif os(iOS) || os(visionOS)
    url = document.fileURL
#endif
    
    assertInlineSnapshot(
        of: url,
        as: .folderStructure,
        matches: expected,
        file: file,
        function: function,
        line: line,
        column: column
    )
}
