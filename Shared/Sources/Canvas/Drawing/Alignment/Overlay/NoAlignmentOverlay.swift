import CoreGraphics

public class NoAlignmentOverlay: AlignmentOverlayProtocol {
    public init() {}
    
    public func alignToAny(_ sourceControl: ArtboardElementLayer, point: CGPoint, drawnControls: [ArtboardElementLayer]) -> CGPoint {
        return point
    }
    
    public func alignToAny(_ sourceControl: ArtboardElementLayer, frame: CGRect, drawnControls: [ArtboardElementLayer]) -> CGRect {
        return frame
    }
    
    public func hideAligningLine() {
        // Do nothing
    }
}
