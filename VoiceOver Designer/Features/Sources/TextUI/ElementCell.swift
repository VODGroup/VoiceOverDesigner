import Foundation
import AppKit
import Document

class ElementCell: NSTableCellView {
    
    func setup(model: (any AccessibilityView)?, isSelected: Bool) {
        self.model = model
        self.isSelected = isSelected
        
    }
    
    private var model: (any AccessibilityView)?
    
    private func update(model: (any AccessibilityView)?) {
        if let element = model as? A11yDescription {
            textField?.attributedStringValue = element.voiceOverTextAttributed(font: textField?.font)
        } else if let container = model as? A11yContainer {
            textField?.stringValue = container.label // TODO: Make bold?
        } else {
            textField?.stringValue = NSLocalizedString("Unknown element", comment: "")
        }
    }
    
    var isSelected: Bool = false {
        didSet {
            if isSelected {
                if let attributedString = textField?.attributedStringValue {
                    let stringToDeselect = NSMutableAttributedString(attributedString: attributedString)
                    stringToDeselect.addAttribute(.foregroundColor,
                                                  value: Color.white,
                                                  range: NSRange(location: 0, length: stringToDeselect.length))
                    
                    textField?.attributedStringValue = stringToDeselect
                }
            } else {
                update(model: model)
            }
        }
    }
}
