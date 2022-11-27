//
//  A11yTrait+UIKitTest.swift
//  
//
//  Created by Mikhail Rubanov on 01.05.2022.
//

import XCTest
import Document

#if canImport(UIKit)
class A11yTrait_UIKitTest: XCTestCase {
    func testButton() {
        XCTAssertEqual(A11yTraits.button.accessibilityTrait, .button)
    }
    
    func testStaticText() {
        XCTAssertEqual(A11yTraits.staticText.accessibilityTrait, .staticText)
    }
    
    func testNone() {
        XCTAssertEqual(A11yTraits.none.accessibilityTrait, .none)
    }
    
    func testSelected() {
        XCTAssertEqual(A11yTraits.selected.accessibilityTrait, .selected)
    }
    
    func testSelectedButton() {
        XCTAssertEqual(
            A11yTraits([.selected, .button]).accessibilityTrait,
            [.selected, .button]
        )
    }
    
    func testSelectedNotEnabledButton() {
        XCTAssertEqual(
            A11yTraits([.selected, .button, .notEnabled]).accessibilityTrait,
            [.selected, .button, .notEnabled]
        )
    }
}
#endif
