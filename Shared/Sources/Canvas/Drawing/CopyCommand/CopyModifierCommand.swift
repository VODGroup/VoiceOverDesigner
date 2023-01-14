//
//  File.swift
//  
//
//  Created by Andrey Plotnikov on 04.08.2022.
//

import Combine
import Foundation


public class CopyModifierFactory {
    
    public init() {
        
    }
    public func make() -> CopyModifierAction {
        #if os(macOS)
        return CopyModifierCommand()
        #else
        return ManualCopyCommand()
        #endif
    }
}

#if canImport(AppKit)
import AppKit
public class CopyModifierCommand: CopyModifierAction {
    
    public init() {
        monitor = NSEvent.addLocalMonitorForEvents(matching: [.flagsChanged], handler: { [weak self] event in
            self?.subject.send(event.modifierFlags.contains(.option))
            return event
        })
    }
    
    deinit {
        if let monitor {
            NSEvent.removeMonitor(monitor)
        }
    }
    
    
    
    private var monitor: Any?
    
    // TODO: Support changes on fly in CopyAndTranslateAction or DrawingController
    private let subject: CurrentValueSubject<Bool, Never> = .init(false)
    
    public var modifierPublisher: AnyPublisher<Bool, Never> {
        subject.eraseToAnyPublisher()
    }
    
    public var isModifierActive: Bool {
        subject.value
    }

}
#endif


