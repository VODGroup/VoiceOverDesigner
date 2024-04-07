import Document

#if canImport(UIKit)
import UIKit
public typealias AppView = UIView
extension AppView {
    var unwrappedLayer: CALayer {
        layer
    }
}
#else
import AppKit
public typealias AppView = NSView

extension AppView {
    var unwrappedLayer: CALayer {
        layer!
    }
}
#endif

extension AppView {
    func addSublayer(_ layer: CALayer) {
        unwrappedLayer.addSublayer(layer)
    }
    
    var contentScale: CGFloat {
        unwrappedLayer.contentsScale
    }
    
    var sublayers: [CALayer] {
        unwrappedLayer.sublayers ?? []
    }
    
    func absoluteFrame(of rect: CGRect, for element: CALayer) -> CGRect {
        unwrappedLayer.convert(rect, from: element.superlayer)
    }
    
    func relativeFrame(of rect: CGRect, in parent: CALayer?) -> CGRect {
        unwrappedLayer.convert(rect, to: parent)
    }
}

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
    
    public var frames: [Canvas.FrameLayer] {
        return sublayers.compactMap({ layer in
            layer as? FrameLayer
        })
    }
    
    /// Contains flatten version of every A11yControlLayer
    public var drawnControls: [ControlLayer] {
        sublayers
            .flatMap({ layer in
                layer.nestedControlsLayers()
            })
    }
}

extension CALayer {
    /// Return element and all sublayers
    func nestedControlsLayers<T>() -> [T] {
        var result = [T]()
        
        if let control = self as? T {
            result.append(control)
        }
        
        let conformingSublayers = sublayers?
            .compactMap({ layer in
                layer as? T
            }) ?? []
        
    
        result.append(contentsOf: conformingSublayers)
    
        return result
    }
}

public extension DrawingView {
    
    func add(frame: FrameLayer) {
        addSublayer(frame)
    }
    
    func add(control: ControlLayer,
             to parent: CALayer? = nil // TODO: Remove default
    ) {
        control.contentsScale = contentScale
        
        if let parent {
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
    ) -> ControlLayer? {
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
    
    func drawnControls(for container: any ArtboardContainer) -> [ControlLayer] {
        drawnControls.filter { layer in
            container.elements.contains { $0 === layer.model }
        }
    }
    
    func recalculateAbsoluteFrameForNestedElements(
        in container: any ArtboardContainer
    ) {
        for nestedLayer in drawnControls(for: container) {
            let relativeFrame = nestedLayer.frame
            
            nestedLayer.recalculateAbsoluteFrameInModel(to: relativeFrame, in: self)
            
            // TODO: Won't work on nested containers or should be recursive
        }
    }
}
