//
//  SettingsTests.swift
//  SettingsTests
//
//  Created by Mikhail Rubanov on 05.05.2022.
//

import XCTest
@testable import Settings
@testable import Document
import CoreGraphics
import Canvas

class SettingsTests: XCTestCase {

    var model: A11yDescription!
    var control: A11yControlLayer!
    var sut: ElementSettingsPresenter!
    var delegate: FakeSettingsDelegate!
    
    override func setUp() {
        model = A11yDescription.empty(frame: .zero)
        
        control = A11yControlLayer()
        control.model = model
        
        delegate = FakeSettingsDelegate()
        
        sut = ElementSettingsPresenter(
            element: model,
            delegate: delegate)
    }
    
    func test_whenSettingsUpdateLabel_shouldRevalidateColor() throws {
        XCTExpectFailure("Should be moved to integration or UI tests")
        
        sut.updateLabel(to: "Test")
        
        XCTAssertEqual(
            control.backgroundColor,
            Color.validColor.withAlphaComponent(0.5).cgColor
        )
    }
}

class FakeSettingsDelegate: SettingsDelegate {
    var didUpdateValue = false
    func updateValue() {
       didUpdateValue = true
    }
    
    func delete(model: any ArtboardElement) {
        
    }
}
