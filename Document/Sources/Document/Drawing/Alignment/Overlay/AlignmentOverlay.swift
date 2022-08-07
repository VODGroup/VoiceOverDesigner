#if canImport(AppKit)
import AppKit

class AlignmentOverlay: AlignmentOverlayProtocol {
    init(view: View) {
        self.view = view
    }
    
    let view: View
    
    private var alignmentLines: [CALayer] = []
    
    private func createAlignmentLine() -> CAShapeLayer {
        let line = CAShapeLayer()
        line.backgroundColor = NSColor.systemRed.cgColor
        view.addSublayer(line)
        alignmentLines.append(line)
        return line
    }
    
    private func removeAlignments() {
        for alignmentLine in alignmentLines {
            alignmentLine.removeFromSuperlayer()
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
    
    private var alignedEdges: [AlignmentPoint] = [] {
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
        
        hideAligningLine()
        
        let alignments: [AlignmentPoint] = drawnControls
            .filter { control in
                control != sourceControl
            }.map { control in
                point.aligned(to: control.frame)
            }.reduce([]) { partialResult, alignments in
                var res = partialResult
                res.append(contentsOf: alignments)
                return res
            }
        
        let (alignedPoint, stickedAlignemntes) = alignments.getPoint(original: point)
        
        drawAligningLine(from: sourceControl.frame,
                         alignments: stickedAlignemntes)
        
        return alignedPoint
    }
    
    func alignToAny(
        _ sourceControl: A11yControl,
        frame: CGRect,
        drawnControls: [A11yControl]
    ) -> CGRect {
        
        hideAligningLine()
        
        let alignments: [AlignmentPoint] = drawnControls
            .filter { control in
                control != sourceControl
            }.map { control in
                frame.aligned(to: control.frame)
            }.reduce([]) { partialResult, alignments in
                var res = partialResult
                res.append(contentsOf: alignments)
                return res
            }
        
        let (alignedFrame, stickedAlignments) = alignments.getFrame(original: frame)
        
        self.alignedEdges = stickedAlignments
        
        drawAligningLine(from: sourceControl.frame,
                         alignments: stickedAlignments)
        
        return alignedFrame
    }
    
    private func drawAligningLine(
        from: CGRect,
        alignments: [AlignmentPoint]
    ) {
        for edge in alignments {
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
        removeAlignments()
        alignedControl = nil
        alignedEdges = []
    }
}
#endif
