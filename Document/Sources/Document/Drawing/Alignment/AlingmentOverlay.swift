import AppKit

class AlingmentOverlay {
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
                NSHapticFeedbackManager.defaultPerformer.perform(.alignment, performanceTime: .default)
                print("hap")
            }
        }
    }
    
    private var alignedEdge: NSRectEdge? {
        didSet {
            if alignedEdge != oldValue {
                NSHapticFeedbackManager.defaultPerformer.perform(.alignment, performanceTime: .default)
                print("hap")
            }
        }
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
            alignmentLine.frame = alignmentFrame(from: from, to: to, edge: edge)
        }
    }
    
    private func alignmentFrame(from: CGRect, to: CGRect, edge: NSRectEdge) -> CGRect {
        let unionRect = from.union(to).insetBy(dx: -5, dy: -5)
        
        switch edge {
        case .minX:
            return CGRect(
                x: unionRect.minX,
                y: unionRect.maxY,
                width: 1,
                height: unionRect.minY - unionRect.maxY)
        case .maxX:
            return CGRect(
                x: unionRect.maxX,
                y: unionRect.maxY,
                width: 1,
                height: unionRect.minY - unionRect.maxY)
        case .minY:
            return CGRect(
                x: unionRect.minX,
                y: unionRect.minY,
                width: unionRect.maxX - unionRect.minX,
                height: 1)
        case .maxY:
            return CGRect(
                x: unionRect.minX,
                y: unionRect.maxY,
                width: unionRect.maxX - unionRect.minX,
                height: 1)
        @unknown default: return .zero
        }
    }
    
    func hideAligningLine() {
        alignmentLine.isHidden = true
        alignedControl = nil
        alignedEdge = nil
    }
}
