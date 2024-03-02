import Foundation

/// Domain object that is used for drawing
public class Frame: BaseContainer, ArtboardContainer, ObservableObject {
    public var type: ArtboardType = .frame
    
    public var id: UUID
    public var label: String {
        willSet { objectWillChange.send() }
    }
    public var imageLocation: ImageLocation {
        willSet { objectWillChange.send() }
    }
    
    /// In absolute coordinates
    public var frame: CGRect
    
    public convenience init(
        label: String,
        imageName: String,
        frame: CGRect,
        elements: [any ArtboardElement]
    ) {
        self.init(
            id: UUID(),
            label: label,
            imageLocation: .fileWrapper(name: imageName),
            frame: frame,
            elements: elements)
    }
    
    public init(
        id: UUID = UUID(),
        label: String,
        imageLocation: ImageLocation,
        frame: CGRect,
        elements: [any ArtboardElement]
    ) {
        
        self.id = id
        self.label = label
        self.imageLocation = imageLocation
        self.frame = frame
        
        super.init(elements: elements)
    }
    
    // MARK: ArtboardElement
    public static func == (lhs: Frame, rhs: Frame) -> Bool {
        lhs.label == rhs.label &&
        lhs.imageLocation == rhs.imageLocation
    }
}
