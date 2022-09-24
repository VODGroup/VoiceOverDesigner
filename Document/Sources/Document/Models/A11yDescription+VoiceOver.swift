import Foundation

#if canImport(AppKit)
import AppKit

public typealias Font = NSFont
#elseif canImport(UIKit)
import UIKit
public typealias Font = UIFont
#endif

extension A11yDescription {
    
    @available(macOS 12, *)
    @available(iOS 15, *)
    public func voiceOverTextAttributed(font: Font?) -> NSAttributedString {
        let result = NSMutableAttributedString()
        
        if trait.contains(.selected) {
            result += "\(Localization.traitSelectedDescription) \(label)"
        } else {
            result += label
        }
        
        if !value.isEmpty {
            let valueString = isAdjustable ? (adjustableOptions.currentValue ?? "") : value
            result += ": \(valueString.italic)"
        }
        
        var traitsDescription = self.traitDescription

        if !hint.isEmpty {
            traitsDescription.append("\(hint)")
        }

        if result.isEmpty && traitsDescription.isEmpty {
            result += Localization.traitEmptyDescription.italic
        }

        if !traitsDescription.isEmpty {
            if result.isEmpty {
                result += traitsDescription.joined(separator: " ")
            } else {
                let trailingPeriod = result.string.hasSuffix(".") ? "" : "."
                let trait = traitsDescription.joined(separator: " ")
                result += "\(trailingPeriod) \(trait)".markdown(color: .color(for: self))
            }
        }
        
        if let font = font {
            result.addAttribute(.font, value: font, range: result.string.fullRange)
        }
        
        return result
    }
    
    private var traitDescription: [String] {
        var traitsDescription: [String] = []
        
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
        
        return traitsDescription
    }
    
    @available(macOS 12, *)
    @available(iOS 15, *)
    public var voiceOverText: String {
        voiceOverTextAttributed(font: nil).string
    }
}

extension String {
    var fullRange: NSRange {
        NSRange(location: 0, length: count)
    }
}
