import AppKit

protocol AlingmentOverlayProtocol {
    func alignToAny(_ sourceControl: A11yControl, point: CGPoint, drawnControls: [A11yControl]) -> CGPoint
    func alignToAny(_ sourceControl: A11yControl, frame: CGRect, drawnControls: [A11yControl]) -> CGRect
    func hideAligningLine()
}

class AlingmentCommandModifier: AlingmentOverlayProtocol {
    init(alingmentOverlay: AlingmentOverlay,
         noAlingmentOverlay: NoAlignmentOverlay
    ) {
        self.alingmentOverlay = alingmentOverlay
        self.noAlingmentOverlay = noAlingmentOverlay
        
        self.keyPressMonitor = NSEvent.addLocalMonitorForEvents(matching: [.flagsChanged]) { [weak self] event in
            self?.isCommandPressed = event.modifierFlags.contains(.command)
            
            return event
        }
    }
    
    // MARK: Proxy
    func alignToAny(_ sourceControl: A11yControl, point: CGPoint, drawnControls: [A11yControl]) -> CGPoint {
        currentOverlay.alignToAny(sourceControl, point: point, drawnControls: drawnControls)
    }
    
    func alignToAny(_ sourceControl: A11yControl, frame: CGRect, drawnControls: [A11yControl]) -> CGRect {
        currentOverlay.alignToAny(sourceControl, frame: frame, drawnControls: drawnControls)
    }
    
    func hideAligningLine() {
        currentOverlay.hideAligningLine()
    }
    
    // MARK: Implementations
    private var alingmentOverlay: AlingmentOverlay
    private var noAlingmentOverlay: NoAlignmentOverlay
    
    private var currentOverlay: AlingmentOverlayProtocol {
        if isCommandPressed {
            return noAlingmentOverlay
        } else {
            return alingmentOverlay
        }
    }
    
    private var keyPressMonitor: Any?
    var isCommandPressed = false {
        didSet {
            if isCommandPressed {
                alingmentOverlay.hideAligningLine() // Hide alingment line event when mode changed
            }
            print(isCommandPressed ? "Pressed": "Released")
        }
    }
}