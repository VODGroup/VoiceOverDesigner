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
        // Remove animation when wrap elements in container
        view.unwrappedLayer.updateWithoutAnimation {
            drawElements(
                artboard.elements,
                in: nil, // DrawingView in itself
                scale: scale,
                imageLoader: artboard.imageLoader)
        }
        
        view.invalidateIntrinsicContentSize()
    }
    
    func drawElements(
        _ controls: [any ArtboardElement],
        in parentLayer: CALayer?,
        scale: CGFloat,
        imageLoader: ImageLoading
    ) {
        for control in controls {
            switch control.cast {
            case .frame(let frame):
                draw(frame: frame,
                     imageLoader: imageLoader,
                     scale: scale)
                
            case .container(let container):
                let containerLayer = draw(container: container,
                                          in: parentLayer,
                                          scale: scale)
                
                for element in container.elements {
                    draw(element: element,
                         scale: scale, in: containerLayer)
                }
                
            case .element(let element):
                draw(element: element, scale: scale, in: parentLayer)
            }
        }
    }
    
    private func draw(frame: Frame, imageLoader: ImageLoading, scale: CGFloat) {
        let frameLayer = drawImage(for: frame, imageLoader: imageLoader, scale: scale)
        
        drawElements(frame.elements,
                     in: frameLayer,
                     scale: scale,
                     imageLoader: imageLoader)
    }
    
    @discardableResult
    private func drawImage(
        for frame: Frame,
        imageLoader: ImageLoading,
        scale: CGFloat
    ) -> CALayer {
        let frameLayer = frameLayer(for: frame, imageLoader: imageLoader)
        frameLayer.frame = frame.frame
        frameLayer.contentsScale = scale
        
        return frameLayer
    }
    
    @discardableResult
    private func draw(
        element: any ArtboardElement,
        scale: CGFloat,
        in parent: CALayer?
    ) -> ControlLayer {
        let layer = layer(for: element, in: parent)
        
        if let parent {
            layer.frame = view.relativeFrame(
                of: element.frame.scaled(scale),
                in: parent)
        } else {
            layer.frame = element.frame.scaled(scale)
        }
        
        layer.backgroundColor = element.color.cgColor
        
        return layer
    }
    
    private func frameLayer(
        for frame: Frame,
        imageLoader: ImageLoading
    ) -> FrameLayer {
        if let cachedLayer = cachedFrameLayer(for: frame)  {
            return cachedLayer
        }
        
        // Create new
        let layer = FrameLayer(model: frame)
        layer.image = imageLoader.image(for: frame)?.defaultCGImage
        view.add(frame: layer)
        
        return layer
    }
    
    private func layer(
        for model: any ArtboardElement,
        in parent: CALayer?
    ) -> ControlLayer {
        if let cachedLayer = cachedLayer(for: model) {
            return cachedLayer
        } else {
            let layer = ControlLayer(model: model)
            view.add(control: layer, to: parent)
            return layer
        }
    }
    
    func cachedLayer(for model: any ArtboardElement) -> ControlLayer? {
        view.drawnControls.first(where: { layer in
            layer.model === model
        })
    }
    
    func cachedFrameLayer(for frame: Frame) -> FrameLayer? {
        view.frames.first(where:  { layer in
            layer.model === frame
        })
    }
    
    @discardableResult
    public func draw(
        container: any ArtboardElement,
        in parent: CALayer?,
        scale: CGFloat
    ) -> ControlLayer {
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
        let action = action(for: location, selectedControl: selectedControl)
        switch action {
        case .dragging(let control):
            startDragging(control: control, startLocation: location)
        case .drawing:
            startDrawing(coordinate: location)
        case .resizing(let control, let corner):
            startResizing(control: control, startLocation: location, corner: corner)
        }
    }
    
    public func mouseMoved(
        on location: CGPoint,
        selectedControl: ArtboardElementLayer?
    ) {
        switch action(for: location, selectedControl: selectedControl) {
        case .dragging:
            pointerSubject.send(view.copyListener.isModifierActive ? .copy : .hover)
        case .drawing:
            pointerSubject.send(nil)
        case .resizing(_ /*control*/, let corner):
            pointerSubject.send(.resize(corner))
        }
    }
    
    private enum MouseAction {
        case resizing(_ control: ArtboardElementLayer, corner: RectCorner)
        case dragging(_ control: ArtboardElementLayer)
        case drawing
    }
    
    private func action(
        for location: CGPoint,
        selectedControl: ArtboardElementLayer?
    ) -> MouseAction {
        if let selectedControl {
            if let corner = view.hud.corner(for: location) {
                return .resizing(selectedControl, corner: corner)
            } else if let frame = selectedControl as? FrameLayer,
                      frame.frame.contains(location)
            {
                return .dragging(frame)
            }
        }
        
        if let existedControl = view.control(at: location) {
            return .dragging(existedControl)
        } else {
            return .drawing
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
        let parentFrame = view.frames.first { frame in
            frame.frame.contains(coordinate)
        }
       
        let element = A11yDescription.empty(frame: .zero)
        element.parent = parentFrame?.model as? BaseContainer // Set parent here. Probably, is should be done when an action is finished
        
        let control = draw(
            element: element,
            scale: 1,
            in: parentFrame)
        
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
        in view: DrawingView,
        offset: CGPoint = .zero
    ) {
        var newFrame = relativeFrame
        if let _ = model?.parent {
            newFrame = view.relativeFrame(of: relativeFrame, in: superlayer)
        }
        
        frame = newFrame
        
        recalculateAbsoluteFrameInModel(to: relativeFrame,
                                        in: view,
                                        offset: offset)
    }
    
    public func recalculateAbsoluteFrameInModel(
        to relativeFrame: CGRect,
        in view: DrawingView,
        offset: CGPoint = .zero
    ) {
        let absoluteFrame = view.absoluteFrame(
            of: relativeFrame,
            for: self)
        
        model?.frame = absoluteFrame
    }
}

public class FrameLayer: ArtboardElementLayer {
    
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
