//
//  VODesignDocumentTests.swift
//  
//
//  Created by Mikhail Rubanov on 01.05.2022.
//

import XCTest
import Document
import DocumentTestHelpers

#if os(macOS)
extension VODesignDocument {
    static func with2Controls(name: String, testCase: XCTestCase) -> VODesignDocument {
        let document = VODesignDocument.testDocument(name: name, testCase: testCase)
        document.controls = [A11yDescription.testMake(label: "Label1"),
                             A11yDescription.testMake(label: "Label2")]
        return document
    }
}

class VODesignDocumentPersistanceTests: XCTestCase {
    
    func testWhenSaveOneDocument_andReadAnotherWithSameName_shouldKeepObjects() throws {
        throw XCTSkip("Force-unwrap crashes")
        let fileName = "TestFile1"
        
        var document: VODesignDocument?
        
        XCTContext.runActivity(named: "Create document") { _ in
            document = VODesignDocument.with2Controls(name: fileName, testCase: self)
            document!.controls = [A11yDescription.testMake(label: "Label1"),
                                  A11yDescription.testMake(label: "Label2")]
        }
        
        XCTContext.runActivity(named: "Save document and remove from memory") { _ in
            document!.save(testCase: self, fileName: fileName)
            addTeardownBlock {
                try! VODesignDocument.removeTestDocument(name: fileName)
            }
            document = nil
        }
        
        XCTContext.runActivity(named: "Read document with same name") { _ in
            let document2 = VODesignDocument(
                fileName: fileName,
                rootPath: VODesignDocument.path)
//            try? document2.read()
            
            XCTAssertEqual(document2.controls.count, 2, "Should contain controls")
        }
    }
    
    func testWhenSaveNewDocument_shouldHaveCorrectExtensions() throws {
        let document = VODesignDocument.with2Controls(name: "TestFile2", testCase: self)
        
        XCTContext.runActivity(named: "Save document to disk") { _ in
            document.save(testCase: self, fileName: "TestFile2")
            addTeardownBlock {
                try! VODesignDocument.removeTestDocument(name: "TestFile2")
            }
        }
        
        XCTAssertEqual(document.fileURL?.pathExtension, "vodesign")
    }
}

#endif
