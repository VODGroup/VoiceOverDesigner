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

public class A11yDescription: Codable, Equatable, ObservableObject {
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
    
    enum CodingKeys: CodingKey {
        case isAccessibilityElement
        case label
        case value
        case hint
        case trait
        case frame
        case adjustableOptions
        case customActions
        case customDescriptions
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.isAccessibilityElement = try container.decode(Bool.self, forKey: .isAccessibilityElement)
        self.label = try container.decode(String.self, forKey: .label)
        self.value = try container.decode(String.self, forKey: .value)
        self.hint = try container.decode(String.self, forKey: .hint)
        self.trait = try container.decode(A11yTraits.self, forKey: .trait)
        self.frame = try container.decode(CGRect.self, forKey: .frame)
        self.adjustableOptions = try container.decode(AdjustableOptions.self, forKey: .adjustableOptions)
        self._customActions = try container.decode(DecodableDefault.EmptyCustomActions.self, forKey: .customActions)
        self._customDescriptions = try container.decode(DecodableDefault.EmptyCustomDescriptions.self, forKey: .customDescriptions)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.isAccessibilityElement, forKey: .isAccessibilityElement)
        try container.encode(self.label, forKey: .label)
        try container.encode(self.value, forKey: .value)
        try container.encode(self.hint, forKey: .hint)
        try container.encode(self.trait, forKey: .trait)
        try container.encode(self.frame, forKey: .frame)
        try container.encode(self.adjustableOptions, forKey: .adjustableOptions)
        try container.encode(self._customActions, forKey: .customActions)
        try container.encode(self._customDescriptions, forKey: .customDescriptions)
    }
    
    
    @Published public var isAccessibilityElement: Bool
    @Published public var label: String
    @Published public var value: String
    @Published public var hint: String
    @Published public var trait: A11yTraits
    @Published public var frame: CGRect
    
    @DecodableDefault.ElementAccessibilityViewType
    public var type: AccessibilityViewTypeDto
    
    // MARK: - Adjustable
    @Published
    public var adjustableOptions: AdjustableOptions // Not optional because user can input values, disable adjustable, but reenable after time. The app will keep data :-)
    
    @DecodableDefault.EmptyCustomActions 
    public var customActions: A11yCustomActions {
        willSet {
            objectWillChange.send()
        }
    }
    
    @DecodableDefault.EmptyCustomDescriptions
    public var customDescriptions: A11yCustomDescriptions {
        willSet {
            objectWillChange.send()
        }
    }
    
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
