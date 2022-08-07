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

public class A11yDescription: Codable {
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
    
    public private(set) var customActions: A11yCustomActions
    
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
        var descr = [String]()
        
        if trait.contains(.selected) {
            descr.append("Выбрано. ")
        }
        
        if !label.isEmpty {
            descr.append(label)
        }
        
        if !value.isEmpty {
            descr.append(": \(value)")
        }
        
        if trait.contains(.notEnabled) {
            descr.append(". Недоступно")
        }
        
        // TODO: Add more traits
        if trait.contains(.button) {
            descr.append(". Кнопка")
        }
        
        if trait.contains(.adjustable) {
            descr.append(". Элемент регулировки")
        }
        
        if trait.contains(.header) {
            descr.append(". Заголовок")
        }
        
        // TODO: Это иначе работает, .tab это свойство контейнера
        if trait.contains(.tab) {
            descr.append(". Вкладка")
        }
        
        // TODO: Test order when all enabled
        if trait.contains(.image) {
            descr.append(". Изображение")
        }
        
        if trait.contains(.link) {
            descr.append(". Ссылка")
        }
        
        if !hint.isEmpty {
            descr.append(". \(hint)")
        }
        
        if descr.isEmpty {
            return NSLocalizedString("Empty", comment: "")
        }
        
        return descr.joined()
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
