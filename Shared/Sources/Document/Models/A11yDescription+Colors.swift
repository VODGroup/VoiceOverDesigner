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
