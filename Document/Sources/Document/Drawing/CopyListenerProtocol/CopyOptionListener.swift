//
//  File.swift
//  
//
//  Created by Andrey Plotnikov on 04.08.2022.
//

import Foundation


public class CopyListenerFactory {
    
    public init() {
        
    }
    public func make() -> CopyListenerProtocol {
        #if os(macOS)
        return CopyOptionListener()
        #else
        return EmptyCopyListener()
        #endif
    }
}

#if canImport(AppKit)
import AppKit
public class CopyOptionListener: CopyListenerProtocol {
    
    public init() {
        keyListener = NSEvent.addLocalMonitorForEvents(matching: [.flagsChanged], handler: { [weak self] event in
            self?.isOptionPressed = event.modifierFlags.contains(.option)
            return event
        })
    }
    
    
    private var keyListener: Any?
    public var isOptionPressed: Bool = false {
        didSet {
            print(isOptionPressed ? "Option Pressed": "Option Released")
        }
    }

}
#endif


