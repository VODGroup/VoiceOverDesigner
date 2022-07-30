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
    override func tearDownWithError() throws {
        try VODesignDocument.removeTestDocument(name: "TestFile")

    }
    
    func testWhenSaveNewDocument_shouldHaveSameExtensions() throws {
        var document: VODesignDocument? = VODesignDocument.testDocument(name: "TestFile")
        document!.controls = [A11yDescription.testMake(label: "Label3"),
                              A11yDescription.testMake(label: "Label4")]
        document!.save()
        
        
        XCTAssertEqual(document?.fileURL?.pathExtension, "vodesign")
    }
}

class VODesignDocumentPersistanceTests: VODesignDocumentTests {
    override func tearDownWithError() throws {
        try VODesignDocument.removeTestDocument(name: "TestFile")
    }
    
    func testWhenSaveOneDocument_andReadAnotherWithSameName_shouldKeepObjects() throws {
        var document: VODesignDocument? = VODesignDocument.testDocument(name: "TestFile")
        document!.controls = [A11yDescription.testMake(label: "Label1"),
                              A11yDescription.testMake(label: "Label2")]
        document!.save()
        document = nil
        
        let document2 = VODesignDocument(
            fileName: "TestFile",
            rootPath: VODesignDocument.path)
        try document2.read()
        
        XCTAssertEqual(document2.controls.count, 2)
    }
}

class VODesignDocumentUndoTests: VODesignDocumentTests {
    
    func test_undoForArray() {
        let document = VODesignDocument.testDocument(name: "TestFile")
        document.controls = [A11yDescription.testMake(label: "Label1"),
                             A11yDescription.testMake(label: "Label2")]
        
        document.undoManager?.undo()
        XCTAssertTrue(document.controls.isEmpty)
        
        document.undoManager?.redo()
        XCTAssertEqual(document.controls.count, 2)
    }
}
#endif
