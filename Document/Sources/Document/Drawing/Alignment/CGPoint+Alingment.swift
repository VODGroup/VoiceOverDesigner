import CoreGraphics

extension Array where Element == AlingmentPoint {
    func getPoint(original: CGPoint) -> CGPoint {
        CGPoint(x: firstHorizontal() ?? original.x,
                y: firstVertical() ?? original.y)
    }
    
    func first(in directions: [AlingmentDirection]) -> CGFloat? {
        first { element in
            directions.contains(element.direction)
        }?.value
    }
    
    func firstHorizontal() -> CGFloat? {
        first(in: AlingmentDirection.horizontals)
    }
    
    func firstVertical() -> CGFloat? {
        first(in: AlingmentDirection.verticals)
    }
}

extension CGPoint {
    func aligned(
        to frame: CGRect
    ) -> [AlingmentPoint]  {
        AlingmentDirection
            .allCases
            .filter { edge in
                isNear(to: frame, edge: edge)
            }
            .map { edge in
                AlingmentPoint(value: frame.value(edge), direction: edge, frame: frame)
            }
    }
    
    private func isNear(to frame: CGRect, edge: AlingmentDirection) -> Bool {
        let threeshold: CGFloat = 5
        return abs(self.value(edge) - frame.value(edge)) < threeshold
    }
    
    private func value(_ edge: AlingmentDirection) -> CGFloat {
        switch edge {
        case .minX: return x
        case .maxX: return x
        case .minY: return y
        case .maxY: return y
        }
    }
}
