import AppKit

class AlingmentOverlay: AlingmentOverlayProtocol {
    init(view: View) {
        self.view = view
    }
    
    let view: View
    
    private lazy var alignmentLine: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.backgroundColor = NSColor.lightGray.cgColor
        view.addSublayer(layer)
        return layer
    }()
    
    private var alignedControl: A11yControl? {
        didSet {
            if alignedControl != oldValue {
                vibrate()
            }
        }
    }
    
    private var alignedEdge: NSRectEdge? {
        didSet {
            if alignedEdge != oldValue {
                vibrate()
            }
        }
    }
    
    private func vibrate() {
        NSHapticFeedbackManager.defaultPerformer.perform(.alignment, performanceTime: .default)
    }
    
    func alignToAny(_ sourceControl: A11yControl, point: CGPoint, drawnControls: [A11yControl]) -> CGPoint {
        
        for control in drawnControls {
            guard control != sourceControl else { continue }
            guard let (aligned, edge) = point.aligned(to: control.frame) else {
                continue
            }
            
            self.alignedControl = control
            self.alignedEdge = edge
            
            drawAligningLine(from: control.frame, to: CGRect(origin: aligned, size: .zero), edge: edge)
            
            return aligned
        }
        
        hideAligningLine()
        return point
    }
    
    func alignToAny(_ sourceControl: A11yControl, frame: CGRect, drawnControls: [A11yControl]) -> CGRect {
        for control in drawnControls {
            guard control != sourceControl else { continue }
            guard let (aligned, edge) = frame.aligned(to: control.frame) else {
                continue
            }
            
            self.alignedControl = control
            self.alignedEdge = edge
            drawAligningLine(from: control.frame, to: sourceControl.frame, edge: edge)
            return aligned
        }
        
        hideAligningLine()
        return frame // No frames to align, return original
    }
    
    private func drawAligningLine(from: CGRect, to: CGRect, edge: NSRectEdge) {
        alignmentLine.updateWithoutAnimation {
            alignmentLine.isHidden = false
            alignmentLine.frame = from.frameForAlignmentLine(with: to, edge: edge)
        }
    }
    
    func hideAligningLine() {
        alignmentLine.isHidden = true
        alignedControl = nil
        alignedEdge = nil
    }
}
