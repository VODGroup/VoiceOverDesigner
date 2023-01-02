import QuartzCore

/// The HUD lives in coordinate spec of drawing element and update according to current magnifictation level
public class HUDLayer: CALayer {
    
    public var scale: CGFloat {
        didSet {
            elementOverlay.scale = scale
        }
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
        self.elementOverlay = ElementOverlayLayer(scale: 1)
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
        self.elementOverlay = ElementOverlayLayer(scale: layer.scale)
        self.tintColor = layer.tintColor
        super.init()
    }
    
    private let elementOverlay: ElementOverlayLayer
}
