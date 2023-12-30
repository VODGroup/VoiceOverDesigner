//
//  File.swift
//  
//
//  Created by Andrey Plotnikov on 28.10.2023.
//

import Foundation
import SwiftUI
import Purchases

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


private struct UnlockedProductsKey: EnvironmentKey {
    static var defaultValue: Set<ProductId> = []
}

public extension EnvironmentValues {
    var unlockedProductIds: Set<ProductId> {
        get { self[UnlockedProductsKey.self] }
        set { self[UnlockedProductsKey.self] = newValue }
    }
}

public extension View {
    @warn_unqualified_access
    func unlockedProductIds(_ value: Set<ProductId>) -> some View {
        environment(\.unlockedProductIds, value)
    }
}

extension UnlockPresenter {
    struct Key: EnvironmentKey {
        static var defaultValue: UnlockPresenter? = nil
    }
}

public extension EnvironmentValues {
    var unlocker: UnlockPresenter? {
        get { self[UnlockPresenter.Key.self] }
        set { self[UnlockPresenter.Key.self] = newValue }
    }
}

public extension View {
    @warn_unqualified_access
    func unlockPresenter(_ value: UnlockPresenter) -> some View {
        environment(\.unlocker, value)
    }
}
