//
//  AdjustableOptionsTests.swift
//  
//
//  Created by Mikhail Rubanov on 14.05.2022.
//

import XCTest
@testable import Document

class AdjustableOptionsTests: XCTestCase {

    func test_whenRemoveLatestSelectedIndex_shouldMoveIndexToLastElement() {
        var sut = AdjustableOptions(
            options: ["Маленькая", "Средняя", "Большная"],
            currentIndex: 2) // Last

        sut.remove(at: 2)
        
        XCTAssertEqual(sut.currentIndex, 1)
    }
    
    func test_whenRemoveSelectedIndex_shouldMoveIndexToNextElement() {
        var sut = AdjustableOptions(
            options: ["Маленькая", "Средняя", "Большная"],
            currentIndex: 0)
        
        sut.remove(at: 0)
        
        XCTAssertEqual(sut.currentIndex, 0)
    }
    
    func test_whenAddFirstOption_shouldSelect() {
        var sut = AdjustableOptions(options: [])
        
        sut.add()
        
        XCTAssertEqual(sut.options, [""])
        XCTAssertEqual(sut.currentIndex, 0)
    }
    
    func test_whenRemoveLastSelectedSetting_shouldResetCurrenSelection() {
        var sut = AdjustableOptions(options: ["First"], currentIndex: 0)
        
        sut.remove(at: 0)
        
        XCTAssertNil(sut.currentIndex)
    }
    
    func test_accessibillityIncrement_shouldChangeValueAndIndex() {
        var sut = AdjustableOptions(options: ["First", "Second"], currentIndex: 0)
        sut.accessibilityIncrement()
        XCTAssertEqual(sut.currentIndex, 1)
        XCTAssertEqual(sut.currentValue, "Second")
    }
    
    func test_accessibillityIncrement_shouldnotChangeValueAndIndex() {
        var sut = AdjustableOptions(options: ["First"], currentIndex: 0)
        sut.accessibilityIncrement()
        XCTAssertEqual(sut.currentIndex, 0)
        XCTAssertEqual(sut.currentValue, "First")
    }
    
    func test_accessibillityDecrement_shouldChangeValueAndIndex() {
        var sut = AdjustableOptions(options: ["First", "Second"], currentIndex: 1)
        sut.accessibilityDecrement()
        XCTAssertEqual(sut.currentIndex, 0)
        XCTAssertEqual(sut.currentValue, "First")
    }
    
    func test_accessibillityDecrement_shouldnotChangeValueAndIndex() {
        var sut = AdjustableOptions(options: ["First"], currentIndex: 0)
        sut.accessibilityDecrement()
        XCTAssertEqual(sut.currentIndex, 0)
        XCTAssertEqual(sut.currentValue, "First")
    }
}
