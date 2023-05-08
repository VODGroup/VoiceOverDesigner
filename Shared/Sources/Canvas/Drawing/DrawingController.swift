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
        for frame in artboard.frames {
            draw(frame: frame, scale: scale)
        }
        
        drawControlsAndContainers(
            controls: artboard.controlsWithoutFrames,
            scale: scale)
        
        view.invalidateIntrinsicContentSize()
    }
    
    func draw(frame: Frame, scale: CGFloat) {
        drawImage(for: frame, scale: scale)
        
        drawControlsAndContainers(controls: frame.elements,
                                  scale: scale)
    }
    
    func drawControlsAndContainers(
        controls: [any ArtboardElement],
        scale: CGFloat
    ) {
        controls
            .extractContainers()
            .forEach { container in
                draw(container: container, scale: scale)
            }
       
        // Extract inner elements from containers
        controls
            .extractElements()
            .forEach { element in
                draw(element: element, scale: scale)
            }
    }
    
    class ImageLoader {
        func image(for frame: Frame) -> Image? {
            let documentPath = URL(fileURLWithPath: "/Users/mikhail/Developer/VoiceOverSamples/Ru/Dodo Pizza/Профиль 2.vodesign/Images")
            let filePath = documentPath
                .appendingPathComponent(frame.imageName, conformingTo: .image)
                .appendingPathExtension("png")
            
            return Image(contentsOf: filePath)
//            frame.image?.defaultCGImage
        }
    }
    private let imageLoader = ImageLoader()
    
    @discardableResult
    public func drawImage(
        for frame: Frame,
        scale: CGFloat
    ) -> CALayer {
        let imageLayer = ImageLayer()
        imageLayer.frame = frame.frame
        imageLayer.image = imageLoader.image(for: frame)?.defaultCGImage
        imageLayer.contentsScale = scale
        view.add(frame: imageLayer)
        return imageLayer
    }
    
    @discardableResult
    public func draw(
        element: any ArtboardElement,
        scale: CGFloat
    ) -> A11yControlLayer {
        let control = A11yControlLayer()
        control.model = element
        control.frame = element.frame.scaled(scale)
        control.backgroundColor = element.color.cgColor
        
        view.add(control: control)
        return control
    }
    
    @discardableResult
    public func draw(
        container: any ArtboardElement,
        scale: CGFloat
    ) -> A11yControlLayer {
        let container = draw(element: container, scale: scale)
//        container.strokeColor = model.color.cgColor
        container.cornerCurve = .continuous
        container.cornerRadius = 20
        container.masksToBounds = true
         
        return container
    }
    
    // MARK: New drawing
    public func mouseDown(
        on location: CGPoint,
        selectedControl: A11yControlLayer?
    ) {
        if let selectedControl {
            if let corner = view.hud.corner(for: location) {
                startResizing(control: selectedControl, startLocation: location, corner: corner)
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
        selectedControl: A11yControlLayer?
    ) {
        if let corner = view.hud.corner(for: location) {
            pointerSubject.send(.resize(corner))
            return
        }
        
        if view.control(at: location) != nil {
            pointerSubject.send(view.copyListener.isModifierActive ? .copy : .hover)
        } else {
            pointerSubject.send(nil)
        }
    }
    
    private func startDragging(
        control: A11yControlLayer,
        startLocation: CGPoint
    ) {
        action = CopyAndTranslateAction(view: view, sourceControl: control, startLocation: startLocation, offset: .zero, initialFrame: control.frame)
    }
    
    private func startResizing(
        control: A11yControlLayer,
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

public class ImageLayer: CALayer {
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
#elseif os(iOS)
        return cgImage
#endif
    }
}


