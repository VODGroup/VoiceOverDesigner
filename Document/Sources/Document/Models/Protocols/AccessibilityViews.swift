//
//  File.swift
//  
//
//  Created by Andrey Plotnikov on 08.11.2022.
//

import Foundation

public protocol AccessibilityView: AnyObject, Equatable {
    var label: String { get set }
    var frame: CGRect { get set }
}

public protocol AccessibilityContainer: AccessibilityView {
    associatedtype Element: AccessibilityElement
    var elements: [Element] { get set }
}

public protocol AccessibilityElement: AccessibilityView {
    var isAccessibilityElement: Bool { get set }
    var value: String { get set }
    var hint: String { get set }
    var trait: A11yTraits { get set }
}


