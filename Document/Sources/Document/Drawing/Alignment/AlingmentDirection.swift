import CoreGraphics

public enum AlingmentDirection: CaseIterable {
    case minX
    case maxX
    case midX
    
    case minY
    case maxY
    case midY
    
    static var horizontals: [Self] = [.minX, .maxX]
    static var verticals: [Self] = [.minY, .maxY]
}

struct AlingmentPoint: Equatable {
    let value: CGFloat
    let direction: AlingmentDirection
    let frame: CGRect
}
