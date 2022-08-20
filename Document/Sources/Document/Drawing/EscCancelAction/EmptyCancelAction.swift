//
//  File.swift
//  
//
//  Created by Andrey Plotnikov on 20.08.2022.
//

import Foundation


public class EmptyCancelAction: EscModifierAction {
    public func setDelegate(_ delegate: EscModifierActionDelegate) {
        self.delegate = delegate
    }
    
    public var delegate: EscModifierActionDelegate?
    
    public init() {}
    
}
