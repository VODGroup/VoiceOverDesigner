import AppKit

class NoAlignmentOverlay: AlingmentOverlayProtocol {
    func alignToAny(_ sourceControl: A11yControl, point: CGPoint, drawnControls: [A11yControl]) -> CGPoint {
        return point
    }
    
    func alignToAny(_ sourceControl: A11yControl, frame: CGRect, drawnControls: [A11yControl]) -> CGRect {
        return frame
    }
    
    func hideAligningLine() {
        // Do nothing
    }
}
