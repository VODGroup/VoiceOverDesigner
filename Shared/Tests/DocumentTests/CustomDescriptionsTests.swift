//
//  File.swift
//  
//
//  Created by Andrey Plotnikov on 24.08.2022.
//


@testable import Document
import XCTest

class CustomDescriptionsTests: XCTestCase {
    
    func test_addNewCustomDescription_shouldChangeCountAndHaveActionName() throws {
        var sut = A11yCustomDescriptions.testMake(descriptions: [])
        sut.addNewCustomDescription(.testMake(number: 0))
        XCTAssertTrue(!sut.descriptions.isEmpty)
        XCTAssertEqual(sut.descriptions.count, 1)
        XCTAssertEqual(sut.descriptions[0].label, "Label 0")
        XCTAssertEqual(sut.descriptions[0].value, "Value 0")
    }
    
    func test_removeAtIndex_shouldChangeCount() throws {
        var sut = A11yCustomDescriptions.testMake(descriptions: [.testMake(number: 0), .testMake(number: 1)])
        
        sut.remove(at: 0)
        XCTAssertTrue(!sut.descriptions.isEmpty)
        XCTAssertEqual(sut.descriptions.count, 1)
        XCTAssertEqual(sut.descriptions[0].label, "Label 1")
        XCTAssertEqual(sut.descriptions[0].value, "Value 1")

    }
    
    func test_updateAtIndex_shouldChangeName() throws {
        var sut = A11yCustomDescriptions.testMake(descriptions: [.testMake(number: 0), .testMake(number: 2)])
        sut.update(at: 0, with: .testMake(number: 2))
        XCTAssertTrue(!sut.descriptions.isEmpty)
        XCTAssertEqual(sut.descriptions.count, 2)
        XCTAssertEqual(sut.descriptions[0].label, "Label 2")
        XCTAssertEqual(sut.descriptions[0].value, "Value 2")
    }
    
}
