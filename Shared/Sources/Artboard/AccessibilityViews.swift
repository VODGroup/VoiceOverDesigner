import Foundation

// MARK: - Relation
public protocol Child: AnyObject {
    /// Must be `weak`
    var parent: BaseContainer? { get set }
}

// TODO: Make generic?
public protocol Container: Child {
    var elements: [any ArtboardElement] { get }
}

public protocol Node: BaseContainer, Child, Container {}

open class BaseContainer: Container {
    // TODO: Make public and remove controls from A11yContainer
    open var elements: [any ArtboardElement] = []
    
    public var parent: BaseContainer?

    public func append(_ child: any ArtboardElement) {
        elements.append(child)
        child.parent = self
    }
    
    public func insert(_ node: any ArtboardElement, at index: Int) {
        elements.insert(node, at: index)
        node.parent = self
    }
    
    public func remove(_ node: any ArtboardElement) -> Int? {
        elements.remove(node)
    }
    
    public init(elements: [any ArtboardElement], parent: BaseContainer? = nil) {
        self.elements = elements
        self.parent = parent
        
        for element in elements {
            element.parent = self
        }
    }
}

extension Array where Element == any ArtboardElement {
    /// - Returns: Element index
    @discardableResult
    public mutating func remove(_ element: Element) -> Int? {
        let from = firstIndex(where: { control in
            control === element
        })
        
        if let from {
            remove(at: from)
            return from
        }
        
        return nil
    }
}

// MARK: - Types

public enum ArtboardType: String, Codable {
    case element
    case container
    case frame
    //    case artboard
}

public protocol ArtboardElement: Child, Equatable {
    var id: UUID { get }
    var label: String { get set }
    var frame: CGRect { get set }
    
    var type: ArtboardType { get }
}

public protocol ArtboardContainer: ArtboardElement, Node {}

/// Allows
public protocol InstantiatableContainer {
    init(
        elements: [any ArtboardElement],
        frame: CGRect,
        label: String
    )
}
