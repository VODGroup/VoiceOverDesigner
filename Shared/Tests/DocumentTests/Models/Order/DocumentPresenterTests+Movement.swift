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
    var coins: A11yDescription!
    var gift: A11yDescription!
    
    var sut: DocumentPresenter!
    var undoManager: UndoManager?
    let testDocumentName = "Test"
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        let document = VODesignDocument.testDocument(name: testDocumentName, testCase: self)
        
        undoManager = document.undoManager
        sut = DocumentPresenter(document: document)
        
        artboard = document.artboard
        
        sut.disableUndoRegistration()
        sut.add(image: Sample().image3x(), origin: .zero)
        
        frame = try XCTUnwrap(artboard.frames.first)
        frame.label = "Frame"
        
        title = A11yDescription.testMake(label: "Title")
        settingsButton = A11yDescription.testMake(label: "Settings")
        coins = A11yDescription.testMake(label: "Coins")
        gift = A11yDescription.testMake(label: "Gift")
        
        sut.append(control: title)
        sut.append(control: settingsButton)
        sut.append(control: coins)
        sut.append(control: gift)
        sut.enableUndoRegistration()
    }
    
    override func tearDown() {
        title = nil
        settingsButton = nil
        
        try? VODesignDocument.removeTestDocument(name: testDocumentName)
        
        super.tearDown()
    }
    
    func assertDefault(
        _ message: String = "Default structure",
        file: StaticString = #filePath,
        function: StaticString = #function,
        line: UInt = #line,
        column: UInt = #column
    ) {
        artboard.assert(
            message,
            matches: {
"""
Frame:
 Title
 Settings
 Coins
 Gift
"""
            },
            file: file, function: function, line: line, column: column)
    }
    
    // MARK: - Wrapping
    
    func assertUndoToDefaultAndRedo(
        _ expected: (() -> String)? = nil,
        file: StaticString = #filePath,
        function: StaticString = #function,
        line: UInt = #line,
        column: UInt = #column
    ) {
        artboard.assert(
            "after Action",
            matches: expected,
            file: file, function: function, line: line, column: column)
        
        undo()
        assertDefault(
            "after Undo",
            file: file, function: function, line: line, column: column)
        
        redo()
        artboard.assert(
            "after Redo",
            matches: expected,
            file: file, function: function, line: line, column: column)
    }
    
    func testDefaultState() {
        assertDefault()
    }
    
    func test_2elementsInFrame_whenDropOnElement_shouldCreateContainer() throws {
        let result = sut.drag(
            title,
            over: settingsButton, 
            insertAtIndex: -1)
        
        XCTAssertTrue(result)
        assertUndoToDefaultAndRedo {
"""
Frame:
 Coins
 Container:
  Title
  Settings
 Gift
"""
        }
        
        // TODO: Coins should be after container
    }
    
    func test_2elementsInFrame_whenDropSecondElementOnFirst_shouldCreateContainer() throws {
        let result = sut.drag(
            settingsButton,
            over: title,
            insertAtIndex: -1)
        
        XCTAssertTrue(result)
        assertUndoToDefaultAndRedo {
"""
Frame:
 Container:
  Title
  Settings
 Coins
 Gift
"""}
    }
    
    func test_moveLastElementOnFirstElement_shouldCreateContainer() throws {
        let result = sut.drag(
            gift,
            over: title,
            insertAtIndex: -1)
        
        XCTAssertTrue(result)
        assertUndoToDefaultAndRedo {
"""
Frame:
 Container:
  Title
  Gift
 Settings
 Coins
"""
        }
    }

    // MARK: Moving
    func test_2elementsInFrame_whenDropElementAfter2ndElement_shouldRearrange() {
        let result = sut.drag(
            title,
            over: frame,
            insertAtIndex: 2)
        
        XCTAssertTrue(result)
        assertUndoToDefaultAndRedo{
"""
Frame:
 Settings
 Title
 Coins
 Gift
"""}
    }
    
    func test_moveElementAfterFrame_shouldMoveToArtboardLevel() throws {
        let result = sut.drag(
            title,
            over: nil,
            insertAtIndex: 1) // After frame
        
        XCTAssertTrue(result)
        assertUndoToDefaultAndRedo{
"""
Frame:
 Settings
 Coins
 Gift
Title
"""}
    }
    
    func test_moveElementOutOfFrame_shouldMoveToArtboardLevel() throws {
        let result = sut.drag(
            title,
            over: nil,
            insertAtIndex: -1)
        
        XCTAssertTrue(result)
        assertUndoToDefaultAndRedo{
"""
Frame:
 Settings
 Coins
 Gift
Title
"""
        }
    }
    
    
    // TODO: Move container on element –> Move container and wrap item in it
    // TODO: Move container on container -> Place second container in first. Nested container should be supported
    
    // TODO: Move container on frame -> Apped
    // TODO: Move container inside frame -> Ok
    // TODO: Can't place frame on frame
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
