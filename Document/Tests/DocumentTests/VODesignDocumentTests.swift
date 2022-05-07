//
//  VODesignDocumentTests.swift
//  
//
//  Created by Mikhail Rubanov on 01.05.2022.
//

import XCTest
import Document

#if os(macOS)
class VODesignDocumentTests: XCTestCase {

    let path = FileManager.default.urls(
        for: .cachesDirectory,
        in: .userDomainMask).first!
    
    let fileName = "TestFile"
    
    var fileURL: URL!
    
    override func setUp() {
        super.setUp()
        fileURL = path.appendingPathComponent("TestFile.vodesign", isDirectory: false)
    }
    
    override func tearDownWithError() throws {
        try FileManager.default
            .removeItem(at: fileURL)
    }

    func testWhenSaveOneDocument_andReadAnotherWithSameName_shouldKeepObjects() throws {
        var document: VODesignDocument? = VODesignDocument(file: fileURL)
        document!.controls = [A11yDescription.testMake(label: "Label1"),
                             A11yDescription.testMake(label: "Label2")]
        document!.save()
        document = nil
        
        let document2 = VODesignDocument(
            fileName: fileName,
            rootPath: path)
        try document2.read()
    
        XCTAssertEqual(document2.controls.count, 2)
    }
}

extension VODesignDocument {
    public func save() {
        save(to: fileURL!, ofType: Self.vodesign, for: .saveOperation) { error in
            Swift.print(error)
            // TODO: Handle
        }
    }
    
    public func read() throws {
        try read(from: fileURL!, ofType: Self.vodesign)
    }
}
#endif
