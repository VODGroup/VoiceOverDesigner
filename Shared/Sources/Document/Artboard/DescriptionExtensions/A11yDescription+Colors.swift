import CoreGraphics

extension A11yDescription {
    var isValid: Bool {
        !label.isEmpty
    }
    
    static let colorAlpha: CGFloat = 0.5 // same as A11yControl.Config().normalAlpha
    
    public var color: Color {
        .color(for: self)
        .withAlphaComponent(Self.colorAlpha)
    }
}

extension AccessibilityView {
    public var color: Color {
        if self is A11yContainer {
            return Color.systemGray.withAlphaComponent(A11yDescription.colorAlpha)
        } else if let element = self as? A11yDescription {
            return element.color
        } else {
            return Color.black.withAlphaComponent(A11yDescription.colorAlpha)
        }
    }
}
