import QuartzCore

/// The HUD lives in coordinate spec of drawing element and update according to current magnifictation level
public class HUDLayer: CALayer {
    
    public func hideHUD() {
        updateWithoutAnimation {
            isHidden = true
        }
    }
    
    public func showHUD() {
        updateWithoutAnimation {
            isHidden = true
        }
    }
    
    public func corner(for location: CGPoint) -> RectCorner? {
        selectedControlFrame?.isCorner(at: location, size: resizeMarkerSize)
    }
    
    public var scale: CGFloat {
        didSet {
            elementOverlay.resizeMarkerSize = resizeMarkerSize
            elementOverlay.resizeMarkerLineWidth = 2 * scale // TODO: Move 2 to config
            elementOverlay.borderLineWidth = lineWidth(for: scale)
        }
    }
    
    private func lineWidth(for scale: CGFloat) -> CGFloat {
        4 * scale
    }
    
    var resizeMarkerSize: CGFloat {
        Config().resizeMarkerSize * scale
    }
    
    public var selectedControlFrame: CGRect? {
        didSet {
            isHidden = selectedControlFrame == nil

            updateWithoutAnimation {
                elementOverlay.frame = selectedControlFrame ?? .zero
            }
        }
    }
    
    public var tintColor: CGColor? {
        didSet {
            elementOverlay.tintColor = tintColor
        }
    }
    
    public override init() {
        self.scale = 1
        self.elementOverlay = ElementOverlayLayer()
        super.init()
        
        addSublayer(elementOverlay)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override init(layer: Any) {
        let layer = layer as! HUDLayer
        
        self.selectedControlFrame = layer.selectedControlFrame
        self.scale = layer.scale
        self.elementOverlay = ElementOverlayLayer()
        self.tintColor = layer.tintColor
        super.init()
    }
    
    private let elementOverlay: ElementOverlayLayer
}
