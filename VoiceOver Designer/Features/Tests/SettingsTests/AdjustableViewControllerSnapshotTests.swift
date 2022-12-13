//
//  AdjustableViewControllerSnapshotTests.swift
//  SettingsTests
//
//  Created by Mikhail Rubanov on 14.05.2022.
//

import XCTest
import SnapshotTesting
import DocumentTestHelpers

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
        
        sut.presenter = .init(element: descr,
                              delegate: FakeSettingsDelegate())
        
        sut.view.wantsLayer = true
        sut.view.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        
        return sut
    }
}
