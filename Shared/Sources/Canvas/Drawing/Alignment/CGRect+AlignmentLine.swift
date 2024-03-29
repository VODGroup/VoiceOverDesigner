import CoreGraphics

extension CGRect {
    func frameForAlignmentLine(
        with: CGRect,
        edge: AlignmentDirection
    ) -> CGRect {
        let unionRect = self.union(with).insetBy(dx: -5, dy: -5)
        
        let width: CGFloat = 2
        
        switch edge {
        case .minX:
            return CGRect(
                x: unionRect.minX,
                y: unionRect.maxY,
                width: width,
                height: unionRect.minY - unionRect.maxY)
        case .maxX:
            return CGRect(
                x: unionRect.maxX,
                y: unionRect.maxY,
                width: width,
                height: unionRect.minY - unionRect.maxY)
        case .midX:
            return CGRect(
                x: unionRect.midX,
                y: unionRect.maxY,
                width: width,
                height: unionRect.minY - unionRect.maxY)
            
        case .minY:
            return CGRect(
                x: unionRect.minX,
                y: unionRect.minY,
                width: unionRect.maxX - unionRect.minX,
                height: width)
        case .maxY:
            return CGRect(
                x: unionRect.minX,
                y: unionRect.maxY,
                width: unionRect.maxX - unionRect.minX,
                height: width)
        case .midY:
            return CGRect(
                x: unionRect.minX,
                y: unionRect.midY,
                width: unionRect.maxX - unionRect.minX,
                height: width)
        }
    }
}
