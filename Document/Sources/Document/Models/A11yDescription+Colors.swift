import CoreGraphics

extension A11yDescription {
    var isValid: Bool {
        !label.isEmpty
    }
    
    static let colorAlpha: CGFloat = A11yControl.Config().normalAlpha
    
    public var color: Color {
        guard isAccessibilityElement else {
            return Self.ignoreColor.withAlphaComponent(Self.colorAlpha)
        }
        
        guard isAdjustable else {
            return Self.adjustableColor.withAlphaComponent(Self.colorAlpha)
        }
        
        return (isValid ? Self.validColor: Self.invalidColor).withAlphaComponent(Self.colorAlpha)
    }
    
    static var invalidColor: Color {
        Color.systemOrange
    }
    
    static var validColor: Color {
        Color.systemGreen
    }
    
    static var ignoreColor: Color {
        Color.systemGray
    }
    
    static var adjustableColor: Color {
        Color.systemPurple
    }
}
