import CoreGraphics
import Artboard

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

extension ArtboardElement {
    // TODO: Inverse dependency? element should know about it's color
    public var color: Color {
        switch cast {
        case .frame:
            return Color.blue
        case .container(let container):
            return Color.systemGray
                .withAlphaComponent(A11yDescription.colorAlpha)
        case .element(let element):
            return element.color
        }
    }
}
