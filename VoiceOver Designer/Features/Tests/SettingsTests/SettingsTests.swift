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
        let control = A11yControl()
        control.a11yDescription = .empty(frame: .zero)
        
        let sut = SettingsPresenter(
            control: control,
            delegate: SettingsDelegateMock())
        
        sut.updateLabel(to: "Test")
        
        XCTAssertEqual(
            control.backgroundColor,
            A11yDescription.validColor.withAlphaComponent(0.3).cgColor
        )
    }
    
    func test_whenSettingsUpdateLabel_shouldUpdateLayerLabel() throws {
        let control = A11yControl()
        control.a11yDescription = .empty(frame: .zero)
        
        let sut = SettingsPresenter(
            control: control,
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
    
    func delete(control: A11yControl) {
        
    }
}
