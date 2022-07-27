#if canImport(UIKit)
import UIKit
public typealias View = UIView
extension View {
    func addSublayer(_ layer: CALayer) {
        self.layer.addSublayer(layer)
    }
}
#else
import AppKit
public typealias View = NSView

extension View {
    func addSublayer(_ layer: CALayer) {
        self.layer!.addSublayer(layer)
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
}

public extension DrawingView {
    
    func add(control: A11yControl) {
        addSublayer(control)
        drawnControls.append(control)
    }
    
    // MARK: Existed
    func control(at coordinate: CGPoint) -> A11yControl? {
        drawnControls.first { control in
            control.frame.contains(coordinate)
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
        for contol in drawnControls {
            contol.removeFromSuperlayer()
        }
    }
}
