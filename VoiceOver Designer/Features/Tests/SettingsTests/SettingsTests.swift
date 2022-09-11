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

class SettingsTests: XCTestCase {

    func test_whenSettingsUpdateLabel_shouldRevalidateColor() throws {
        XCTExpectFailure("Should be moved to integration tests")
        let model = A11yDescription.empty(frame: .zero)
        
        let control = A11yControl()
        control.a11yDescription = model
        
        let sut = SettingsPresenter(
            model: model,
            delegate: SettingsDelegateMock())
        
        sut.updateLabel(to: "Test")
        
        XCTAssertEqual(
            control.backgroundColor,
            Color.validColor.withAlphaComponent(0.5).cgColor
        )
    }
    
    func test_whenSettingsUpdateLabel_shouldUpdateLayerLabel() throws {
        let model = A11yDescription.empty(frame: .zero)
        
        let control = A11yControl()
        control.a11yDescription = model
        
        let sut = SettingsPresenter(
            model: model,
            delegate: SettingsDelegateMock())
        
        sut.updateLabel(to: "Test")
        
        let labelString = control.label?.string as? String
        
        XCTAssertEqual(
            labelString,
            "Test"
        )
    }
}

class SettingsDelegateMock: SettingsDelegate {
    func didUpdateValue() {
        
    }
    
    func delete(model: A11yDescription) {
        
    }
}
