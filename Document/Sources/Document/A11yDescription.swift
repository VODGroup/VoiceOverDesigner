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
        adjustableOptions: AdjustableOptions
    ) {
        self.isAccessibilityElement = isAccessibilityElement
        self.label = label
        self.value = value
        self.hint = hint
        self.trait = trait
        self.frame = frame
        self.adjustableOptions = adjustableOptions
    }
    
    public var isAccessibilityElement: Bool
    public var label: String
    public var value: String
    public var hint: String
    public var trait: A11yTraits
    public var frame: CGRect
    
    // MARK: - Adjustable
    public var adjustableOptions: AdjustableOptions // Not optional because user can input values, disable adjustable, but reenable after time. The app will keep data :-)
    
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
            adjustableOptions: AdjustableOptions(options: []))
    }
    
    var isValid: Bool {
        !label.isEmpty
    }
    
    private let alphaColor: CGFloat = 0.3
    
    public var color: Color {
        guard isAccessibilityElement else {
            return Self.ignoreColor.withAlphaComponent(alphaColor)
        }
        
        return (isValid ? Self.validColor: Self.invalidColor).withAlphaComponent(alphaColor)
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
        
        return descr.joined()
    }
}

public struct AdjustableOptions: Codable {
    init(options: [String], currentIndex: Int? = nil) {
        self.options = options
        self.currentIndex = currentIndex
    }
    
    public var options: [String] {
        didSet {
            if let currentIndex = currentIndex,
                options.count <= currentIndex
            {
                self.currentIndex = options.count - 1
            }
        }
    }
    public var currentIndex: Int?
}
