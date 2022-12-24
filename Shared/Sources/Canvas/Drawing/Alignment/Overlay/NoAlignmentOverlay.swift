import CoreGraphics

public class NoAlignmentOverlay: AlignmentOverlayProtocol {
    public init() {}
    
    public func alignToAny(_ sourceControl: A11yControlLayer, point: CGPoint, drawnControls: [A11yControlLayer]) -> CGPoint {
        return point
    }
    
    public func alignToAny(_ sourceControl: A11yControlLayer, frame: CGRect, drawnControls: [A11yControlLayer]) -> CGRect {
        return frame
    }
    
    public func hideAligningLine() {
        // Do nothing
    }
}
