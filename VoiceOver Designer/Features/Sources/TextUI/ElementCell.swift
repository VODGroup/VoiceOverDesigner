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
        switch model?.cast {
        case .container(let container):
            textField?.stringValue = container.label // TODO: Make bold?
        case .element(let element):
            textField?.attributedStringValue = element.voiceOverTextAttributed(font: textField?.font)
        case .none:
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
