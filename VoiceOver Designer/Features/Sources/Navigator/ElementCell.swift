import Foundation
import AppKit
import Document

class ElementCell: NSTableCellView {
    
    func setup(model: (any ArtboardElement)?) {
        self.model = model
        deselect()
    }
    
    private var model: (any ArtboardElement)?
    
    private func update(model: (any ArtboardElement)?) {
        switch model?.cast {
        case .frame(let frame):
            textField?.stringValue = frame.label
        case .container(let container):
            textField?.stringValue = container.label // TODO: Make bold?
        case .element(let element):
            textField?.attributedStringValue = element.voiceOverTextAttributed(font: textField?.font)
        case .none:
            textField?.stringValue = NSLocalizedString("Unknown element", comment: "")
        }
    }
    
    public func select() {
        if let attributedString = textField?.attributedStringValue {
            let stringToDeselect = NSMutableAttributedString(attributedString: attributedString)
            stringToDeselect.addAttribute(.foregroundColor,
                                          value: Color.white,
                                          range: NSRange(location: 0, length: stringToDeselect.length))
            
            textField?.attributedStringValue = stringToDeselect
        }
    }
    
    public func deselect() {
        update(model: model)
    }
}
