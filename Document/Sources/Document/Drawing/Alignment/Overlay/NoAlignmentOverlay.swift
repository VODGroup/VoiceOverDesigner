import CoreGraphics

public class NoAlignmentOverlay: AlignmentOverlayProtocol {
    public init() {}
    
    public func alignToAny(_ sourceControl: A11yControl, point: CGPoint, drawnControls: [A11yControl]) -> CGPoint {
        return point
    }
    
    public func alignToAny(_ sourceControl: A11yControl, frame: CGRect, drawnControls: [A11yControl]) -> CGRect {
        return frame
    }
    
    public func hideAligningLine() {
        // Do nothing
    }
}
