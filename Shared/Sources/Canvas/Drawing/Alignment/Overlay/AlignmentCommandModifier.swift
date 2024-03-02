import CoreGraphics

public protocol AlignmentOverlayProtocol {
    func alignToAny(_ sourceControl: ArtboardElementLayer, point: CGPoint, drawnControls: [ArtboardElementLayer]) -> CGPoint
    func alignToAny(_ sourceControl: ArtboardElementLayer, frame: CGRect, drawnControls: [ArtboardElementLayer]) -> CGRect
    func hideAligningLine()
}

public class AlignmentOverlayFactory {
    public init() {}
    
    public func overlay(for view: AppView) -> AlignmentOverlayProtocol {
#if canImport(UIKit)
        return NoAlignmentOverlay()
#else
        return AlignmentCommandModifier(
            alignmentOverlay: AlignmentOverlay(view: view),
            noAlignmentOverlay: NoAlignmentOverlay())
#endif
    }
}


#if canImport(AppKit)
import AppKit

class AlignmentCommandModifier: AlignmentOverlayProtocol {
    init(alignmentOverlay: AlignmentOverlay,
         noAlignmentOverlay: NoAlignmentOverlay
    ) {
        self.alignmentOverlay = alignmentOverlay
        self.noAlignmentOverlay = noAlignmentOverlay
        
        self.keyPressMonitor = NSEvent.addLocalMonitorForEvents(matching: [.flagsChanged]) { [weak self] event in
            self?.isCommandPressed = event.modifierFlags.contains(.command)
            
            return event
        }
    }
    
    // MARK: Proxy
    func alignToAny(
        _ sourceControl: ArtboardElementLayer,
        point: CGPoint,
        drawnControls: [ArtboardElementLayer]
    ) -> CGPoint {
        currentOverlay.alignToAny(sourceControl, point: point, drawnControls: drawnControls)
    }
    
    func alignToAny(
        _ sourceControl: ArtboardElementLayer,
        frame: CGRect,
        drawnControls: [ArtboardElementLayer]
    ) -> CGRect {
        currentOverlay.alignToAny(sourceControl, frame: frame, drawnControls: drawnControls)
    }
    
    func hideAligningLine() {
        currentOverlay.hideAligningLine()
    }
    
    // MARK: Implementations
    private var alignmentOverlay: AlignmentOverlay
    private var noAlignmentOverlay: NoAlignmentOverlay
    
    private var currentOverlay: AlignmentOverlayProtocol {
        if isCommandPressed {
            return noAlignmentOverlay
        } else {
            return alignmentOverlay
        }
    }
    
    private var keyPressMonitor: Any?
    var isCommandPressed = false {
        didSet {
            if isCommandPressed {
                alignmentOverlay.hideAligningLine() // Hide alignment line event when mode changed
            }
        }
    }
}
#endif
