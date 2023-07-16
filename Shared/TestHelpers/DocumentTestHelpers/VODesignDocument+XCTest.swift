import Foundation
import Document
import XCTest

extension VODesignDocument {
    public static func removeTestDocument(name: String) throws {
        try FileManager.default
            .removeItem(at: testURL(name: name))
    }
    
    public static func testURL(name: String) -> URL {
        return Self.path
            .appendingPathComponent("\(name).vodesign",
                                    isDirectory: false)
    }
    
    public static var path: URL {
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
    
    public func save(testCase: XCTestCase, fileName: String) throws {
        let expectation = testCase.expectation(description: "Save file")
        
        var resultError: Error?
        save(to: Self.testURL(name: fileName), ofType: vodesign, for: .saveOperation) { error in
            resultError = error

            expectation.fulfill()
        }
        
        testCase.wait(for: [expectation], timeout: 1)
        
        if let resultError {
            throw resultError
        }
    }
    
//    public func read() throws {
//        try read(from: fileURL!, ofType: vodesign)
//    }
}
#endif
