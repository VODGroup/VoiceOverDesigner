//
//  File.swift
//  
//
//  Created by Andrey Plotnikov on 28.10.2023.
//

import Foundation
import SwiftUI

private struct TextRecognitionsResults: EnvironmentKey {
    static var defaultValue: [String] = []
}

public extension EnvironmentValues {
    var textRecognitionResults: [String] {
        get { self[TextRecognitionsResults.self] }
        set { self[TextRecognitionsResults.self] = newValue }
    }
}

public extension View {
    @warn_unqualified_access
    func textRecognitionResults(_ value: [String]) -> some View {
        environment(\.textRecognitionResults, value)
    }
}
