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
        isAccessibilityElement: Bool = true,
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
    
    // MARK: - Adjustable
    public private(set) var adjustableOptions: AdjustableOptions // Not optional because user can input values, disable adjustable, but reenable after time. The app will keep data :-)
    
    @DecodableDefault.EmptyCustomActions
    public private(set) var customActions: A11yCustomActions
    
    @DecodableDefault.EmptyCustomDescriptions
    public private(set) var customDescriptions: A11yCustomDescriptions
    
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
    
    var isValid: Bool {
        !label.isEmpty
    }
    
    static let alphaColor: CGFloat = A11yControl.Config().normalAlpha

    
    public var color: Color {
        guard isAccessibilityElement else {
            return Self.ignoreColor.withAlphaComponent(Self.alphaColor)
        }
        
        return (isValid ? Self.validColor: Self.invalidColor).withAlphaComponent(Self.alphaColor)
    }
    
    static var invalidColor: Color {
        Color.systemOrange
    }
    
    static var validColor: Color {
        Color.systemGreen
    }
    
    static var ignoreColor: Color {
        Color.systemGray
    }
    
    public var voiceOverText: String {
        var descr = ""
        var traitsDescription: [String] = []
        

        
        if !label.isEmpty {
            descr.append(label)
        }
        
        if !value.isEmpty {
            descr.append(": \(isAdjustable ? (adjustableOptions.currentValue ?? "") : value)")
        }
        
        if trait.contains(.selected) {
            if descr.isEmpty {
                descr = Localization.traitSelectedDescription
            } else {
                descr = Localization.traitSelectedFormat(value: descr)
            }
        }
        
        if trait.contains(.notEnabled) {
            traitsDescription.append(Localization.traitNotEnabledDescription)
        }
        
        // TODO: Add more traits
        if trait.contains(.button) {
            traitsDescription.append(Localization.traitButtonDescription)
        }
        
        if trait.contains(.adjustable) {
            traitsDescription.append(Localization.traitAdjustableDescription)
        }
        
        if trait.contains(.header) {
            traitsDescription.append(Localization.traitHeaderDescription)
        }
        
        // TODO: Это иначе работает, .tab это свойство контейнера
        if trait.contains(.tab) {
            traitsDescription.append(Localization.traitTabDescription)
        }
        
        // TODO: Test order when all enabled
        if trait.contains(.image) {
            traitsDescription.append(Localization.traitImageDescription)
        }
        
        if trait.contains(.link) {
            traitsDescription.append(Localization.traitLinkDescription)
        }
        
        if !hint.isEmpty {
            traitsDescription.append("\(hint)")
        }
        
        if descr.isEmpty && traitsDescription.isEmpty {
            return Localization.traitEmptyDescription
        }
        
        if !traitsDescription.isEmpty {
            if !descr.isEmpty {
                let trailingPeriod = descr.hasSuffix(".") ? "" : "."
                descr = "\(descr)\(trailingPeriod) \(traitsDescription.joined(separator: " "))"
            } else {
                descr = traitsDescription.joined(separator: " ")
            }
        }
        
        return descr
        

    }
    
    public func addAdjustableOption(defaultValue: String = "") {
        trait.formUnion(.adjustable)
        adjustableOptions.add(defaultValue: defaultValue)
    }
    
    public func updateAdjustableOption(at index: Int, with text: String) {
        adjustableOptions.update(at: index, text: text)
    }
    
    public func removeAdjustableOption(at index: Int) {
        adjustableOptions.remove(at: index)
        if adjustableOptions.isEmpty {
            trait.remove(.adjustable)
        }
    }
    
    public func selectAdjustableOption(at index: Int) {
        adjustableOptions.currentIndex = index
        value = adjustableOptions.options[index]
    }
    
    public func accessibilityIncrement() {
        adjustableOptions.accessibilityIncrement()
        value = adjustableOptions.currentValue ?? ""
    }
    
    public func accessibilityDecrement() {
        adjustableOptions.accessibilityDecrement()
        value = adjustableOptions.currentValue ?? ""
    }
}

// MARK: CustomActions
public extension A11yDescription {
    func addCustomAction(named name: String) {
        customActions.addNewCustomAction(named: name)
    }
    
    func removeCustomAction(at index: Int) {
        customActions.remove(at: index)
    }
    
    func updateCustomAction(at index: Int, with name: String) {
        customActions.update(at: index, with: name)
    }
}


// MARK: CustomDescription
public extension A11yDescription {
    func addCustomDescription(_ description: A11yCustomDescription) {
        customDescriptions.addNewCustomDescription(description)
    }
    
    func removeCustomDescription(at index: Int) {
        customDescriptions.remove(at: index)
    }
    
    func updateCustomDescription(at index: Int, with description: A11yCustomDescription) {
        customDescriptions.update(at: index, with: description)
    }
}
