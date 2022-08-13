//
//  VoiceOver_DesignerTests.swift
//  VoiceOver DesignerTests
//
//  Created by Mikhail Rubanov on 30.04.2022.
//

import XCTest
@testable import Document

class A11yDescriptionTests_EN: XCTestCase {
    
    func skipIfNotRuLocale() throws {
        try XCTSkipIf(Locale.current.languageCode != "en")
    }

    func test_labelOnly() {
        let descr = A11yDescription.testMake(label: "4 cheese")
        
        XCTAssertEqual(descr.voiceOverText, "4 cheese")
    }
    
    func test_labelWithValue() throws {
        let descr = A11yDescription.testMake(
            label: "City",
            value: "Yekaterinburg")
        
        XCTAssertEqual(descr.voiceOverText, "City: Yekaterinburg")
    }

    func test_labelWithValueAndTrait() {
        let descr = A11yDescription.testMake(
            label: "City",
            value: "Yekaterinburg",
            trait: .button)
        
        XCTAssertEqual(descr.voiceOverText, "City: Yekaterinburg. Button")
    }
    
    func test_selectedButton() {
        let descr = A11yDescription.testMake(
            label: "City",
            value: "Yekaterinburg",
            trait: [.button, .selected])
        
        XCTAssertEqual(descr.voiceOverText, "Selected. City: Yekaterinburg. Button")
    }
    
    func test_notEnabledButton() {
        let descr = A11yDescription.testMake(
            label: "City",
            value: "Yekaterinburg",
            trait: [.button, .notEnabled])
        
        XCTAssertEqual(descr.voiceOverText, "City: Yekaterinburg. Dimmed. Button")
    }
    
    
    func test_whenRemoveLastAdjustableOption_shouldRemoveAdjustableTrait() {
        let descr = A11yDescription.testMake(
            value: "",
            trait: .adjustable,
            adjustableOption: .testMake(options: ["Small", "Medium", "Big"],
                                        currentIndex: 0)
        )
        
        for option in descr.adjustableOptions.options {
            if let index = descr.adjustableOptions.options.firstIndex(of: option) {
                descr.removeAdjustableOption(at: index)
            }
        }
        XCTAssertFalse(descr.trait.contains(.adjustable))
        XCTAssertEqual(descr.adjustableOptions.isEmpty, true)
    }
    
    func test_addingAdjustableOption_withSample() {
        let descr = A11yDescription.testMake()
        
        let options = ["Small", "Medium", "Big"]
        
        for option in options {
            descr.addAdjustableOption(defaultValue: option)
        }
        XCTAssertTrue(descr.trait.contains(.adjustable))
        XCTAssertEqual(descr.adjustableOptions.isEmpty, false)
        XCTAssertEqual(descr.adjustableOptions.options.count, 3)
    }
    
    func test_selectingAdjustableOption_shouldSetValue() {
        let descr = A11yDescription.testMake(
            label: "Pizza",
            value: "Small",
            trait: .adjustable,
            adjustableOption: .testMake(options: ["Small", "Medium"],
                                        currentIndex: 0)
        )
        
        descr.addAdjustableOption(defaultValue: "Big")
        descr.selectAdjustableOption(at: 2)
        XCTAssertEqual(descr.voiceOverText, "Pizza: Big, 3 of 3. Adjustable")
    }
}

