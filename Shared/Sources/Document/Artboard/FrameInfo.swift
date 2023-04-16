import Foundation

/// Data transfer object that represents file structure
public struct FrameInfo: Codable {
    public var id: UUID
    public var imageScale: CGFloat
    public var frame: CGRect
    
    public static var `default`: Self {
        Self(id: UUID(), imageScale: 1, frame: .zero)
    }
}
