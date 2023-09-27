//
//  KeyboardAction.swift
//  
//
//  Created by Alex Agapov on 28.09.2023.
//

import Foundation

protocol KeyboardAction: AnyObject {}

public final class KeyboardActionsFactory {

    var actions: [KeyboardAction] = []

    public init(presenter: CanvasPresenter) {

#if canImport(AppKit)
        actions = [DuplicateKeyboardAction(presenter: presenter)]
#else
        actions = []
#endif

    }
}
