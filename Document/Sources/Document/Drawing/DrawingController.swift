import CoreGraphics
import QuartzCore

public class DrawingController {
    public init(view: DrawingView) {
        self.view = view
        
#if os(macOS)
        view.wantsLayer = true
#endif
    }
    
    public let view: DrawingView
    private var action: Action?
    
#if canImport(UIKit)
    private lazy var alingmentOverlay = NoAlignmentOverlay()
#else
    private lazy var alingmentOverlay = AlingmentCommandModifier(
        alingmentOverlay: AlingmentOverlay(view: view),
        noAlingmentOverlay: NoAlignmentOverlay())
#endif
    
    // MARK: Drawn from existed controls
    
    @discardableResult
    public func drawControl(from description: A11yDescription) -> A11yControl {
        let control = A11yControl()
        control.a11yDescription = description
        control.frame = description.frame
        control.backgroundColor = description.color.cgColor
        
        view.add(control: control)
        return control
    }
    
    public enum Action {
        case new(control: A11yControl, origin: CGPoint)
        case translate(control: A11yControl, startLocation: CGPoint, offset: CGPoint, initialFrame: CGRect)
        case click(control: A11yControl)
    }
    
    // MARK: New drawing
    public func startTranslating(control: A11yControl, startLocation: CGPoint) {
        self.action = .translate(control: control, startLocation: startLocation,
                                 offset: .zero, initialFrame: control.frame)
    }
    
    public func startDrawing(coordinate: CGPoint) {
        let control = drawControl(from: .empty(frame: .zero))
        
        let point = alingmentOverlay.alignToAny(control, point: coordinate, drawnControls: view.drawnControls)
        self.action = .new(control: control, origin: point)
    }
    
    public func drag(to coordinate: CGPoint) {
        switch action {
        case .new(let control, let origin):
            let alignedCoordinate = alingmentOverlay.alignToAny(control, point: coordinate, drawnControls: view.drawnControls)
            control.updateWithoutAnimation {
                control.frame = CGRect(x: origin.x,
                                       y: origin.y,
                                       width: alignedCoordinate.x - origin.x,
                                       height: alignedCoordinate.y - origin.y)
            }
        case .translate(let control, let startLocation, _, let initialFrame):
            let offset = coordinate - startLocation
            
            let frame = initialFrame
                .offsetBy(dx: offset.x,
                          dy: offset.y)
            
            let aligned = alingmentOverlay.alignToAny(control, frame: frame, drawnControls: view.drawnControls)
            
            control.updateWithoutAnimation {
                control.frame = aligned
            }
            
            action = .translate(control: control,
                                startLocation: startLocation,
                                offset: offset,
                                initialFrame: initialFrame)
            
        case .click:
            break
        case .none:
            break
        }
    }
    
    public func end(coordinate: CGPoint) -> Action? {
        defer {
            self.action = nil
            alingmentOverlay.hideAligningLine()
        }
        
        drag(to: coordinate)
        
        switch action {
        case .new(let control, _):
            if control.frame.size.width < 5 || control.frame.size.height < 5 {
                view.delete(control: control)
                return .none
            }
            
            let minimalTapSize: CGFloat = 44
            control.frame = control.frame.increase(to: CGSize(width: minimalTapSize, height: minimalTapSize))
            
        case .translate(let control, _, let offset, _):
            if offset.isSmallOffset {
                // Reset frame
                control.frame = control.frame.offsetBy(dx: -offset.x,
                                                       dy: -offset.y)
                return .click(control: control)
            }
        case .click(_):
            break // impossible state at this moment
            
        case .none:
            break
        }
        
        return action
    }
}
