import Foundation
@_exported import Artboard

public enum ArtboardElementCast {
    case element(_ element: A11yDescription)
    case container(_ container: A11yContainer)
    case frame(_ frame: Frame)
}

extension ArtboardElement {
    public var cast: ArtboardElementCast {
        if let container = self as? A11yContainer {
            return .container(container)
        } else if let element = self as? A11yDescription {
            return .element(element)
        } else if let frame = self as? Frame {
            return .frame(frame)
        } else {
            fatalError()
        }
    }
}
