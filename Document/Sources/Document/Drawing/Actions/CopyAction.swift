//
//  File.swift
//  
//
//  Created by Andrey Plotnikov on 02.08.2022.
//

import QuartzCore

public class CopyAction: DraggingAction {
    
    init(view: DrawingView, copiedControl: A11yControl, startLocation: CGPoint, offset: CGPoint, initialFrame: CGRect) {
        self.view = view

        self.copiedControl = copiedControl
        self.startLocation = startLocation
        self.offset = offset
        self.initialFrame = initialFrame
        
    }
    
    private let view: DrawingView
    public let copiedControl: A11yControl
    private let startLocation: CGPoint
    private var offset: CGPoint
    private let initialFrame: CGRect
    
    public func drag(to coordinate: CGPoint) {
        let offset = coordinate - startLocation
        let frame = initialFrame.offsetBy(dx: offset.x, dy: offset.y)
        copiedControl.updateWithoutAnimation {
            copiedControl.frame = frame
        }
        self.offset = offset
    }
    
    public func end(at coordinate: CGPoint) -> DraggingAction? {
        return self
    }
}
