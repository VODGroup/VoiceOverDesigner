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
        action.end(at: coordinate)
    }
    
    init(view: DrawingView, sourceControl: A11yControlLayer, startLocation: CGPoint, offset: CGPoint, initialFrame: CGRect) {
        self.view = view

        self.sourceControl = sourceControl
        self.startLocation = startLocation
        self.offset = offset
        self.initialFrame = initialFrame
    }
    
    private let view: DrawingView
    public let sourceControl: A11yControlLayer
    private let startLocation: CGPoint
    private var offset: CGPoint
    private let initialFrame: CGRect
    
    private lazy var copyAction: CopyAction = {
        let modelToCopy = sourceControl.model!
        
        let modelCopy = modelToCopy.copy()
        let newControl = A11yControlLayer.copy(from: modelCopy)
        view.add(control: newControl)
        
        let action = CopyAction(view: view,
                                control: newControl,
                                startLocation: startLocation,
                                offset: offset,
                                initialFrame: initialFrame)
        return action
    }()
    
    private lazy var translateAction: TranslateAction = TranslateAction(view: view, control: sourceControl, startLocation: startLocation, offset: offset, initialFrame: initialFrame)
    
    var action: DraggingAction {
        if view.copyListener.isCopyHold {
            return copyAction
        } else {
            return translateAction
        }
    }
    
    public var control: A11yControlLayer {
        return action.control
    }
}
