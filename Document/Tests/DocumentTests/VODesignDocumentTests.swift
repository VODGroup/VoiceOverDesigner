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
    
    override func tearDownWithError() throws {
        try FileManager.default
            .removeItem(at: path.appendingPathComponent(fileName))
    }

    func testWhenSaveOneDocument_andReadAnotherWithSameName_shouldKeepObjects() throws {
        
        
        var document: VODesignDocument? = VODesignDocument(
            fileName: fileName, rootPath: path)
        
        document!.controls = [A11yDescription.testMake(label: "Label1"),
                             A11yDescription.testMake(label: "Label2")]
        document!.save()
        document = nil
        
        let document2 = VODesignDocument(
            fileName: fileName,
            rootPath: path)
        document2.read()
    
        XCTAssertEqual(document2.controls.count, 2)
    }
}
#endif
