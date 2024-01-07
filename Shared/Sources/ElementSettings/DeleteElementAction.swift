//
//  File.swift
//  
//
//  Created by Andrey Plotnikov on 28.10.2023.
//

import Foundation
import SwiftUI
import Artboard

public struct DeleteElementAction {
    var closure: (_ element: any ArtboardElement) -> Void
    
    func delete(_ element: any ArtboardElement) {
        closure(element)
    }
}

private extension DeleteElementAction {
    struct Key: EnvironmentKey {
        static var defaultValue: DeleteElementAction = .init(closure: { _ in })
    }
}

public extension EnvironmentValues {
    var deleteDocumentElement: DeleteElementAction {
        get { self[DeleteElementAction.Key.self] }
        set { self[DeleteElementAction.Key.self] = newValue }
    }
}
