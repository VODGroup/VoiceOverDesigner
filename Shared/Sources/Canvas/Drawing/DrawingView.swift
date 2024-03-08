import Document

#if canImport(UIKit)
import UIKit
public typealias AppView = UIView
extension AppView {
    func addSublayer(_ layer: CALayer) {
        self.layer.addSublayer(layer)
    }
    
    var contentScale: CGFloat {
        layer.contentsScale
    }
}
#else
import AppKit
public typealias AppView = NSView

extension AppView {
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

public protocol DrawingView: AppView {
    var drawnControls: [A11yControlLayer] { get set }
    var frames: [ImageLayer] { get set }
    
    var alignmentOverlay: AlignmentOverlayProtocol { get }
    var hud: HUDLayer { get }
    
    var copyListener: CopyModifierAction { get set }
}

extension DrawingView {
    func absoluteFrame(for element: CALayer) -> CGRect {
        absoluteFrame(of: element.frame,
                      for: element)
    }
    
    func absoluteFrame(of rect: CGRect, for element: CALayer) -> CGRect {
        layer!.convert(rect,
                       to: element.superlayer!)
    }
}

public extension DrawingView {
    
    func add(frame: ImageLayer) {
        addSublayer(frame)
        frames.append(frame)
    }
    
    func add(control: A11yControlLayer,
             to parent: CALayer? = nil // TODO: Remove default
    ) {
        control.contentsScale = contentScale
        
        if let parent {
            control.frame = layer!.convert(control.frame,
                                           to: parent)
            parent.addSublayer(control)
        } else {
            addSublayer(control)
        }
        drawnControls.append(control)
    }
    
    // MARK: Existed
    func control(at coordinate: CGPoint) -> A11yControlLayer? {
        let viewsUnderCoordinate = drawnControls.filter({ control in
            control.model!.frame.contains(coordinate)
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
    
    func delete(control: A11yControlLayer) {
        control.removeFromSuperlayer()
        
        if let index = drawnControls.firstIndex(of: control) {
            drawnControls.remove(at: index)
        }
    }
    
    func removeAll() {
        for frame in frames.reversed() {
            frame.removeFromSuperlayer()
            frames.remove(at: frames.count - 1)
        }
        
        for control in drawnControls.reversed() {
            control.removeFromSuperlayer()
            _ = drawnControls.popLast()
        }
    }
    
    func remove(_ model: any ArtboardElement) {
        guard let index = drawnControls.firstIndex(where: {
            $0.model === model
        }), let control = drawnControls.first(where: {
            $0.model === model
        }) else { return }
        control.removeFromSuperlayer()
        drawnControls.remove(at: index)
    }
    
    func addHUD() {
        hud.removeFromSuperlayer()
        addSublayer(hud)
        hud.zPosition = 10_000
    }
    
    func drawnControls(for container: any ArtboardContainer) -> [A11yControlLayer] {
        drawnControls.filter { layer in
            container.elements.contains { $0 === layer.model }
        }
    }
}
