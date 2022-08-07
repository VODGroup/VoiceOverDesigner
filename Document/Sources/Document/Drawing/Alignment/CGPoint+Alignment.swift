import CoreGraphics

extension Array where Element == AlignmentPoint {
    func getPoint(original: CGPoint) -> (CGPoint, [AlignmentPoint]) {
        let horizontal = firstHorizontal()
        let vertical = firstVertical()
        
        let point = CGPoint(x: horizontal?.value ?? original.x,
                            y: vertical?.value ?? original.y)
        return (point, [horizontal, vertical].compactMap { $0 })
    }
    
    func first(in directions: [AlignmentDirection]) -> Element? {
        first { element in
            directions.contains(element.direction)
        }
    }
    
    func firstHorizontal() -> Element? {
        first(in: AlignmentDirection.horizontals)
    }
    
    func firstVertical() -> Element? {
        first(in: AlignmentDirection.verticals)
    }
}

extension CGPoint {
    func aligned(
        to frame: CGRect
    ) -> [AlignmentPoint]  {
        AlignmentDirection
            .allCases
            .filter { edge in
                isNear(to: frame, edge: edge)
            }
            .map { edge in
                AlignmentPoint(value: frame.value(edge), direction: edge, frame: frame)
            }
    }
    
    private func isNear(to frame: CGRect, edge: AlignmentDirection) -> Bool {
        let threeshold: CGFloat = 5
        return abs(self.value(edge) - frame.value(edge)) < threeshold
    }
    
    private func value(_ edge: AlignmentDirection) -> CGFloat {
        switch edge {
        case .minX: return x
        case .maxX: return x
        case .midX: return x
            
        case .minY: return y
        case .maxY: return y
        case .midY: return y
        }
    }
}
