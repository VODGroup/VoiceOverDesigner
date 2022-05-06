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
        label: String,
        value: String,
        hint: String,
        trait: A11yTraits,
        frame: CGRect) {
            self.label = label
            self.value = value
            self.hint = hint
            self.trait = trait
            self.frame = frame
        }
    
    public var label: String
    public var value: String
    public var hint: String
    public var trait: A11yTraits
    
    public var frame: CGRect
    
    public static func empty(frame: CGRect) -> A11yDescription {
        A11yDescription(label: "", value: "", hint: "", trait: .none, frame: frame)
    }
    
    var isValid: Bool {
        !label.isEmpty
    }
    
    public var color: Color {
        (isValid ? Self.validColor: Self.invalidColor).withAlphaComponent(0.3)
    }
    
    static var invalidColor: Color {
        Color.systemOrange
    }
    
    static var validColor: Color {
        Color.systemGreen
    }
    
    public var voiceOverText: String {
        var descr = [String]()
        
        if !label.isEmpty {
            descr.append(label)
        }
        
        if !value.isEmpty {
            descr.append(": \(value)")
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
        
        if trait.contains(.tab) {
            descr.append(". Вкладка")
        }
        
        if !hint.isEmpty {
            descr.append(". \(hint)")
        }
        
        return descr.joined()
    }
}
