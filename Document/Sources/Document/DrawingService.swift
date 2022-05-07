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
        
#if os(macOS)
        view.wantsLayer = true
#endif
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
        control.a11yDescription = .empty(frame: .zero)
        control.updateColor()
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
        
        switch action {
        case .new(let control, let origin):
            let minimalTapSize: CGFloat = 44
            control.frame = control.frame.increase(to: CGSize(width: minimalTapSize, height: minimalTapSize))
            
        case .translate(let control, let startLocation, let offset):
            if offset == .zero {
                // Reset frame
                control.frame = control.frame.offsetBy(dx: -offset.x,
                                                       dy: -offset.y)
                return .click(control: control)
            }
        case .click(let control):
            break // impossible state at this moment
            
        case .none:
            break
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

extension CGRect {
    func increase(to minimalSize: CGSize) -> Self {
        var rect = self
        
        if size.width < minimalSize.width {
            rect = rect.insetBy(dx: (size.width - minimalSize.width)/2, dy: 0)
        }
        
        if size.height < minimalSize.height {
            rect = rect.insetBy(dx: 0, dy: (size.height - minimalSize.height)/2)
        }
        
        return rect
    }
}
