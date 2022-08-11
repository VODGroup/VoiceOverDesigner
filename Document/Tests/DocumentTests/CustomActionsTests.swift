//
//  File.swift
//  
//
//  Created by Andrey Plotnikov on 11.08.2022.
//

import XCTest
@testable import Document

class CustomActionsTests: XCTestCase {
    
    func test_addNewAction_shouldChangeCountAndHaveActionName() throws {
        var sut = A11yCustomActions(names: [])
        sut.addNewCustomAction(named: "TestAction")
        XCTAssertTrue(!sut.names.isEmpty)
        XCTAssertEqual(sut.names.count, 1)
        XCTAssertEqual(sut.names[0], "TestAction")
    }
    
    func test_removeAtIndex_shouldChangeCount() throws {
        var sut = A11yCustomActions(names: ["Name1", "Name2"])
        sut.remove(at: 0)
        XCTAssertTrue(!sut.names.isEmpty)
        XCTAssertEqual(sut.names.count, 1)
        XCTAssertEqual(sut.names[0], "Name2")
    }
    
    func test_updateAtIndex_shouldChangeName() throws {
        var sut = A11yCustomActions(names: ["Name1", "Name2"])
        sut.update(at: 0, with: "NewName")
        XCTAssertTrue(!sut.names.isEmpty)
        XCTAssertEqual(sut.names.count, 2)
        XCTAssertEqual(sut.names[0], "NewName")
    }
    
}
