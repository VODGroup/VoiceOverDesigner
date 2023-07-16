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
        document.artboard.controlsWithoutFrames = [
            A11yDescription.testMake(label: "Label1"),
            A11yDescription.testMake(label: "Label2"),
        ]
        return document
    }
    
    static func with2ControlsInFrame(name: String, testCase: XCTestCase) -> VODesignDocument {
        let document = VODesignDocument.testDocument(name: name, testCase: testCase)
        document.artboard.frames = [Frame(
            label: "Frame1",
            imageName: "Frame1.png",
            frame: .zero,
            elements: [
                A11yDescription.testMake(label: "Label1"),
                A11yDescription.testMake(label: "Label2"),
            ])
        ]
        return document
    }
}

class VODesignDocumentPersistanceTests: XCTestCase {
    
    private func createDocumentAndSave(
        _ documentSetup: (_ fileName: String) -> VODesignDocument,
        andLoad: (VODesignDocument) -> Void
    ) throws {
        let fileName = "TestFile1"
        
        var document: VODesignDocument?
        
        XCTContext.runActivity(named: "Create document") { _ in
            document = documentSetup(fileName)
        }
        
        try XCTContext.runActivity(named: "Save document and remove from memory") { _ in
            try document!.save(name: fileName, testCase: self)
            addTeardownBlock {
                try! VODesignDocument.removeTestDocument(name: fileName)
            }
            document = nil
        }
        
        XCTContext.runActivity(named: "Read document with same name") { _ in
            let document2 = VODesignDocument(
                fileName: fileName,
                rootPath: VODesignDocument.path)
            
            andLoad(document2)
        }
    }
    
    func test_saveDocumentWithElementsNotInFrames_whenReadByName_shouldKeepObjects() throws {
        try createDocumentAndSave { fileName in
            VODesignDocument.with2Controls(name: fileName, testCase: self)
        } andLoad: { document in
            XCTAssertEqual(document.artboard.controlsWithoutFrames.count, 2, "Should contain controls")
        }
    }
    
    func test_saveDocumentWithElementsInFrames_whenReadByName_shouldKeepObjects() throws {
        try createDocumentAndSave { fileName in
            VODesignDocument.with2ControlsInFrame(name: fileName, testCase: self)
        } andLoad: { document in
            let frames = document.artboard.frames
            XCTAssertEqual(frames.count, 1)
            XCTAssertEqual(frames.first?.elements.count, 2, "Should contain controls")
        }
    }
    
    // TODO: Add test that check content of artboards
    
    func testWhenSaveNewDocument_shouldHaveCorrectExtensions() throws {
        let document = VODesignDocument.with2Controls(name: "TestFile2", testCase: self)
        
        try document.saveAndRemoveAtTearDown(name: "TestFile2", testCase: self)
        
        XCTAssertEqual(document.fileURL?.pathExtension, "vodesign")
    }
}

#endif
