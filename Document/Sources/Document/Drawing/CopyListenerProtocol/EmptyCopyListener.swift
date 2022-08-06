//
//  File.swift
//  
//
//  Created by Andrey Plotnikov on 05.08.2022.
//

import Foundation

public class EmptyCopyListener: CopyModifierProtocol {
    public var isCopyHold: Bool {
        false
    }
}
