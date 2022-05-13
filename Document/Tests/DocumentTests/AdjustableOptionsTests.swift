//
//  AdjustableOptionsTests.swift
//  
//
//  Created by Mikhail Rubanov on 14.05.2022.
//

import XCTest
@testable import Document

class AdjustableOptionsTests: XCTestCase {

    func test_whenRemoveLastSelectedIndex_shouldMoveIndexToLastElement() {
        var sut = AdjustableOptions(
            options: ["Маленькая", "Средняя", "Большная"],
            currentIndex: 2) // Last

        sut.options.remove(at: 2)
        
        XCTAssertEqual(sut.currentIndex, 1)
    }
    
    func test_whenRemoveSelectedIndex_shouldMoveIndexToNextElement() {
        var sut = AdjustableOptions(
            options: ["Маленькая", "Средняя", "Большная"],
            currentIndex: 0)
        
        sut.options.remove(at: 0)
        
        XCTAssertEqual(sut.currentIndex, 0)
    }
}
