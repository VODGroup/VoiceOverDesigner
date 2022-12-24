import CoreGraphics

extension CGRect {
    func isCorner(
        at point: CGPoint,
        size: CGFloat
    ) -> RectCorner? {
        for corner in RectCorner.allCases {
            let frame = frame(corner: corner, size: size)
            if frame.contains(point) {
                return corner
            }
        }
        
        return nil
    }
    
    func frame(
        corner: RectCorner,
        size: CGFloat
    ) -> CGRect {
        let center = point(at: corner)
        let origin = CGPoint(x: center.x - size/2,
                             y: center.y - size/2)
        
        let size = CGSize(width: size, height: size)
        let frame = CGRect(origin: origin, size: size)
        
        return frame
    }
    
    /// Top left origin of coordinate system
    func point(at corner: RectCorner) -> CGPoint {
        switch corner {
        case .bottomLeft:
            return CGPoint(x: minX, y: maxY)
        case .bottomRight:
            return CGPoint(x: maxX, y: maxY)
        case .topLeft:
            return CGPoint(x: minX, y: minY)
        case .topRight:
            return CGPoint(x: maxX, y: minY)
        }
    }
    
    func move(
        corner: RectCorner,
        to newLocation: CGPoint
    ) -> CGRect {
        switch corner {
        case .bottomLeft:
            let offset = CGPoint(
                x: newLocation.x - origin.x,
                y: newLocation.y - (origin.y + height))
            
            let origin = CGPoint(x: newLocation.x,
                                 y: origin.y)
            
            let size = CGSize(
                width: width - offset.x,
                height: height + offset.y)
            
            return CGRect(origin: origin, size: size)
            
        case .bottomRight:
            let size = CGSize(
                width: newLocation.x - origin.x,
                height: newLocation.y - origin.y)
            
            return CGRect(origin: origin, size: size)
            
        case .topLeft:
            let offset = CGPoint(
                x: newLocation.x - origin.x,
                y: newLocation.y - origin.y)
            
            let size = CGSize(width: width - offset.x,
                              height: height - offset.y)
            
            return CGRect(origin: newLocation, size: size)
            
        case .topRight:
            let offset = CGPoint(
                x: newLocation.x - (origin.x + width),
                y: newLocation.y - origin.y)
            
            let origin = CGPoint(x: origin.x,
                                 y: newLocation.y)
            
            let size = CGSize(
                width: width + offset.x,
                height: height - offset.y)
            
            return CGRect(origin: origin, size: size)
        }
    }
}

public enum RectCorner: CaseIterable {
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight
}
