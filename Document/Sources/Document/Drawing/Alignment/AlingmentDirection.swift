import CoreGraphics

public enum AlingmentDirection: CaseIterable {
    case minX
    case maxX
    //    case centerX = 2
    
    case minY
    case maxY
    //    case centerY = 5
    
    static var horizontals: [Self] = [.minX, .maxX]
    static var verticals: [Self] = [.minY, .maxY]
}

struct AlingmentPoint: Equatable {
    let value: CGFloat
    let direction: AlingmentDirection
    let frame: CGRect
}
