//
//  File.swift
//  
//
//  Created by Andrey Plotnikov on 28.10.2023.
//

import Foundation
import SwiftUI

public struct DeleteElementAction {
    var closure: () -> Void
    
    func callAsFunction() {
        closure()
    }
}

private extension DeleteElementAction {
    struct Key: EnvironmentKey {
        static var defaultValue: DeleteElementAction = .init(closure: {})
    }
}

public extension EnvironmentValues {
    var deleteDocumentElement: DeleteElementAction {
        get { self[DeleteElementAction.Key.self] }
        set { self[DeleteElementAction.Key.self] = newValue }
    }
}
