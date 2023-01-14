//
//  File.swift
//  
//
//  Created by Andrey Plotnikov on 05.08.2022.
//

import Combine
import Foundation

public protocol CopyModifierAction {
    var modifierPublisher: AnyPublisher<Bool, Never> { get }
    var isModifierActive: Bool { get }
}



