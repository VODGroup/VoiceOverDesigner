//
//  DrawingService.swift
//  VoiceOver Designer
//
//  Created by Mikhail Rubanov on 30.04.2022.
//

import AppKit

class DrawingService {
    init(view: NSView) {
        self.view = view
    }
    
    private let view: NSView
    
    var origin: CGPoint?
    var control: A11yControl?
    
    // MARK: Drawn from existed controls
    
    func drawControl(from description: A11yDescription) {
        let control = A11yControl()
        control.a11yDescription = description
        control.frame = description.frame
        control.backgroundColor = description.color.cgColor
        
        view.layer!.addSublayer(control)
        drawnControls.append(control)
    }
    
    // MARK: New drawing
    func start(coordinate: CGPoint) {
        self.origin = coordinate
        
        control = A11yControl()
        control!.backgroundColor = A11yDescription.notValidColor.cgColor
        control!.a11yDescription = .empty(frame: .zero)
        
        drawnControls.append(control!)
        
        view.layer?.addSublayer(control!)
    }
    
    func drag(to coordinate: CGPoint) {
        guard let origin = origin else { return }
        
        control?.updateWithoutAnimation {
            control?.frame = CGRect(x: origin.x,
                                    y: origin.y,
                                    width: coordinate.x - origin.x,
                                    height: coordinate.y - origin.y)
        }
    }
    
    func end(coordinate: CGPoint) {
        drag(to: coordinate)
        
        self.control = nil
    }
    
    // MARK: Existed
    func control(at coordinate: CGPoint) -> A11yControl? {
        drawnControls.first { control in
            control.frame.contains(coordinate)
        }
    }
    
    func delete(control: A11yControl) {
        control.removeFromSuperlayer()
        
        if let index = drawnControls.firstIndex(of: control) {
            drawnControls.remove(at: index)
        }
    }
    
    var drawnControls: [A11yControl] = []
}
