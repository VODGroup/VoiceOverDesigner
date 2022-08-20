//
//  File.swift
//  
//
//  Created by Andrey Plotnikov on 20.08.2022.
//

import Foundation

public class EscModifierFactory {
    
    public init() {
        
    }
    public func make() -> EscModifierAction {
        #if os(macOS)
        return EscModifierActionCommand()
        #else
        return EmptyCancelAction()
        #endif
    }
}


public protocol EscModifierActionDelegate: AnyObject {
    func didPressed()
}


public protocol EscModifierAction {
    var delegate: EscModifierActionDelegate? { get }
    func setDelegate(_ delegate: EscModifierActionDelegate)
}


