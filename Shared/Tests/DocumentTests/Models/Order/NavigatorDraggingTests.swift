//
//  NavigatorDraggingTests.swift
//
//
//  Created by Mikhail Rubanov on 30.12.2022.
//

import XCTest
import Document
import DocumentTestHelpers
import Canvas
import Samples
import AppKit

class NavigatorDraggingTests: XCTestCase {
    
    var artboard: Artboard!
    var frame: Frame!
    var title: A11yDescription!
    var settingsButton: A11yDescription!
    var tabsContainer: A11yContainer!
    
    var sut: DocumentPresenter!
    var undoManager: UndoManager?
//    let testDocumentName = "Test"
    
    func undo() {
        undoManager?.undo()
    }
    
    func redo() {
        undoManager?.redo()
    }
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        let document: VODesignDocument = try Sample().document(name: FileSample.artboard, testCase: self)
//        let document = VODesignDocument(fileName: testDocumentName)
        
        undoManager = document.undoManager
        sut = DocumentPresenter(document: document)
        
        artboard = document.artboard
//        sut.add(image: Sample().image3x(), origin: .zero)
        
        frame = try XCTUnwrap(artboard.frames.first)
        title = try XCTUnwrap(frame.elements[0] as? A11yDescription)
        settingsButton = try XCTUnwrap(frame.elements[1] as? A11yDescription)
        tabsContainer = try XCTUnwrap(frame.elements.last as? A11yContainer)
    }
    
    override func tearDown() {
        title = nil
        settingsButton = nil
        tabsContainer = nil
        
//        try? VODesignDocument.removeTestDocument(name: testDocumentName)
        
        // Document will be removed at tearDown by Sampler
        super.tearDown()
    }
    
    func testDefaultState() {
        XCTAssertEqual(frame.elements.count, 10)
        
        XCTAssertEqual(titles[0...2], ["Привет, Михаил", "Настройки", "186 додокоинов"])
    }
    
    var titles: [String] {
        frame.elements.compactMap({ element in
            (element as? A11yDescription)?.label
        })
    }
    
    func test_2elementsInFrame_whenDropOnElement_shouldCreateContainer() throws {
        let result = sut.drag(
            title,
            over: settingsButton, 
            insertAtIndex: -1)
        
        XCTAssertTrue(result)
        let newContainer = try XCTUnwrap(frame.elements.first as? A11yContainer, "wrap in container")
        XCTAssertEqual(newContainer.elements.count, 2)
    }
    
    // TODO: Move container on element
    // TODO: Move container on container
    
    func test_2elementsInFrame_whenDropElementAfter2ndElement_shouldRearrange() {
        let result = sut.drag(
            title,
            over: frame,
            insertAtIndex: 2)
        
        XCTAssertTrue(result)
        
        XCTAssertEqual(titles[0...1], ["Настройки", "Привет, Михаил"])
        
        undo()
        XCTAssertEqual(titles[0...1], ["Привет, Михаил", "Настройки"])
        
        redo()
        XCTAssertEqual(titles[0...1], ["Настройки", "Привет, Михаил"])
    }
    
    func test_moveElementOutOfFrame_shouldMoveToArtboardLevel() throws {
        let result = sut.drag(
            title,
            over: nil,
            insertAtIndex: 2)
        
        XCTAssertTrue(result)
        XCTAssertEqual(artboard.elements.count, 3)
        
        let description = try XCTUnwrap(artboard.elements.last as? A11yDescription)
        XCTAssertEqual(description.label, "Привет, Михаил")
        XCTAssertEqual(titles[0...1], ["Настройки", "186 додокоинов"])
    }
    
    // TODO: Move Container out of frame
    // TODO: Move container on frame
    // TODO: Another frame
}
