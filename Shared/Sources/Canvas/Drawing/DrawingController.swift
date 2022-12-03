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
    
    public func drawControls(
        _ models: [any AccessibilityView]
    ) {
        // Draw containers under elements
        models
            .extractContainers()
            .forEach { model in
                draw(model, scale: 1)
            }
       
        // Extract inner elements from containers
        models
            .extractElements()
            .forEach { model in
                draw(model, scale: 1)
            }
    }
    
    @discardableResult
    public func draw(
        _ model: any AccessibilityView,
        scale: CGFloat
    ) -> A11yControl {
        let control = A11yControl()
        control.model = model
        control.frame = model.frame.scaled(scale)
        control.backgroundColor = model.color.cgColor
        
        view.add(control: control)
        return control
    }
    
    // MARK: New drawing
    public func mouseDown(on location: CGPoint) {
        if let existedControl = view.control(at: location) {
            if location.nearBottomRightCorner(of: existedControl.frame) {
                startResizing(control: existedControl, startLocation: location)
            } else {
                startDragging(control: existedControl, startLocation: location)
            }
        } else {
            startDrawing(coordinate: location)
        }
    }
    
    private func startDragging(control: A11yControl, startLocation: CGPoint) {
        action = CopyAndTranslateAction(view: view, sourceControl: control, startLocation: startLocation, offset: .zero, initialFrame: control.frame)
    }
    
    private func startResizing(control: A11yControl, startLocation: CGPoint) {
        action = ResizeAction(view: view, control: control, startLocation: startLocation, offset: .zero, initialFrame: control.frame)
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
