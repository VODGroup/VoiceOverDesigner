//
//  File.swift
//  
//
//  Created by Andrey Plotnikov on 04.08.2022.
//

import Foundation


public class CopyModifierFactory {
    
    public init() {
        
    }
    public func make() -> CopyModifierProtocol {
        #if os(macOS)
        return CopyModifierCommand()
        #else
        return EmptyCopyListener()
        #endif
    }
}

#if canImport(AppKit)
import AppKit
public class CopyModifierCommand: CopyModifierProtocol {
    
    public init() {
        keyListener = NSEvent.addLocalMonitorForEvents(matching: [.flagsChanged], handler: { [weak self] event in
            self?.isCopyHold = event.modifierFlags.contains(.option)
            return event
        })
    }
    
    
    private var keyListener: Any?
    public var isCopyHold: Bool = false {
        didSet {
            print(isCopyHold ? "Option Pressed": "Option Released")
        }
    }

}
#endif


