//
//  DrawingService.swift
//  VoiceOver Designer
//
//  Created by Mikhail Rubanov on 30.04.2022.
//

#if canImport(UIKit)
import UIKit
public typealias View = UIView
extension View {
    func addSublayer(_ layer: CALayer) {
        self.layer.addSublayer(layer)
    }
}
#else
import AppKit
public typealias View = NSView

extension View {
    func addSublayer(_ layer: CALayer) {
        self.layer!.addSublayer(layer)
    }
}
#endif

public class DrawingService {
    public init(view: View) {
        self.view = view
    }
    
    private let view: View
    
    var origin: CGPoint?
    var control: A11yControl?
    
    // MARK: Drawn from existed controls
    
    public func drawControl(from description: A11yDescription) {
        let control = A11yControl()
        control.a11yDescription = description
        control.frame = description.frame
        control.backgroundColor = description.color.cgColor
        
        view.addSublayer(control)
        drawnControls.append(control)
    }
    
    // MARK: New drawing
    public func start(coordinate: CGPoint) {
        self.origin = coordinate
        
        control = A11yControl()
        control!.backgroundColor = A11yDescription.notValidColor.cgColor
        control!.a11yDescription = .empty(frame: .zero)
        
        drawnControls.append(control!)
        
        view.addSublayer(control!)
    }
    
    public func drag(to coordinate: CGPoint) {
        guard let origin = origin else { return }
        
        control?.updateWithoutAnimation {
            control?.frame = CGRect(x: origin.x,
                                    y: origin.y,
                                    width: coordinate.x - origin.x,
                                    height: coordinate.y - origin.y)
        }
    }
    
    public func end(coordinate: CGPoint) {
        drag(to: coordinate)
        
        self.control = nil
    }
    
    // MARK: Existed
    public func control(at coordinate: CGPoint) -> A11yControl? {
        drawnControls.first { control in
            control.frame.contains(coordinate)
        }
    }
    
    public func delete(control: A11yControl) {
        control.removeFromSuperlayer()
        
        if let index = drawnControls.firstIndex(of: control) {
            drawnControls.remove(at: index)
        }
    }
    
    public private(set) var drawnControls: [A11yControl] = []
}

extension CALayer {
    public func updateWithoutAnimation(_ block: () -> Void) {
        CATransaction.begin()
        CATransaction.setAnimationDuration(0)
        block()
        CATransaction.commit()
    }
}
