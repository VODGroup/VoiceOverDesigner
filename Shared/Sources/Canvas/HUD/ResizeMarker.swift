import QuartzCore
import Document

class ResizeMarker: CAShapeLayer {
    override init() {
        super.init()
        
        fillColor = Color.systemBlue.cgColor
        strokeColor = Color.white.cgColor
    }
    
    override func layoutSublayers() {
        super.layoutSublayers()
        
        let sideSize = bounds.width
        let size = CGSize(width: sideSize, height: sideSize)
        let rect = CGRect(origin: .zero, size: size)
        let circle = CGPath(ellipseIn: rect, transform: nil)
        
        path = circle
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


