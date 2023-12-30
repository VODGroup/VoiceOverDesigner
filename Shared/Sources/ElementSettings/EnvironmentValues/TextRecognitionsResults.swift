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


public struct UnlockedProductsAction: EnvironmentKey {
    
    public static var defaultValue: UnlockedProductsAction = UnlockedProductsAction(action: { _ in })
    
    private let action: (ProductId) async -> Void
    
    public init(action: @escaping (ProductId) async -> Void) {
        self.action = action
    }
    
    func callAsFunction(productId: ProductId) async {
        await action(productId)
    }
}

public extension EnvironmentValues {
    var unlockAction: UnlockedProductsAction {
        get { self[UnlockedProductsAction.self] }
        set { self[UnlockedProductsAction.self] = newValue }
    }
}

public extension View {
    @warn_unqualified_access
    func unlockedProductAction(_ action: @escaping (ProductId) async -> Void) -> some View {
        environment(\.unlockAction, UnlockedProductsAction(action: action))
    }
}
