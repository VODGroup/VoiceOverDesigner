import QuartzCore
import Document

class ResizeMarker: CAShapeLayer {
    override init() {
        super.init()
        let size = Config().resizeMarkerSize
        let circle = CGPath(ellipseIn: CGRect(origin: .zero,
                                              size: CGSize(width: size, height: size)),
                            transform: nil)
        
        path = circle
        fillColor = Color.systemBlue.cgColor
        lineWidth = 4
        strokeColor = Color.white.cgColor
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
    }
    
    // TODO: Init with layer
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
