import Foundation
import Artboard

extension A11yContainer: ArtboardContainer, InstantiatableContainer {
}

public class A11yContainer: BaseContainer, Codable, ObservableObject {

    required convenience public init(
        elements: [any ArtboardElement],
        frame: CGRect,
        label: String
    ) {
        self.init(elements: elements as! [A11yDescription], frame: frame, label: label, isModal: false)
    }
    
    public init(
        id: UUID = UUID(),
        elements: [any ArtboardElement],
        frame: CGRect,
        label: String,
        isModal: Bool = false,
        isTabTrait: Bool = false,
        treatButtonsAsAdjustableValues: Bool = false,
        isEnumerated: Bool = false,
        containerType: ContainerType = .semanticGroup,
        navigationStyle: NavigationStyle = .automatic
    ) {
        self.frame = frame
        self.label = label
        
        super.init(elements: elements)
        
        self.containerType = containerType
        self.navigationStyle = navigationStyle
        self.id = id
        
        self.isModal = isModal
        self.isTabTrait = isTabTrait
        self.treatButtonsAsAdjustable = treatButtonsAsAdjustableValues
        self.isEnumerated = isEnumerated
        
    }

    public static func ==(lhs: A11yContainer, rhs: A11yContainer) -> Bool {
        lhs.frame == rhs.frame
        && lhs.label == rhs.label
    }

    @DecodableDefault.RandomUUID
    public var id: UUID
    
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
    
    @DecodableDefault.False
    public var treatButtonsAsAdjustable: Bool {
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
    
    public enum ContainerType: String, Codable, CaseIterable, Identifiable {
        case none
//        case dataTable
        case semanticGroup
        case list
        public var id: Self { self }
    }
    
    public enum NavigationStyle: String, Codable, CaseIterable, Identifiable {
        case automatic
        case separate
        case combined
        
        public var id: Self { self }
    }
    
    
    public func contains(_ element: A11yDescription) -> Bool {
        elements.contains { anElement in
            anElement === element
        }
    }
    
    enum CodingKeys: CodingKey {
        case type
        case label
        case frame
        
        case elements
        
        case isModal
        case isTabTrait
        case isEnumerated
        case containerType
        case navigationStyle
        case treatButtonsAsAdjustable
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.label = try container.decode(String.self, forKey: .label)
        self.frame = try container.decode(CGRect.self, forKey: .frame)
        let elements = try container.decode([ArtboardElementDecodable].self, forKey: .elements) // TODO: Nested containers are possible
        
        super.init(elements: elements.map(\.view))
        
        self.isModal = try container.decode(Bool.self, forKey: .isModal)
        self.isEnumerated = try container.decode(Bool.self, forKey: .isEnumerated)
        self.containerType = try container.decode(ContainerType.self, forKey: .containerType)
        self.navigationStyle = try container.decode(NavigationStyle.self, forKey: .navigationStyle)
        self.isTabTrait = try container.decode(Bool.self, forKey: .isTabTrait)
        self.treatButtonsAsAdjustable = (try? container.decode(Bool.self, forKey: .treatButtonsAsAdjustable)) ?? false
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(ArtboardType.container, forKey: .type)
        try container.encode(label, forKey: .label)
        try container.encode(frame, forKey: .frame)
        try container.encode(elements.map(ArtboardElementDecodable.init(view:)), forKey: .elements)
        try container.encode(isModal, forKey: .isModal)
        try container.encode(isEnumerated, forKey: .isEnumerated)
        try container.encode(containerType, forKey: .containerType)
        try container.encode(navigationStyle, forKey: .navigationStyle)
        try container.encode(isTabTrait, forKey: .isTabTrait)
        try container.encode(treatButtonsAsAdjustable, forKey: .treatButtonsAsAdjustable)
    }
}

// MARK: - Adjustable Proxy
extension A11yContainer {
    
    public var canTraitAsAdjustable: Bool {
        buttons.count > 1
    }
    
    public var adjustableProxy: A11yDescription? {
        guard treatButtonsAsAdjustable,
              canTraitAsAdjustable else {
            return nil
        }
        
        let proxy =  A11yDescription(
            isAccessibilityElement: true,
            label: label,
            value: "",
            hint: "",
            trait: .adjustable,
            frame: frame,
            adjustableOptions: AdjustableOptions(
                options: buttons.map { $0.label },
                currentIndex: 0,
                isEnumerated: isEnumerated),
            customActions: A11yCustomActions())
        
        return proxy
    }
    
    var buttons: [A11yDescription] {
        extractElements()
            .filter { $0.trait.contains(.button) }
    }
}
