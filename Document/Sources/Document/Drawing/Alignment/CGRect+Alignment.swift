import CoreGraphics

extension Array where Element == AlingmentPoint {
    func getFrame(original: CGRect) -> (CGRect, [AlingmentPoint]) {
        let horizontal = firstHorizontal()
        let vertical = firstVertical()
        
        let rect = original.offsetBy(dx: horizontal?.value ?? 0,
                                     dy: vertical?.value ?? 0)
        return (rect, [horizontal, vertical].compactMap { $0 })
    }
}

extension CGRect {
    
    func aligned(
        to frame: CGRect
    ) -> [AlingmentPoint] {
        AlingmentDirection
            .allCases
            .filter { edge in
                isNear(to: frame, edge: edge)
            }.map { edge in
                let value = frame.value(edge) - self.value(edge)
                return AlingmentPoint(value: value, direction: edge, frame: frame)
            }
    }

    private func isNear(
        to frame: CGRect,
        edge: AlingmentDirection
    ) -> Bool {
        let threeshold: CGFloat = 5
        return abs(self.value(edge) - frame.value(edge)) < threeshold
    }
    
    func value(_ edge: AlingmentDirection) -> CGFloat {
        switch edge {
        case .minX: return minX
        case .minY: return minY
        case .midX: return midX
            
        case .maxX: return maxX
        case .maxY: return maxY
        case .midY: return midY
        }
    }
}
