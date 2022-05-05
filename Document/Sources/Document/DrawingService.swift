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
        
        view.wantsLayer = true
    }
    
    private let view: View
    
    private var action: Action?

    // MARK: Drawn from existed controls
    public func removeAll() {
        for contol in drawnControls {
            contol.removeFromSuperlayer()
        }
    }
    
    public func drawControl(from description: A11yDescription) {
        let control = A11yControl()
        control.a11yDescription = description
        control.frame = description.frame
        control.backgroundColor = description.color.cgColor
        
        view.addSublayer(control)
        drawnControls.append(control)
    }
    
    public enum Action {
        case new(control: A11yControl, origin: CGPoint)
        case translate(control: A11yControl, startLocation: CGPoint, offset: CGPoint)
        case click(control: A11yControl)
    }
    
    // MARK: New drawing
    public func startTranslating(control: A11yControl, startLocation: CGPoint) {
        self.action = .translate(control: control, startLocation: startLocation, offset: .zero)
    }
    
    public func startDrawing(coordinate: CGPoint) {
        let control = A11yControl()
        control.backgroundColor = A11yDescription.notValidColor.cgColor
        control.a11yDescription = .empty(frame: .zero)
        
        drawnControls.append(control)
        
        view.addSublayer(control)
        
        self.action = .new(control: control, origin: coordinate)
    }
    
    public func drag(to coordinate: CGPoint) {
        switch action {
        case .new(let control, let origin):
            control.updateWithoutAnimation {
                control.frame = CGRect(x: origin.x,
                                       y: origin.y,
                                       width: coordinate.x - origin.x,
                                       height: coordinate.y - origin.y)
            }
        case .translate(let control, let startLocation, let offsetOld):
            let offset = CGPoint(x: coordinate.x - startLocation.x,
                                 y: coordinate.y - startLocation.y)
            
            control.updateWithoutAnimation {
                control.frame = control.frame
                    .offsetBy(dx: offset.x - offsetOld.x,
                              dy: offset.y - offsetOld.y)
            }
            
            action = .translate(control: control, startLocation: startLocation, offset: offset) // Reset translation
            
        case .click:
            break
        case .none:
            break
        }
    }
    
    public func end(coordinate: CGPoint) -> Action? {
        defer {
            self.action = nil
        }
        
        drag(to: coordinate)
        
        if case let .translate(control, _, offset) = action {
            if offset == .zero {
                // Reset frame
                control.frame = control.frame.offsetBy(dx: -offset.x,
                                                       dy: -offset.y)
               return .click(control: control)
            }
        }
        
        return action
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
