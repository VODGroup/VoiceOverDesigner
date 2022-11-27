//
//  AdjustableViewControllerSnapshotTests.swift
//  SettingsTests
//
//  Created by Mikhail Rubanov on 14.05.2022.
//

import XCTest
import SnapshotTesting

@testable import Settings

import Document

class AdjustableViewControllerSnapshotTests: XCTestCase {

    override class func setUp() {
        super.setUp()
        
//        SnapshotTesting.isRecording = true
    }
    
    func test_empty() throws {
        let descr = A11yDescription.testMake()

        let sut = sut(descr: descr)
        
        assertSnapshot(matching: sut, as: .image())
    }
    
    func test_value_notAdjustable() throws {
        let descr = A11yDescription.testMake(value: "Маленькая")
    
        let sut = sut(descr: descr)
        
        assertSnapshot(matching: sut, as: .image())
    }
    
    func test_adjustable_noSamples() throws {
        let descr = A11yDescription.testMake(
            value: "Маленькая",
            trait: .adjustable
        )
        
        let sut = sut(descr: descr)
        
        assertSnapshot(matching: sut, as: .image())
    }
    
    func test_adjustable_withSamples() throws {
        let descr = A11yDescription.testMake(
            trait: .adjustable,
            adjustableOption: .testMake(options: ["Маленькая", "Средняя"],
                                        currentIndex: 0)
        )
        
        let sut = sut(descr: descr)
        
        assertSnapshot(matching: sut, as: .image())
    }
    
    func test_notAdjustable_withSamples() throws {
        let descr = A11yDescription.testMake(
            value: "Маленькая",
//            trait: .adjustable,
            adjustableOption: .testMake(options: ["Маленькая", "Средняя"],
                                        currentIndex: 0)
        )
        
        let sut = sut(descr: descr)
        
        assertSnapshot(matching: sut,
                       as: .image())
    }
    
    private let size = CGSize(width: 350, height: 300)
    
    private func sut(descr: A11yDescription) -> A11yValueViewController {
        let sut = A11yValueViewController.fromStoryboard()
        
        sut.presenter = .init(model: descr,
                              delegate: SettingsDelegateMock())
        
        sut.view.wantsLayer = true
        sut.view.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        
        return sut
    }
}

// TODO: Remove duplicate
extension A11yDescription {
    public static func testMake(
        label: String = "",
        value: String = "",
        hint: String = "",
        trait: A11yTraits = .none,
        frame: CGRect = .zero,
        adjustableOption: AdjustableOptions = .testMake(),
        customActions: A11yCustomActions = .testMake()
    ) -> A11yDescription {
        A11yDescription(
            isAccessibilityElement: true,
            label: label,
            value: value,
            hint: hint,
            trait: trait,
            frame: frame,
            adjustableOptions: adjustableOption,
            customActions: customActions
        )
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

extension A11yCustomActions {
    public static func testMake(names: [String] = []) -> A11yCustomActions {
        A11yCustomActions(names: names)
    }
}
