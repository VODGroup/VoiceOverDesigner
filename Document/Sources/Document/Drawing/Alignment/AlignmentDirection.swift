import CoreGraphics

public enum AlignmentDirection: CaseIterable {
    case minX
    case maxX
    case midX
    
    case minY
    case maxY
    case midY
    
    static var horizontals: [Self] = [.minX, .maxX, .midX]
    static var verticals: [Self] = [.minY, .maxY, .midY]
}

struct AlignmentPoint: Equatable {
    let value: CGFloat
    let direction: AlignmentDirection
    let frame: CGRect
}
