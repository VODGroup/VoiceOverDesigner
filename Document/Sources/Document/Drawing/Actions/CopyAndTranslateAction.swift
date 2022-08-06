//
//  File.swift
//  
//
//  Created by Andrey Plotnikov on 06.08.2022.
//

import Foundation

public class CopyAndTranslateAction: DraggingAction {
    public func drag(to coordinate: CGPoint) {
        action?.drag(to: coordinate)
    }
    
    public func end(at coordinate: CGPoint) -> DraggingAction? {
        action?.end(at: coordinate)
    }
    
    init(view: DrawingView, sourceControl: A11yControl, startLocation: CGPoint, offset: CGPoint, initialFrame: CGRect) {
        self.view = view

        self.sourceControl = sourceControl
        self.startLocation = startLocation
        self.offset = offset
        self.initialFrame = initialFrame
        
    }
    
    private let view: DrawingView
    public let sourceControl: A11yControl
    private let startLocation: CGPoint
    private var offset: CGPoint
    private let initialFrame: CGRect
    
    private lazy var copyAction: CopyAction? = {
        guard let descriptionToCopy = sourceControl.a11yDescription else {
            return nil
        }
        
        let newDescription = A11yDescription.copy(from: descriptionToCopy)
        let newControl = A11yControl()
        newControl.a11yDescription = newDescription
        newControl.frame = newDescription.frame
        newControl.backgroundColor = newDescription.color.cgColor
//        sourceControl.updateWithoutAnimation {
//            sourceControl.frame = initialFrame
//        }
        
        view.add(control: newControl)
        let action = CopyAction(view: view, control: newControl, startLocation: startLocation, offset: offset, initialFrame: initialFrame)
        return action

    }()
    
    private lazy var translateAction: TranslateAction = TranslateAction(view: view, control: sourceControl, startLocation: startLocation, offset: offset, initialFrame: initialFrame)
    
    var action: DraggingAction? {
        if view.copyListener.isOptionPressed {
            return copyAction
        } else {
            return translateAction
        }
    }
}
