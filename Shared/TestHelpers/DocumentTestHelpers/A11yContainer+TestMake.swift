//
//  File.swift
//  
//
//  Created by Andrey Plotnikov on 30.12.2022.
//

import CoreGraphics
import Foundation
@testable import Document

extension A11yContainer {
   public static func testMake(
        elements: [A11yDescription] = [],
        frame: CGRect = .zero,
        label: String = ""
    ) -> A11yContainer {
        A11yContainer(
            elements: elements,
            frame: frame,
            label: label
        )
    }
}
