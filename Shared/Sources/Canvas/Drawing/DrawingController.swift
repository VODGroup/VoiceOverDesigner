import CoreGraphics
import QuartzCore
import Combine
import Document

public class DrawingController {
    
    public enum Pointer: Equatable {
        case hover
        case dragging
        case resize(RectCorner)
        case crosshair
        case copy
    }
    
    public init(view: DrawingView) {
        self.view = view
        
#if os(macOS)
        view.wantsLayer = true

#endif
    }
    
    public let view: DrawingView
    private var action: DraggingAction?
    public var pointerPublisher: AnyPublisher<Pointer?, Never> {
        pointerSubject
            .eraseToAnyPublisher()
    }
    private var pointerSubject = PassthroughSubject<Pointer?, Never>()
    

    
    // MARK: Drawn from existed controls
    
    /// Draw all elements and containers on screen
    /// - Parameters:
    ///   - scale: Relative scale to fit controls on screen. Is neede for Preview
    public func draw(
        artboard: Artboard,
        scale: CGFloat
    ) {
        drawElements(
            controls: artboard.elements,
            scale: scale,
            containerLayer: nil, // DrawingView in itself
            imageLoader: artboard.imageLoader)
        
        view.invalidateIntrinsicContentSize()
    }
    
    func drawElements(
        controls: [any ArtboardElement],
        scale: CGFloat,
        containerLayer: CALayer?,
        imageLoader: ImageLoading
    ) {
        for control in controls {
            switch control.cast {
            case .frame(let frame):
                draw(frame: frame,
                     imageLoader: imageLoader,
                     scale: scale)
                
            case .container(let container):
                let containerLayer = draw(container: container, scale: scale, in: containerLayer)
                
                for element in container.elements {
                    draw(element: element,
                         scale: scale, in: containerLayer)
                }
                
            case .element(let element):
                draw(element: element, scale: scale, in: containerLayer)
            }
        }
    }
    
    private func draw(frame: Frame, imageLoader: ImageLoading, scale: CGFloat) {
        let frameLayer = drawImage(for: frame, imageLoader: imageLoader, scale: scale)
        
        drawElements(controls: frame.elements,
                                  scale: scale,
                                  containerLayer: frameLayer,
                                  imageLoader: imageLoader)
    }
    
    @discardableResult
    private func drawImage(
        for frame: Frame,
        imageLoader: ImageLoading,
        scale: CGFloat
    ) -> CALayer {
        let imageLayer = frameLayer(for: frame, imageLoader: imageLoader)
        imageLayer.frame = frame.frame
        imageLayer.contentsScale = scale
        
        return imageLayer
    }
    
    @discardableResult
    private func draw(
        element: any ArtboardElement,
        scale: CGFloat,
        in parent: CALayer? = nil // TODO: Remove default
    ) -> A11yControlLayer {
        let control = layer(for: element, in: parent)
        control.frame = element.frame.scaled(scale)
        control.backgroundColor = element.color.cgColor
        
        return control
    }
    
    private func frameLayer(
        for frame: Frame,
        imageLoader: ImageLoading
    ) -> ImageLayer {
        if let cachedLayer = cachedFrameLayer(for: frame)  {
            return cachedLayer
        }
        
        // Create new
        let layer = ImageLayer(model: frame)
        layer.image = imageLoader.image(for: frame)?.defaultCGImage
        view.add(frame: layer)
        
        return layer
    }
    
    private func layer(
        for model: any ArtboardElement,
        in parent: CALayer?
    ) -> A11yControlLayer {
        if let cachedLayer = cachedLayer(for: model) {
            return cachedLayer
        } else {
            let layer = A11yControlLayer(model: model)
            view.add(control: layer, to: parent)
            return layer
        }
    }
    
    func cachedLayer(for model: any ArtboardElement) -> A11yControlLayer? {
        view.drawnControls.first(where: { layer in
            layer.model === model
        })
    }
    
    func cachedFrameLayer(for frame: Frame) -> ImageLayer? {
        view.frames.first(where:  { layer in
            layer.model === frame
        })
    }
    
    @discardableResult
    public func draw(
        container: any ArtboardElement,
        scale: CGFloat,
        in parent: CALayer?
    ) -> A11yControlLayer {
        let container = draw(element: container,
                             scale: scale,
                             in: parent)
//        container.strokeColor = model.color.cgColor
        container.cornerCurve = .continuous
        container.cornerRadius = 20
        container.masksToBounds = true
         
        return container
    }
    
    // MARK: New drawing
    public func mouseDown(
        on location: CGPoint,
        selectedControl: ArtboardElementLayer?
    ) {
        if let selectedControl {
            if let corner = view.hud.corner(for: location) {
                startResizing(control: selectedControl, startLocation: location, corner: corner)
                return
            } else if let frame = selectedControl as? ImageLayer {
                startDragging(control: frame, startLocation: location)
                return
            }
        }
        
        if let existedControl = view.control(at: location) {
            startDragging(control: existedControl, startLocation: location)
        } else {
            startDrawing(coordinate: location)
        }
    }
    
    public func mouseMoved(
        on location: CGPoint,
        selectedControl: ArtboardElementLayer?
    ) {
        if let corner = view.hud.corner(for: location) {
            pointerSubject.send(.resize(corner))
            return
        }
        
        let hasElementUnderCursor = view.control(at: location) != nil
        let isFrameSelected = selectedControl is ImageLayer
        if hasElementUnderCursor || isFrameSelected {
            pointerSubject.send(view.copyListener.isModifierActive ? .copy : .hover)
        } else {
            pointerSubject.send(nil)
        }
    }
    
    private func startDragging(
        control: ArtboardElementLayer,
        startLocation: CGPoint
    ) {
        action = CopyAndTranslateAction(view: view, sourceControl: control, startLocation: startLocation, offset: .zero, initialFrame: control.frame)
    }
    
    private func startResizing(
        control: ArtboardElementLayer,
        startLocation: CGPoint,
        corner: RectCorner
    ) {
        action = ResizeAction(view: view, control: control, startLocation: startLocation, offset: .zero, initialFrame: control.frame, corner: corner)
    }
    
    private func startDrawing(coordinate: CGPoint) {
        let control = draw(
            element: A11yDescription.empty(frame: .zero),
            scale: 1)
        
        self.action = NewControlAction(view: view, control: control, coordinate: coordinate)
        pointerSubject.send(.crosshair)
    }
    
    public func drag(to coordinate: CGPoint) {
        action?.drag(to: coordinate)
        updateDragCursor()
    }
    
    private func updateDragCursor() {
        guard action is CopyAndTranslateAction else { return }
        pointerSubject.send(view.copyListener.isModifierActive ? .copy : .dragging)
    }
    
    public func end(coordinate: CGPoint) -> DraggingAction? {
        defer {
            self.action = nil
            view.alignmentOverlay.hideAligningLine()
        }
        
        drag(to: coordinate)
        
        return action?.end(at: coordinate)
    }

    public func cancelOperation() {
        action?.cancel()
        action = nil
    }
}

extension CGRect {
    public func scaled(_ scale: CGFloat) -> CGRect {
        CGRect(x: minX * scale,
               y: minY * scale,
               width: width * scale,
               height: height * scale)
    }
}

public class ArtboardElementLayer: CALayer {
    public var model: (any ArtboardElement)?
    
    init(model: any ArtboardElement) {
        self.model = model
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override init(layer: Any) {
        super.init(layer: layer)
    }
    
    public func update(
        to relativeFrame: CGRect,
        in view: DrawingView
    ) {
        frame = relativeFrame
        
        let absoluteFrame = view.absoluteFrame(
            of: frame,
            for: self)
        //        print("Set frame to model \(absoluteFrame)")
        
        model?.frame = absoluteFrame
    }
}

public class ImageLayer: ArtboardElementLayer {
    
    public var image: CGImage? {
        set {
            contents = newValue
        }
        
        get {
            guard let contents else { return nil }
            return contents as! CGImage
        }
    }
}


extension Image {
    var defaultCGImage: CGImage? {
#if os(macOS)
        return cgImage(forProposedRect: nil, context: nil, hints: nil)
#elseif os(iOS) || os(visionOS)
        return cgImage
#endif
    }
}
