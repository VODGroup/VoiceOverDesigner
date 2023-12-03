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
        
        // Document will be removed at tearDown by Sampler
        super.tearDown()
    }
    
    func testDefaultState() {
        XCTAssertEqual(frame.elements.count, 4)
        XCTAssertEqual(artboard.elements.count, 1)
        XCTAssertEqual(labels[0...2], ["Title", "Settings", "Coins"])
    }
    
    func test_2elementsInFrame_whenDropOnElement_shouldCreateContainer() throws {
        let result = sut.drag(
            title,
            over: settingsButton, 
            insertAtIndex: -1)
        
        XCTAssertTrue(result)
        
        XCTAssertEqual(labels[0...1], ["Container", "Coins"])
        
        undo()
        XCTAssertEqual(labels[0...2], ["Title", "Settings", "Coins"])
        
        redo()
        let newContainer2 = try XCTUnwrap(frame.elements.first as? A11yContainer, "wrap in container")
        XCTAssertEqual(newContainer2.elements.count, 2)
        XCTAssertEqual(labels[0...1], ["Container", "Coins"])
    }

    func test_2elementsInFrame_whenDropElementAfter2ndElement_shouldRearrange() {
        let result = sut.drag(
            title,
            over: frame,
            insertAtIndex: 2)
        
        XCTAssertTrue(result)
        
        XCTAssertEqual(labels[0...1], ["Settings", "Title"])
        
        undo()
        XCTAssertEqual(labels[0...1], ["Title", "Settings"])
        
        redo()
        XCTAssertEqual(labels[0...1], ["Settings", "Title"])
    }
    
    func test_moveElementAfterFrame_shouldMoveToArtboardLevel() throws {
        let result = sut.drag(
            title,
            over: nil,
            insertAtIndex: 1) // After frame
        
        XCTAssertTrue(result)
        XCTAssertEqual(artboard.elements.count, 2, "Add element on artboard's level")
        XCTAssertEqual(artboard.elements.last?.label, "Title")
        XCTAssertEqual(labels[0...1], ["Settings", "Coins"])
        
        undo()
        XCTAssertEqual(artboard.elements.count, 1, "Only frame")
        XCTAssertEqual(artboard.elements.last?.label, "Frame")
        XCTAssertEqual(labels[0...2], ["Title", "Settings", "Coins"])
        
        redo()
        XCTAssertEqual(artboard.elements.last?.label, "Title")
        XCTAssertEqual(labels[0...1], ["Settings", "Coins"])
    }
    
    func test_moveElementOutOfFrame_shouldMoveToArtboardLevel() throws {
        let result = sut.drag(
            title,
            over: nil,
            insertAtIndex: -1)
        
        XCTAssertTrue(result)
        XCTAssertEqual(artboard.elements.count, 2, "Add element on artboard's level")
        XCTAssertEqual(artboard.elements.last?.label, "Title")
        XCTAssertEqual(labels[0...1], ["Settings", "Coins"])
        
        undo()
        XCTAssertEqual(artboard.elements.count, 1)
        XCTAssertEqual(artboard.elements.last?.label, "Frame")
        XCTAssertEqual(labels[0...2], ["Title", "Settings", "Coins"])
        
        redo()
        XCTAssertEqual(artboard.elements.last?.label, "Title")
        XCTAssertEqual(labels[0...1], ["Settings", "Coins"])
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
    
    var labels: [String] {
        frame.elements.map(\.label)
    }
}
