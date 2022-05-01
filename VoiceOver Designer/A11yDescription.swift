//
//  A11yDescription.swift
//  VoiceOver Designer
//
//  Created by Mikhail Rubanov on 30.04.2022.
//

import Foundation
import AppKit

public struct A11yDescription: Codable {
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
    
    var label: String
    var value: String
    var hint: String
    var trait: A11yTraits
    
    var frame: CGRect
    
    static func empty(frame: CGRect) -> Self {
        A11yDescription(label: "", value: "", hint: "", trait: .none, frame: frame)
    }
    
    var isValid: Bool {
        !label.isEmpty
    }
    
    var color: NSColor {
        (isValid ? Self.validColor: Self.notValidColor).withAlphaComponent(0.3)
    }
    
    static var notValidColor: NSColor {
        NSColor.systemOrange
    }
    
    static var validColor: NSColor {
        NSColor.systemGreen
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

public struct A11yTraits: OptionSet, Codable {
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let none = A11yTraits([])
    
    // MARK: Type
    public static let button = A11yTraits(rawValue: 1 << 0)
    public static let header = A11yTraits(rawValue: 1 << 1)
    public static let adjustable = A11yTraits(rawValue: 1 << 2)
    public static let link = A11yTraits(rawValue: 1 << 3)
    public static let staticText = A11yTraits(rawValue: 1 << 4)
    public static let image = A11yTraits(rawValue: 1 << 5)
    public static let searchField = A11yTraits(rawValue: 1 << 6)
    public static let tab = A11yTraits(rawValue: 1 << 7)
    
    // MARK: Behaviour
    public static let selected = A11yTraits(rawValue: 1 << 8)
    public static let notEnabled = A11yTraits(rawValue: 1 << 9)
    public static let summaryElement = A11yTraits(rawValue: 1 << 10)
    public static let playsSound = A11yTraits(rawValue: 1 << 11)
    public static let allowsDirectInteraction = A11yTraits(rawValue: 1 << 12)
    public static let StartsMediaSession = A11yTraits(rawValue: 1 << 13)
    public static let updatesFrequently = A11yTraits(rawValue: 1 << 14)
    public static let causesPageTurn = A11yTraits(rawValue: 1 << 15)
    public static let keyboardKey = A11yTraits(rawValue: 1 << 16)
}
