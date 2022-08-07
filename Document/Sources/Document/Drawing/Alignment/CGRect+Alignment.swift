import CoreGraphics

#if canImport(AppKit)
import AppKit

public enum AlingmentDirection: CaseIterable {
    case minX
    case maxX
    
    case minY
    case maxY
//    case centerX
//    case centerY
}

extension CGRect {
    
    func aligned(
        to frame: CGRect
    ) -> (CGRect, AlingmentDirection)?  {
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
    
    private func offset(edge: AlingmentDirection, alignedFrame: CGRect) -> CGRect? {
        switch edge {
        case .minX, .maxX:
            return self.offsetBy(dx: alignedFrame.value(edge) - self.value(edge),
                                 dy: 0)
        case .minY, .maxY:
            return self.offsetBy(dx: 0,
                                 dy: alignedFrame.value(edge) - self.value(edge))
        }
    }
    
    func value(_ edge: AlingmentDirection) -> CGFloat {
        switch edge {
        case .minX: return minX
        case .minY: return minY
        case .maxX: return maxX
        case .maxY: return maxY
        }
    }
}

extension NSRectEdge {
    static var allCases: [Self] = [.minX, .maxX, .minY, .maxY]
}
#endif
