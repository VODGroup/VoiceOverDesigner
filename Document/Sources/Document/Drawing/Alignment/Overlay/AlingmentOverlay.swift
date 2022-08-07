#if canImport(AppKit)
import AppKit

class AlingmentOverlay: AlingmentOverlayProtocol {
    init(view: View) {
        self.view = view
    }
    
    let view: View
    
    private var alignmentLines: [CALayer] = []
    
    private func createAlignmentLine() -> CAShapeLayer {
        let line = CAShapeLayer()
        line.backgroundColor = NSColor.lightGray.cgColor
        view.addSublayer(line)
        alignmentLines.append(line)
        return line
    }
    
    private func removeAlingments() {
        for alingmentLine in alignmentLines {
            alingmentLine.removeFromSuperlayer()
        }
        
        alignmentLines = []
    }
    
    private var alignedControl: A11yControl? {
        didSet {
            if alignedControl != oldValue {
                vibrate()
            }
        }
    }
    
    private var alignedEdges: [AlingmentPoint] = [] {
        didSet {
            if alignedEdges != oldValue {
                vibrate()
            }
        }
    }
    
    private func vibrate() {
        NSHapticFeedbackManager.defaultPerformer.perform(.alignment, performanceTime: .default)
    }
    
    func alignToAny(
        _ sourceControl: A11yControl,
        point: CGPoint,
        drawnControls: [A11yControl]
    ) -> CGPoint {
        
//        removeAlingments()
        hideAligningLine()
        
        let alingments: [AlingmentPoint] = drawnControls
            .filter { control in
                control != sourceControl
            }.map { control in
                point.aligned(to: control.frame)
            }.reduce([]) { partialResult, alingments in
                var res = partialResult
                res.append(contentsOf: alingments)
                return res
            }
        
        drawAligningLine(from: sourceControl.frame,
                         alingments: alingments)
        
        return alingments.getPoint(original: point)
    }
    
    func alignToAny(
        _ sourceControl: A11yControl,
        frame: CGRect,
        drawnControls: [A11yControl]
    ) -> CGRect {
        
        hideAligningLine()
        
        let alingments: [AlingmentPoint] = drawnControls
            .filter { control in
                control != sourceControl
            }.map { control in
                frame.aligned(to: control.frame)
            }.reduce([]) { partialResult, alingments in
                var res = partialResult
                res.append(contentsOf: alingments)
                return res
            }
        
        self.alignedEdges = alingments
        
        let alingedFrame = alingments.getFrame(original: frame)
        
        drawAligningLine(from: sourceControl.frame,
                         alingments: alingments)
        
        return alingedFrame
    }
    
    private func drawAligningLine(
        from: CGRect,
        alingments: [AlingmentPoint]
    ) {
        for edge in alingments {
            let line = createAlignmentLine()
            line.updateWithoutAnimation {
                line.isHidden = false
                line.frame = from.frameForAlignmentLine(
                    with: edge.frame,
                    edge: edge.direction)
            }
        }
    }
    
    func hideAligningLine() {
        removeAlingments()
        alignedControl = nil
        alignedEdges = []
    }
}
#endif
