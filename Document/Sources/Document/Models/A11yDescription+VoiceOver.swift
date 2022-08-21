import Foundation
import AppKit

@available(macOS 12, *)
extension NSMutableAttributedString {
    func append(markdown: String) {
        if markdown.isEmpty {
            return // Do nothing, otherwise it will crash
        }
        append(try! NSAttributedString(markdown: markdown))
    }
    
    static func += (lhs: NSMutableAttributedString, rhs: String) {
        lhs.append(markdown: rhs)
    }
    
    var isEmpty: Bool {
        length == 0
    }
}

// MARK: Markdown
extension String {
    var bold: String {
        "**\(self)**"
    }
    
    var italic: String {
        "*\(self)*"
    }
}

extension A11yDescription {
    
    @available(macOS 12, *)
    public func voiceOverTextAttributed(font: NSFont?) -> NSAttributedString {
        let result = NSMutableAttributedString()
        
        if trait.contains(.selected) {
            result += "\(Localization.traitSelectedDescription.bold) \(label)"
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
                result += traitsDescription.joined(separator: " ").bold
            } else {
                let trailingPeriod = result.string.hasSuffix(".") ? "" : "."
                result += "\(trailingPeriod) \(traitsDescription.joined(separator: " ").bold)"
            }
        }
        
        if let font = font {
            result.addAttribute(.font, value: font, range: NSRange(location: 0, length: result.string.count))
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
    public var voiceOverText: String {
        voiceOverTextAttributed(font: nil).string
    }
}
