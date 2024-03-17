import CoreGraphics
import Document

public class CopyAndTranslateAction: DraggingAction {
    public func cancel() {
        if case let copy as CopyAction = action {
            view.delete(control: copy.control)
        }
        
        action.cancel()
    }
    
    public func drag(to coordinate: CGPoint) {
        action.drag(to: coordinate)
    }
    
    public func end(at coordinate: CGPoint) -> DraggingAction? {
        let frame = control.frame.rounded()
        control.update(to: frame, in: view)
        
        return action.end(at: coordinate)
    }
    
    init(view: DrawingView, sourceControl: ArtboardElementLayer, startLocation: CGPoint, offset: CGPoint, initialFrame: CGRect) {
        self.view = view

        self.sourceControl = sourceControl
        self.startLocation = startLocation
        self.offset = offset
        self.initialFrame = initialFrame
    }
    
    private let view: DrawingView
    public let sourceControl: ArtboardElementLayer
    private let startLocation: CGPoint
    private var offset: CGPoint
    private let initialFrame: CGRect
    
    private lazy var copyAction: CopyAction = {
        let modelToCopy = sourceControl.model!
        
        let modelCopy = modelToCopy.copyWithoutLabel()
        let newControl = ControlLayer.copy(from: modelCopy)
        view.add(control: newControl, to: nil)
        
        let action = CopyAction(view: view,
                                control: newControl,
                                startLocation: startLocation,
                                offset: offset,
                                initialFrame: initialFrame)
        return action
    }()
    
    private lazy var translateAction: TranslateAction = TranslateAction(view: view, control: sourceControl, startLocation: startLocation, offset: offset, initialFrame: initialFrame)
    
    var action: DraggingAction {
        if view.copyListener.isModifierActive {
            return copyAction
        } else {
            return translateAction
        }
    }
    
    public var control: ArtboardElementLayer {
        return action.control
    }
}
