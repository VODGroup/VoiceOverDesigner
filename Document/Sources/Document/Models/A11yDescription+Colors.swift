import CoreGraphics

extension A11yDescription {
    var isValid: Bool {
        !label.isEmpty
    }
    
    static let colorAlpha: CGFloat = A11yControl.Config().normalAlpha
    
    public var color: Color {
        .color(for: self)
        .withAlphaComponent(Self.colorAlpha)
    }
}
