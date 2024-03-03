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
    var alignmentOverlay: AlignmentOverlayProtocol { get }
    var hud: HUDLayer { get }
    
    var copyListener: CopyModifierAction { get set }
}

extension DrawingView {
    
    public var frames: [Canvas.ImageLayer] {
        guard let sublayers = layer?.sublayers else {
            return []
        }
        
        return sublayers.compactMap({ layer in
            layer as? ImageLayer
        })
    }
    
    public var drawnControls: [A11yControlLayer] {
        guard let sublayers = layer?.sublayers else {
            return []
        }
        
        let containers = sublayers.flatMap({ layer in
            layer.controlsLayerRecursive()
        })
        
        return containers
    }
}

extension CALayer {
    func controlsLayerRecursive() -> [A11yControlLayer] {
        if let control = self as? A11yControlLayer, sublayers?.isEmpty ?? true {
            return [control]
        } else {
            return sublayers?.compactMap({ layer in
                layer as? A11yControlLayer
            }) ?? []
        }
    }
}

extension DrawingView {
    func absoluteFrame(for element: CALayer) -> CGRect {
        absoluteFrame(of: element.frame,
                      for: element)
    }
    
    func absoluteFrame(of rect: CGRect, for element: CALayer) -> CGRect {
        layer!.convert(rect,
                       to: element.superlayer)
    }
}

public extension DrawingView {
    
    func add(frame: ImageLayer) {
        addSublayer(frame)
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
    }
    
    // MARK: Existed
    func control(at coordinate: CGPoint) -> ArtboardElementLayer? {
        // TODO: Refactor
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
    
    func delete(control: ArtboardElementLayer) {
        control.removeFromSuperlayer()
    }

    func layer(
        for model: any ArtboardElement
    ) -> A11yControlLayer? {
        drawnControls
        .first(where: { control in
            control.model === model
        })
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
