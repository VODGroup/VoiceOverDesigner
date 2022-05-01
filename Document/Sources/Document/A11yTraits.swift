//
//  A11yTraits.swift
//  
//
//  Created by Mikhail Rubanov on 01.05.2022.
//

import Foundation

public struct A11yTraits: OptionSet, Codable, Hashable {
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
    public static let startsMediaSession = A11yTraits(rawValue: 1 << 13)
    public static let updatesFrequently = A11yTraits(rawValue: 1 << 14)
    public static let causesPageTurn = A11yTraits(rawValue: 1 << 15)
    public static let keyboardKey = A11yTraits(rawValue: 1 << 16)
}

#if canImport(UIKit)
import UIKit
extension A11yTraits {
    public var accessibilityTrait: UIAccessibilityTraits {
        var traits = UIAccessibilityTraits.none
        
        for appTrait in traitsMap.keys {
            if self.contains(appTrait) {
                let iosTrait = traitsMap[appTrait]!
                traits.formUnion(iosTrait)
            }
        }
        
        return traits
    }
}

let traitsMap: [A11yTraits: UIAccessibilityTraits] = [
    .none: .none,
    .button: .button,
    .header: .header,
    .adjustable: .adjustable,
    .link: .link,
    .staticText: .staticText,
    .image: .image,
    .searchField: .searchField,
    .tab: .tabBar,
    
        .selected: .selected,
    .notEnabled: .notEnabled,
    .summaryElement: .summaryElement,
    .playsSound: .playsSound,
    .allowsDirectInteraction: .allowsDirectInteraction,
    .startsMediaSession: .startsMediaSession,
    .updatesFrequently: .updatesFrequently,
    .causesPageTurn: .causesPageTurn,
    .keyboardKey: .keyboardKey,
]
#endif
