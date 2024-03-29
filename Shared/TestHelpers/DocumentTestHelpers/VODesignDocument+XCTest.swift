import Foundation
import Document
import XCTest

extension VODesignDocument {
    public static func removeTestDocument(name: String) throws {
        try FileManager.default
            .removeItem(at: testURL(name: name))
    }
    
    public static func testURL(name: String) -> URL {
        return Self.cacheFolder
            .appendingPathComponent("\(name).vodesign",
                                    isDirectory: false)
    }
    
    public static var cacheFolder: URL {
        FileManager.default.urls(
            for: .cachesDirectory,
            in: .userDomainMask).first!
    }
}

#if canImport(AppKit)

extension VODesignDocument {
    public static func testDocument(
        name: String,
        testCase: XCTestCase
    ) -> VODesignDocument {
        if !FileManager.default.fileExists(atPath: testURL(name: name).path) {
            FileManager.default.createFile(atPath: testURL(name: name).path, contents: Data())
        }
        let document = VODesignDocument(file: testURL(name: name))
        return document
    }
    
    public func save(name: String, testCase: XCTestCase) throws {
        let expectation = testCase.expectation(description: "Save file")
        
        var resultError: Error?
        save(to: Self.testURL(name: name), ofType: vodesign, for: .saveOperation) { error in
            resultError = error

            expectation.fulfill()
        }
        
        testCase.wait(for: [expectation], timeout: 1)
        
        if let resultError {
            throw resultError
        }
    }
    
    public func saveAndRemoveAtTearDown(name: String, testCase: XCTestCase) throws {
        testCase.addTeardownBlock {
            let testFilePath = await VODesignDocument.testURL(name: name)
            try FileManager.default.removeItem(at: testFilePath)
        }
        
        try save(name: name, testCase: testCase)
    }
    
//    public func read() throws {
//        try read(from: fileURL!, ofType: vodesign)
//    }
}
#endif

public extension VODesignDocumentProtocol {
    func firstFrame() throws -> Frame {
        try XCTUnwrap(artboard.frames.first)
    }
    
    func imageFromFirstFrame() throws -> Image? {
        let frame = try firstFrame()
        let image = artboard.imageLoader?.image(for: frame)
        return image
    }
}
