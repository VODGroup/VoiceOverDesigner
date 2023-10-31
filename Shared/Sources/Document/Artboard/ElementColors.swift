import Foundation

extension Color {
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
    
    static var buttonColor: Color {
        Color.systemBlue
    }
    
    static func color(for element: A11yDescription) -> Color {
        guard element.isAccessibilityElement else {
            return .ignoreColor
        }
        
        if element.isAdjustable {
            return .adjustableColor
        }
        
        let isButton = element.trait.contains(.button) || element.trait.contains(.link)
        if isButton {
            return .buttonColor
        }
        
        return (element.isValid ? .validColor: .invalidColor)
    }
}
