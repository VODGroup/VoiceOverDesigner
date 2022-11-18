//
//  File.swift
//  
//
//  Created by Andrey Plotnikov on 20.08.2022.
//

import Foundation

#if canImport(AppKit)
import AppKit
public class EscModifierActionCommand: EscModifierAction {
    public func setDelegate(_ delegate: EscModifierActionDelegate) {
        self.delegate = delegate
    }
    
    public weak var delegate: EscModifierActionDelegate?
    static let escapeKeyCode: UInt16 = 53
    
    public init() {
        keyListener = NSEvent.addLocalMonitorForEvents(matching: [.keyDown], handler: { [weak self] event in
            
            if event.keyCode == Self.escapeKeyCode {
                self?.delegate?.didPressed()
            }
            return event
        })
    }
    
    var keyListener: Any?
    

}
#endif
