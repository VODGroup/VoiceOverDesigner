import Foundation
import Artboard

extension A11yContainer: ArtboardContainer, InstantiatableContainer {
    
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

    required convenience public init(
        elements: [any ArtboardElement],
        frame: CGRect,
        label: String
    ) {
        self.init(elements: elements as! [A11yDescription], frame: frame, label: label, isModal: false)
    }
    
    public init(
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
        
        self.isModal = isModal
        self.isTabTrait = isTabTrait
        self.isEnumerated = isEnumerated
        
        for control in controls {
            control.parent = self
        }
    }
    
    
    public static func ==(lhs: A11yContainer, rhs: A11yContainer) -> Bool {
        lhs.frame == rhs.frame
        && lhs.controls == rhs.controls
        && lhs.label == rhs.label
    }
    
    public var controls: [A11yDescription]
    public var frame: CGRect
    
    public var label: String {
        willSet { objectWillChange.send() }
    }
    public var type: ArtboardType = .container
    public weak var parent: (any ArtboardContainer)? = nil
    
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
            elements: model.controls.map({ element in
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
    public func remove(_ element: any ArtboardElement) -> Int? {
        elements.remove(element)
    }
    
    enum CodingKeys: CodingKey {
        case label
        case frame
        
        case controls
        
        case isModal
        case isTabTrait
        case isEnumerated
        case containerType
        case navigationStyle
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.label = try container.decode(String.self, forKey: .label)
        self.frame = try container.decode(CGRect.self, forKey: .frame)
        self.controls = try container.decode([A11yDescription].self, forKey: .controls)
        self.isModal = try container.decode(Bool.self, forKey: .isModal)
        self.isEnumerated = try container.decode(Bool.self, forKey: .isEnumerated)
        self.containerType = try container.decode(ContainerType.self, forKey: .containerType)
        self.navigationStyle = try container.decode(NavigationStyle.self, forKey: .navigationStyle)
        
        for control in controls {
            control.parent = self
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        fatalError()
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
