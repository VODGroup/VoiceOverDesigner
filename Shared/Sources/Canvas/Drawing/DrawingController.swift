import CoreGraphics
import QuartzCore
import Document

public class DrawingController {

    
    public init(view: DrawingView) {
        self.view = view
        view.escListener.setDelegate(self)
        
#if os(macOS)
        view.wantsLayer = true

#endif
    }
    
    public let view: DrawingView
    private var action: DraggingAction?

    
    // MARK: Drawn from existed controls
    
    /// Draw all elements and containers on screen
    /// - Parameters:
    ///   - scale: Relative scale to fit controls on screen. Is neede for Preview
    public func drawControls(
        _ models: [any AccessibilityView],
        scale: CGFloat
    ) {
        // Draw containers under elements
        models
            .extractContainers()
            .forEach { model in
                drawContainer(model, scale: scale)
            }
       
        // Extract inner elements from containers
        models
            .extractElements()
            .forEach { model in
                draw(model, scale: scale)
            }
    }
    
    @discardableResult
    public func draw(
        _ model: any AccessibilityView,
        scale: CGFloat
    ) -> A11yControlLayer {
        let control = A11yControlLayer()
        control.model = model
        control.frame = model.frame.scaled(scale)
        control.border.fillColor = model.color.cgColor
        
        view.add(control: control)
        return control
    }
    
    @discardableResult
    public func drawContainer(
        _ model: any AccessibilityView,
        scale: CGFloat
    ) -> A11yControlLayer {
        let container = draw(model, scale: scale)
        container.border.strokeColor = model.color.cgColor
        container.border.cornerCurve = .continuous
        container.border.cornerRadius = 20
        container.border.masksToBounds = true
         
        return container
    }
    
    // MARK: New drawing
    public func mouseDown(on location: CGPoint, selectedControl: A11yControlLayer?) {
        if let selectedControl {
            let threshold = Config().resizeMarkerSize * 3
            
            if let corner = selectedControl.frame.isCorner(at: location, size: threshold) {
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
        let control = draw(A11yDescription.empty(frame: .zero), scale: 1)
        
        self.action = NewControlAction(view: view, control: control, coordinate: coordinate)
    }
    
    public func drag(to coordinate: CGPoint) {
        action?.drag(to: coordinate)
    }
    
    public func end(coordinate: CGPoint) -> DraggingAction? {
        defer {
            self.action = nil
            view.alignmentOverlay.hideAligningLine()
        }
        
        drag(to: coordinate)
        
        return action?.end(at: coordinate)
    }
}

extension DrawingController: EscModifierActionDelegate {
    public func didPressed() {
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
