//
//  VODesignDocumentTests.swift
//  
//
//  Created by Mikhail Rubanov on 01.05.2022.
//

import XCTest
import Document

#if os(macOS)
extension VODesignDocument {
    static func with2Controls(name: String) -> VODesignDocument {
        let document = VODesignDocument.testDocument(name: name)
        document.controls = [A11yDescription.testMake(label: "Label1"),
                             A11yDescription.testMake(label: "Label2")]
        return document
    }
}


class VODesignDocumentPersistanceTests: XCTestCase {
    
    func testWhenSaveOneDocument_andReadAnotherWithSameName_shouldKeepObjects() throws {
        let fileName = "TestFile1"
        
        var document: VODesignDocument?
        
        XCTContext.runActivity(named: "Create document") { _ in
            document = VODesignDocument.with2Controls(name: fileName)
            document!.controls = [A11yDescription.testMake(label: "Label1"),
                                  A11yDescription.testMake(label: "Label2")]
        }
        
        XCTContext.runActivity(named: "Save document and remove from memory") { _ in
            document!.save()
            addTeardownBlock {
                try! VODesignDocument.removeTestDocument(name: fileName)
            }
            document = nil
        }
        
        XCTContext.runActivity(named: "Read document with same name") { _ in
            let document2 = VODesignDocument(
                fileName: fileName,
                rootPath: VODesignDocument.path)
            try? document2.read()
            
            XCTAssertEqual(document2.controls.count, 2, "Should contain controls")
        }
    }
    
    func testWhenSaveNewDocument_shouldHaveCorrectExtensions() throws {
        let document = VODesignDocument.with2Controls(name: "TestFile2")
        
        XCTContext.runActivity(named: "Save document to disk") { _ in
            document.save()
            addTeardownBlock {
                try! VODesignDocument.removeTestDocument(name: "TestFile2")
            }
        }
        
        XCTAssertEqual(document.fileURL?.pathExtension, "vodesign")
    }
}

class VODesignDocumentUndoTests: XCTestCase {
    
    func test_undoForArray() {
        let document = VODesignDocument.with2Controls(name: "TestFile1")
        XCTAssertEqual(document.controls.count, 2)
        
        document.undoManager?.undo()
        XCTAssertTrue(document.controls.isEmpty)
        
        document.undoManager?.redo()
        XCTAssertEqual(document.controls.count, 2)
    }
}
#endif
