//
//  File.swift
//  
//
//  Created by Andrey Plotnikov on 05.08.2022.
//

import Combine
import Foundation

public class ManualCopyCommand: CopyModifierAction {
    public init() {}
    
    public var isModifierActive: Bool = false
    
    public var modifierPublisher: AnyPublisher<Bool, Never> {
        Just(isModifierActive).eraseToAnyPublisher()
    }
}
