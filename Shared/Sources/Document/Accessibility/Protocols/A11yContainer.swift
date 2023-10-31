import Foundation
import Artboard

extension A11yContainer: ArtboardContainer {
    public var elements: [any ArtboardElement] {
        get {
            controls
        }
        set(newValue) {
            controls = newValue as! [A11yDescription]
        }
    }
}

public class A11yContainer: Codable, ObservableObject {
    public init(
        id: UUID = UUID(),
        elements: [A11yDescription],
        frame: CGRect,
        label: String,
        isModal: Bool = false,
        isTabTrait: Bool = false,
        isEnumerated: Bool = false,
        containerType: ContainerType = .semanticGroup,
        navigationStyle: NavigationStyle = .automatic
    ) {
        self.controls = elements
        self.frame = frame
        self.label = label
        self.containerType = containerType
        self.navigationStyle = navigationStyle
        self.id = id
        
        self.isModal = isModal
        self.isTabTrait = isTabTrait
        self.isEnumerated = isEnumerated
    }

    public static func ==(lhs: A11yContainer, rhs: A11yContainer) -> Bool {
        lhs.frame == rhs.frame
        && lhs.controls == rhs.controls
        && lhs.label == rhs.label
    }

    @DecodableDefault.RandomUUID
    public var id: UUID

    public var elements: [A11yDescription]
    public var frame: CGRect
    
    public var label: String {
        willSet { objectWillChange.send() }
    }
    public var type: ArtboardType = .container
    
    
    @DecodableDefault.False
    public var isModal: Bool {
        willSet { objectWillChange.send() }
    }

    @DecodableDefault.False
    public var isTabTrait: Bool {
        willSet { objectWillChange.send() }
    }
    
    @DecodableDefault.False
    public var isEnumerated: Bool {
        willSet { objectWillChange.send() }
    }
   
    @DecodableDefault.ContainerType
    public var containerType: ContainerType {
        willSet { objectWillChange.send() }
    }
    
    @DecodableDefault.NavigationStyle
    public var navigationStyle: NavigationStyle {
        willSet { objectWillChange.send() }
    }
    
    public static func copy(from model: A11yContainer) -> A11yContainer {
        A11yContainer(
            id: UUID(),
            elements: model.elements.map({ element in
                A11yDescription.copy(from: element)
            }),
            frame: model.frame,
            label: model.label,
            isModal: model.isModal,
            isTabTrait: model.isTabTrait,
            isEnumerated: model.isEnumerated,
            containerType: model.containerType,
            navigationStyle: model.navigationStyle
        )
    }
    
    public enum ContainerType: String, Codable, CaseIterable, Identifiable {
//        case none
//        case dataTable
        case semanticGroup
        case list
        case landmark
        
        public var id: Self { self }
    }
    
    public enum NavigationStyle: String, Codable, CaseIterable, Identifiable {
        case automatic
        case separate
        case combined
        
        public var id: Self { self }
    }
    
    
    public func contains(_ element: A11yDescription) -> Bool {
        controls.contains(element)
    }
    
    @discardableResult
    public func remove(_ element: A11yDescription) -> Int? {
        controls.remove(element)
    }
}

extension A11yContainer {
    /**
     Flattens container to array of ``ArtboardElement``
     - returns: An array of any ArtboardElement
     */
    public func flattenWithElements() -> [any ArtboardElement] {
        [self] + controls
    }
}

public enum A11yElement: Codable {
    case description(A11yDescription)
    case container(A11yContainer)
}

extension ArtboardElement {
    public func copy() -> any ArtboardElement {
        switch self.cast {
        case .frame(let frame):
            // TODO: Implement copying
            fatalError()
        case .container(let container):
            return A11yContainer.copy(from: container)
        case .element(let element):
            return A11yDescription.copy(from: element)
        }
    }
    
    public func copyWithoutLabel() -> any ArtboardElement {
        let copy = self.copy()
        copy.label = ""
        return copy
    }
}
