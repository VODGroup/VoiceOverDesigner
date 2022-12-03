//
//  A11yDescription.swift
//  VoiceOver Designer
//
//  Created by Mikhail Rubanov on 30.04.2022.
//

import Foundation
import CoreGraphics

#if canImport(UIKit)
    import UIKit
    public typealias Color = UIColor
#else
    import AppKit
    public typealias Color = NSColor
#endif

public class A11yDescription: Codable, Equatable {
    public static func == (lhs: A11yDescription, rhs: A11yDescription) -> Bool {
        lhs.frame == rhs.frame // It looks that we can't have two instances with same frame it it's uniquely enough
    }
    
    public init(
        isAccessibilityElement: Bool,
        label: String,
        value: String,
        hint: String,
        trait: A11yTraits,
        frame: CGRect,
        adjustableOptions: AdjustableOptions,
        customActions: A11yCustomActions
    ) {
        self.isAccessibilityElement = isAccessibilityElement
        self.label = label
        self.value = value
        self.hint = hint
        self.trait = trait
        self.frame = frame
        self.adjustableOptions = adjustableOptions
        self.customActions = customActions
    }
    
    public var isAccessibilityElement: Bool
    public var label: String
    public var value: String
    public var hint: String
    public var trait: A11yTraits
    public var frame: CGRect
    
    @DecodableDefault.ElementAccessibilityViewType
    public var type: AccessibilityViewType
    
    // MARK: - Adjustable
    public internal(set) var adjustableOptions: AdjustableOptions // Not optional because user can input values, disable adjustable, but reenable after time. The app will keep data :-)
    
    @DecodableDefault.EmptyCustomActions
    public internal(set) var customActions: A11yCustomActions
    
    @DecodableDefault.EmptyCustomDescriptions
    public internal(set) var customDescriptions: A11yCustomDescriptions
    
    public var isAdjustable: Bool {
        get {
            trait.contains(.adjustable)
        }
        set {
            if newValue {
                trait.formUnion(.adjustable)
            } else {
                trait.remove(.adjustable)
            }
        }
    }
    
    public var isEnumeratedAdjustable: Bool {
        get {
            adjustableOptions.isEnumerated
        }
        
        set {
            adjustableOptions.isEnumerated = newValue
        }
    }
    
    public static func empty(frame: CGRect) -> A11yDescription {
        A11yDescription(
            isAccessibilityElement: true,
            label: "",
            value: "",
            hint: "",
            trait: .none,
            frame: frame,
            adjustableOptions: AdjustableOptions(options: []),
            customActions: A11yCustomActions(names: [])
        )
    }
    
    public static func copy(from descr: A11yDescription) -> A11yDescription {
        A11yDescription(
            isAccessibilityElement: descr.isAccessibilityElement,
            label: descr.label,
            value: descr.value,
            hint: descr.hint,
            trait: descr.trait,
            frame: descr.frame,
            adjustableOptions: descr.adjustableOptions,
            customActions: descr.customActions
        )
    }
}

extension A11yDescription: AccessibilityElement {}
