//
//  NavigatorDraggingTests.swift
//
//
//  Created by Mikhail Rubanov on 30.12.2022.
//

import XCTest
import Document
import DocumentTestHelpers
import Samples
import AppKit

class DocumentPresenterTests_Movement: XCTestCase {
    
    var artboard: Artboard!
    var frame: Frame!
    var title: A11yDescription!
    var settingsButton: A11yDescription!
    
    var sut: DocumentPresenter!
    var undoManager: UndoManager?
    let testDocumentName = "Test"
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        let document = VODesignDocument.testDocument(name: testDocumentName, testCase: self)
        
        undoManager = document.undoManager
        sut = DocumentPresenter(document: document)
        
        artboard = document.artboard
        
        undoManager?.disableUndoRegistration()
        sut.add(image: Sample().image3x(), origin: .zero)
        
        frame = try XCTUnwrap(artboard.frames.first)
        frame.label = "Frame"
        
        title = A11yDescription.testMake(label: "Title")
        settingsButton = A11yDescription.testMake(label: "Settings")
        
        sut.append(control: title)
        sut.append(control: settingsButton)
        sut.append(control: A11yDescription.testMake(label: "Coins"))
        sut.append(control: A11yDescription.testMake(label: "Gift"))
        undoManager?.enableUndoRegistration()
    }
    
    override func tearDown() {
        title = nil
        settingsButton = nil
        
        try? VODesignDocument.removeTestDocument(name: testDocumentName)
        
        super.tearDown()
    }
    
    func testDefaultState() {
        artboard.assert(
            labels: "Frame: Title, Settings, Coins, Gift"
        )
    }
    
    func test_2elementsInFrame_whenDropOnElement_shouldCreateContainer() throws {
        let result = sut.drag(
            title,
            over: settingsButton, 
            insertAtIndex: -1)
        
        XCTAssertTrue(result)
        artboard.assert(
            labels: "Frame: Container: Title, Settings;, Coins, Gift" // Gift on Frame's level
        )
        
        undo()
        artboard.assert(
            labels: "Frame: Title, Settings, Coins, Gift"
        )
        
        redo()
        artboard.assert(
            labels: "Frame: Container: Title, Settings;, Coins, Gift" // Gift on Frame's level
        )
    }

    func test_2elementsInFrame_whenDropElementAfter2ndElement_shouldRearrange() {
        let result = sut.drag(
            title,
            over: frame,
            insertAtIndex: 2)
        
        XCTAssertTrue(result)
        
        XCTAssertEqual(labelsInFrame[0...1], ["Settings", "Title"])
        
        undo()
        artboard.assert(
            labels: "Frame: Title, Settings, Coins, Gift"
        )
        
        redo()
        XCTAssertEqual(labelsInFrame[0...1], ["Settings", "Title"])
    }
    
    func test_moveElementAfterFrame_shouldMoveToArtboardLevel() throws {
        let result = sut.drag(
            title,
            over: nil,
            insertAtIndex: 1) // After frame
        
        XCTAssertTrue(result)
        artboard.assert(
            labels: "Frame: Settings, Coins, Gift",
            "Title"
        )
        
        undo()
        artboard.assert(
            labels: "Frame: Title, Settings, Coins, Gift"
        )
        
        redo()
        artboard.assert(
            labels: "Frame: Settings, Coins, Gift",
            "Title"
        )
    }
    
    func test_moveElementOutOfFrame_shouldMoveToArtboardLevel() throws {
        let result = sut.drag(
            title,
            over: nil,
            insertAtIndex: -1)
        
        XCTAssertTrue(result)
        artboard.assert(
            labels: "Frame: Settings, Coins, Gift",
            "Title"
        )
        
        undo()
        artboard.assert(
            labels: "Frame: Title, Settings, Coins, Gift"
        )
        
        redo()
        artboard.assert(
            labels: "Frame: Settings, Coins, Gift",
            "Title"
        )
    }
    
    
    // TODO: Move container on element
    // TODO: Move container on container
    // TODO: Move Container out of frame
    // TODO: Move container on frame
    // TODO: Another frame
    // TODO: Test that empty containers are removed but will be restored by undo
    
    
    // MARK: - DSL
    
    func undo() {
        undoManager?.undo()
    }
    
    func redo() {
        undoManager?.redo()
    }
    
    var labelsInFrame: [String] {
        frame.elements.map(\.label)
    }
}
