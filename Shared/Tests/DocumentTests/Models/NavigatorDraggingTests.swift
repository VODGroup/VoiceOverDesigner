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
    
    var frame: Frame!
    var title: A11yDescription!
    var settingsButton: A11yDescription!
    var tabsContainer: A11yContainer!
    
    var sut: DocumentPresenter!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        let profileSample: VODesignDocument = try Sample().document(name: FileSample.artboard, testCase: self)
        
        sut = DocumentPresenter(document: profileSample)
        
        frame = try XCTUnwrap(profileSample.artboard.frames.first)
        title = try XCTUnwrap(frame.elements[0] as? A11yDescription)
        settingsButton = try XCTUnwrap(frame.elements[1] as? A11yDescription)
        tabsContainer = try XCTUnwrap(frame.elements.last as? A11yContainer)
    }
    
    override func tearDown() {
        title = nil
        settingsButton = nil
        tabsContainer = nil
        
        // Document will be removed at tearDown by Sampler
        super.tearDown()
    }
    
    func testDefaultState() {
        XCTAssertEqual(frame.elements.count, 10)
        
        XCTAssertEqual(titles, ["Привет, Михаил", "Настройки", "186 додокоинов", "История заказов", "Адреса доставки", "Мои акции", "Акции", "Миссии", "Сделайте три заказа с большой пиццей"])
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
        XCTAssertEqual(titles[0...1], ["Привет, Михаил", "Настройки"])
        
        let result = sut.drag(
            title,
            over: frame,
            insertAtIndex: 2)
        
        XCTAssertTrue(result)
        
        XCTAssertEqual(titles[0...1], ["Настройки", "Привет, Михаил"])
    }
    
    // TODO: Move Container out of frame
    // TODO: Move container on frame
    // TODO: Another frame
}
