import Document

#if canImport(UIKit)
import UIKit
public typealias View = UIView
extension View {
    func addSublayer(_ layer: CALayer) {
        self.layer.addSublayer(layer)
    }
    
    var contentScale: CGFloat {
        layer.contentsScale
    }
}
#else
import AppKit
public typealias View = NSView

extension View {
    func addSublayer(_ layer: CALayer) {
        self.layer!.addSublayer(layer)
    }
    
    var contentScale: CGFloat {
        layer!.contentsScale
    }
}
#endif

extension CALayer {
    public func updateWithoutAnimation(_ block: () -> Void) {
        CATransaction.begin()
        CATransaction.setAnimationDuration(0)
        block()
        CATransaction.commit()
    }
}

public protocol DrawingView: View {
    var drawnControls: [A11yControl] { get set }
    
    var alignmentOverlay: AlignmentOverlayProtocol { get }
    
    var copyListener: CopyModifierProtocol { get set }
    
    var escListener: EscModifierAction { get }
}

public extension DrawingView {
    
    func add(control: A11yControl) {
        control.contentsScale = contentScale
        addSublayer(control)
        drawnControls.append(control)
    }
    
    // MARK: Existed
    func control(at coordinate: CGPoint) -> A11yControl? {
        let viewsUnderCoordinate = drawnControls.filter({ control in
            control.frame.contains(coordinate)
        })

        switch viewsUnderCoordinate.count {
        case 0:
            return nil
        case 1:
            return viewsUnderCoordinate.first
        default:
            if let notContainer = viewsUnderCoordinate.first( where: { control in
                !(control.model is A11yContainer)
            }) {
                return notContainer
            } else {
                return viewsUnderCoordinate.first
            }
        }
    }
    
    func delete(control: A11yControl) {
        control.removeFromSuperlayer()
        
        if let index = drawnControls.firstIndex(of: control) {
            drawnControls.remove(at: index)
        }
    }
    
    func removeLabels() {
        for control in drawnControls {
            control.removeLabel()
        }
    }
    func addLabels() {
        for control in drawnControls {
            control.addLabel()
        }
    }
    
    func removeAll() {
        for control in drawnControls.reversed() {
            control.removeFromSuperlayer()
            drawnControls.remove(at: drawnControls.count - 1)
        }
    }
}
