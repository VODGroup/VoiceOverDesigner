import Foundation

extension Array where Element == any ArtboardElement {
    public func extractElements() -> [A11yDescription] {
        reduce(into: [A11yDescription]()) { result, next in
            result.append(contentsOf: next.extractElements())
        }
    }
    
    public func extractContainers() -> [A11yContainer] {
        compactMap { view in
            view as? A11yContainer
        }
    }
    
    public func extractFrames() -> [Frame] {
        compactMap { view in
            view as? Frame
        }
    }
}

extension ArtboardElement {
    public func extractElements() -> [A11yDescription] {
        var result: [A11yDescription] = []
        switch cast {
        case .frame(let frame):
            result.append(contentsOf: frame.elements.extractElements())
        case .container(let container):
            result.append(contentsOf: container.elements.extractElements())
        case .element(let element):
            result.append(element)
        }
        return result
    }
}
