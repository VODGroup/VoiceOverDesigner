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
    
    private var alignedControl: A11yControlLayer? {
        didSet {
            if alignedControl != oldValue {
                vibrate()
            }
        }
    }
    
    private var alignedEdges: [AlignmentPoint] = []
    
    func alignToAny(
        _ sourceControl: A11yControlLayer,
        point: CGPoint,
        drawnControls: [A11yControlLayer]
    ) -> CGPoint {
        
        removeAlignments()
        
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
        
        let (alignedPoint, stickedAlignments) = alignments.getPoint(original: point)
        
        self.alignedControl = drawnControls.first(where: { control in
            stickedAlignments.map { $0.frame }.contains(control.frame)
        })
        self.alignedEdges = stickedAlignments
        
        drawAligningLine(from: sourceControl.frame,
                         alignments: stickedAlignments)
        
        return alignedPoint
    }
    
    func alignToAny(
        _ sourceControl: A11yControlLayer,
        frame: CGRect,
        drawnControls: [A11yControlLayer]
    ) -> CGRect {
        
        removeAlignments()
        
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
        
        self.alignedControl = drawnControls.first(where: { control in
            stickedAlignments.map { $0.frame }.contains(control.frame)
        })
        self.alignedEdges = stickedAlignments
        
        drawAligningLine(from: sourceControl.frame,
                         alignments: stickedAlignments)
        
        return alignedFrame
    }
    
    func hideAligningLine() {
        removeAlignments()
        alignedControl = nil
        alignedEdges = []
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
    
    private func vibrate() {
        NSHapticFeedbackManager.defaultPerformer.perform(.alignment, performanceTime: .default)
    }
}
#endif
