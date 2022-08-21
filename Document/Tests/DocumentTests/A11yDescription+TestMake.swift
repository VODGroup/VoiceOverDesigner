//
//  File.swift
//  
//
//  Created by Andrey Plotnikov on 13.08.2022.
//
import Foundation
@testable import Document

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
        A11yDescription(label: label,
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