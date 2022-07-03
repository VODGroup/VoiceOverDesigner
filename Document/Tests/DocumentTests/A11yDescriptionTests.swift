//
//  VoiceOver_DesignerTests.swift
//  VoiceOver DesignerTests
//
//  Created by Mikhail Rubanov on 30.04.2022.
//

import XCTest
@testable import Document

class A11yDescriptionTests: XCTestCase {

    func test_labelOnly() {
        let descr = A11yDescription.testMake(label: "4 сыра")
        
        XCTAssertEqual(descr.voiceOverText, "4 сыра")
    }
    
    func test_labelWithValue() {
        let descr = A11yDescription.testMake(
            label: "Город",
            value: "Екатеринбург")
        
        XCTAssertEqual(descr.voiceOverText, "Город: Екатеринбург")
    }

    func test_labelWithValueAndTrait() {
        let descr = A11yDescription.testMake(
            label: "Город",
            value: "Екатеринбург",
            trait: .button)
        
        XCTAssertEqual(descr.voiceOverText, "Город: Екатеринбург. Кнопка")
    }
    
    func test_selectedButton() {
        let descr = A11yDescription.testMake(
            label: "Город",
            value: "Екатеринбург",
            trait: [.button, .selected])
        
        XCTAssertEqual(descr.voiceOverText, "Выбрано. Город: Екатеринбург. Кнопка")
    }
    
    func test_notEnabledButton() {
        let descr = A11yDescription.testMake(
            label: "Город",
            value: "Екатеринбург",
            trait: [.button, .notEnabled])
        
        XCTAssertEqual(descr.voiceOverText, "Город: Екатеринбург. Недоступно. Кнопка")
    }
    
    
    func test_whenRemoveLastAdjustableOption_shouldRemoveAdjustableTrait() {
        let descr = A11yDescription.testMake(
            value: "",
            trait: .adjustable,
            adjustableOption: .testMake(options: ["Маленькая", "Средняя", "Большая"],
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
        
        let options = ["Маленькая", "Средняя", "Большая"]
        
        for option in options {
            descr.addAdjustableOption(defaultValue: option)
        }
        XCTAssertTrue(descr.trait.contains(.adjustable))
        XCTAssertEqual(descr.adjustableOptions.isEmpty, false)
        XCTAssertEqual(descr.adjustableOptions.options.count, 3)
    }
    
    func test_selectingAdjustableOption_shouldSetValue() {
        let descr = A11yDescription.testMake(
            label: "Пицца",
            value: "Маленькая",
            trait: .adjustable,
            adjustableOption: .testMake(options: ["Маленькая", "Средняя"],
                                        currentIndex: 0)
        )
        
        descr.addAdjustableOption(defaultValue: "Большая")
        descr.selectAdjustableOption(at: 2)
        XCTAssertEqual(descr.voiceOverText, "Пицца: Большая. Элемент регулировки")
    }
}

extension A11yDescription {
    public static func testMake(
        label: String = "",
        value: String = "",
        hint: String = "",
        trait: A11yTraits = .none,
        frame: CGRect = .zero,
        adjustableOption: AdjustableOptions = .testMake()
    ) -> A11yDescription {
        A11yDescription(label: label,
                        value: value,
                        hint: hint,
                        trait: trait,
                        frame: frame,
                        adjustableOptions: adjustableOption)
    }
}

extension AdjustableOptions {
    public static func testMake(
        options: [String] = [],
        currentIndex: Int? = nil
    ) -> AdjustableOptions {
        AdjustableOptions(options: options, currentIndex: currentIndex)
    }
}
