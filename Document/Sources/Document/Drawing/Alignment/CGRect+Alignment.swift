import CoreGraphics

#if canImport(AppKit)
import AppKit

extension CGRect {
    
    func aligned(
        to frame: CGRect
    ) -> (CGRect, NSRectEdge)?  {
        for edge in NSRectEdge.allCases {
            let isNear = isNear(to: frame, edge: edge)
            
            if isNear {
                guard let offset = offset(edge: edge, alignedFrame: frame) else {
                    continue
                }
                return (offset, edge)
            }
        }
        
        return nil
    }
    
    private func isNear(to frame: CGRect, edge: NSRectEdge) -> Bool {
        let threeshold: CGFloat = 5
        return abs(self.value(edge) - frame.value(edge)) < threeshold
    }
    
    private func offset(edge: NSRectEdge, alignedFrame: CGRect) -> CGRect? {
        switch edge {
        case .minX, .maxX:
            return self.offsetBy(dx: alignedFrame.value(edge) - self.value(edge),
                                 dy: 0)
        case .minY, .maxY:
            return self.offsetBy(dx: 0,
                                 dy: alignedFrame.value(edge) - self.value(edge))
        @unknown default:
            return nil
        }
    }
    
    func value(_ edge: NSRectEdge) -> CGFloat {
        switch edge {
        case .minX: return minX
        case .minY: return minY
        case .maxX: return maxX
        case .maxY: return maxY
        @unknown default: return 0
        }
    }
}

extension NSRectEdge {
    static var allCases: [Self] = [.minX, .maxX, .minY, .maxY]
}
#endif
