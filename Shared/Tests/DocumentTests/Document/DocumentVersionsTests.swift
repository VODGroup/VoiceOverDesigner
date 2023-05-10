import XCTest
@testable import Document
import DocumentTestHelpers

import SnapshotTesting
import FolderSnapshot

typealias FileSample = String
extension FileSample {
    static var beta = "BetaVersionFormat"
    static var frame = "FrameVersionFormat"
    static var artboard = "ArtboardFormat"
}

final class DocumentVersionsTests: XCTestCase {

#if os(macOS)
    
    // MARK: - Beta format
    func test_betaDocument_whenRead_shouldUpdateStructure() throws {
        let document = try XCTUnwrap(Sample().document(name: .beta, testCase: self))
        
        // Read on file creation

        assertSnapshot(matching: document.fileURL!, as: .folderStructure)
    }
    
    func test_betaDocument_whenRead_shouldMoveElementsToFirstFrame() throws {
        let document = try XCTUnwrap(Sample().document(name: .beta, testCase: self))
        
        let frame = try XCTUnwrap(document.artboard.frames.first)
        
        assert(
            frame: frame, at: document,
            numberOfElements: 12,
            rect: CGRect(x: 0, y: 0, width: 390, height: 844)
        )
        
        assertSnapshot(matching: document.fileURL!, as: .folderStructure)
    }
    
    // MARK: - Frame version
    func test_frameDocument_whenRead_shouldUpdateStructure() throws {
        let document = try XCTUnwrap(Sample().document(name: .frame, testCase: self))
        
        // Read on file creation
        
        assertSnapshot(matching: document.fileURL!, as: .folderStructure)
    }
    
    func test_frameDocument_whenSave_shouldUpdateStructure() throws {
        let document = try XCTUnwrap(Sample().document(name: .frame, testCase: self))

        saveDocumentAndRemoveAtTearDown(document: document, name: "FrameFormatNewStructure")
        
        assertSnapshot(matching: document.fileURL!, as: .folderStructure)
    }
    
    func test_frameDocument_whenRead_shouldReadAsFirstFrame() throws {
        let document = try XCTUnwrap(Sample().document(name: .frame, testCase: self))
        
        let frame = try XCTUnwrap(document.artboard.frames.first)
        
        assert(
            frame: frame, at: document,
            numberOfElements: 12,
            rect: CGRect(x: 0, y: 0, width: 390, height: 844)
        )

        assertSnapshot(matching: document.fileURL!, as: .folderStructure)
    }
    
    // MARK: Artboard version
    func test_artboardDocument_whenRead_shouldUpdateStructure() throws {
        let document = try XCTUnwrap(Sample().document(name: .artboard, testCase: self))
        
        // Read on file creation
        
        assertSnapshot(matching: document.fileURL!, as: .folderStructure)
    }
    
    func test_artboardDocument_whenSave_shouldUpdateStructure() throws {
        let document = try XCTUnwrap(Sample().document(name: .artboard, testCase: self))

        saveDocumentAndRemoveAtTearDown(document: document, name: "ArtboardFormatNewStructure")
        
        assertSnapshot(matching: document.fileURL!, as: .folderStructure)
    }
    
    func test_artboardDocument_whenRead_shouldReadContent() throws {
        let document = try XCTUnwrap(Sample().document(name: .artboard, testCase: self))
        
        let artboard = document.artboard
        XCTAssertEqual(artboard.frames.count, 2)
        XCTAssertEqual(artboard.controlsWithoutFrames.count, 0)
        
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

        assertSnapshot(matching: document.fileURL!, as: .folderStructure)
    }
    
    // MARK: - Restoration DSL
    private let fileManager = FileManager.default
    
    private func saveDocumentAndRemoveAtTearDown(document: VODesignDocument, name: String) {
        document.save(testCase: self, fileName: name)
        addTeardownBlock {
            let testFilePath = Sample().resourcesPath().appendingPathComponent("\(name).vodesign")
            try? self.fileManager.removeItem(at: testFilePath)
        }
    }

    func assert(
        frame: Frame, at document: VODesignDocument,
        numberOfElements: Int, rect: CGRect,
        file: StaticString = #filePath, line: UInt = #line
    ) {
        XCTAssertEqual(frame.elements.count, numberOfElements, file: file, line: line)
        XCTAssertNotNil(document.artboard.imageLoader.image(for: frame), file: file, line: line)
        XCTAssertEqual(frame.frame, rect, "should scale frame", file: file, line: line)
    }
#elseif os(iOS)
    
    func test_canReadDocumentWithoutFrameFolder() async throws {
        let document = try XCTUnwrap(Sample().document(name: .beta))
        
        await document.read()

        await MainActor.run(body: {
            XCTAssertEqual(document.elements.count, 12)
            XCTAssertNotNil(document.image)
            XCTAssertEqual(document.frameInfo.imageScale, 1, "Old format doesn't know about scale")
        })
    }
    
    func test_canReadFrameFileFolrmat() async throws {
        let document = try XCTUnwrap(Sample().document(name: .frame))
        
        await document.read()

        await MainActor.run(body: {
            XCTAssertEqual(document.elements.count, 12)
            XCTAssertNotNil(document.image)
            XCTAssertEqual(document.frameInfo.imageScale, 3)
        })
    }
#endif
}

#if os(iOS)
extension Document {
    func read() async {
        await withCheckedContinuation({ continuation in
            open(completionHandler: { _ in
                continuation.resume()
            })
        })
    }
}
#endif
