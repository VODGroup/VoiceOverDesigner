import QuartzCore
import Document

class ElementOverlayLayer: CALayer {
    
    static func lineWidth(for scale: CGFloat) -> CGFloat {
        4 * scale
    }
    
    var scale: CGFloat = 1 {
        didSet {
            print("Set scale \(scale)")
            setNeedsLayout()
        }
    }
    
    var tintColor: CGColor? {
        didSet {
            updateWithoutAnimation {
                border.strokeColor = tintColor
            }
        }
    }
    
    private let border = CAShapeLayer()
    private var resizingMarkers: [ResizeMarker] = [
        ResizeMarker(),
        ResizeMarker(),
        ResizeMarker(),
        ResizeMarker(),
    ]
    
    public init(scale: CGFloat) {
        super.init()
        
        self.scale = scale
        border.fillColor = Color.clear.cgColor
        border.lineWidth = Self.lineWidth(for: scale)
        addSublayer(border)
        
        resizingMarkers.forEach { marker in
            addSublayer(marker)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
        
        let layer = layer as! ElementOverlayLayer
        self.scale = layer.scale
        // TODO: Copy any data if needed
    }
    
    override public func layoutSublayers() {
        super.layoutSublayers()
        
        updateWithoutAnimation {
            border.lineWidth = Self.lineWidth(for: scale)
            
            layoutResizeMarker()
            border.path = CGPath(roundedRect: bounds,
                                 cornerWidth: cornerRadius,
                                 cornerHeight: cornerRadius,
                                 transform: nil)
            border.frame = bounds
        }
    }
                                      
    private func layoutResizeMarker() {
        let size: CGFloat = Config().resizeMarkerSize * scale
        
        resizingMarkers[0].frame = bounds.frame(corner: .topLeft, size: size)
        resizingMarkers[1].frame = bounds.frame(corner: .topRight, size: size)
        resizingMarkers[2].frame = bounds.frame(corner: .bottomLeft, size: size)
        resizingMarkers[3].frame = bounds.frame(corner: .bottomRight, size: size)
        
        for marker in resizingMarkers {
            marker.lineWidth = 2 * scale
        }
    }
}
