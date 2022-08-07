#if canImport(AppKit)
import AppKit

extension CGPoint {
    func aligned(
        to frame: CGRect
    ) -> (CGPoint, AlingmentDirection)?  {
        for edge in AlingmentDirection.allCases {
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
    
    private func isNear(to frame: CGRect, edge: AlingmentDirection) -> Bool {
        let threeshold: CGFloat = 5
        return abs(self.value(edge) - frame.value(edge)) < threeshold
    }
    
    private func offset(edge: AlingmentDirection, alignedFrame: CGRect) -> CGPoint? {
        switch edge {
        case .minX, .maxX:
            return CGPoint(x: alignedFrame.value(edge),
                           y: y)
        case .minY, .maxY:
            return CGPoint(x: x,
                           y: alignedFrame.value(edge))
        }
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
#endif
