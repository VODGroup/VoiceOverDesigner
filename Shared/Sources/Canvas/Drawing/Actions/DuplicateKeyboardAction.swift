//
//  DuplicateKeyboardAction.swift
//
//
//  Created by Alex Agapov on 27.09.2023.
//

import Foundation

protocol KeyboardAction: AnyObject {}

public final class KeyboardActionsFactory {

    var actions: [KeyboardAction] = []

    public init(
        presenter: CanvasPresenter
    ) {
#if canImport(AppKit)
        actions = [DuplicateKeyboardAction(presenter: presenter)]
#else
        actions = []
#endif
    }
}

#if canImport(AppKit)
import AppKit
public class DuplicateKeyboardAction: KeyboardAction {
    private static let keyCode = 2 // "d"

    weak var presenter: CanvasPresenter?

    public init(presenter: CanvasPresenter) {
        self.presenter = presenter
        keyListener = NSEvent.addLocalMonitorForEvents(matching: [.keyDown], handler: { [weak self] event in
            guard
                event.modifierFlags.contains(.command),
                event.keyCode == DuplicateKeyboardAction.keyCode
            else {
                return event
            }

            if let selectedControl = self?.presenter?.selectedControl?.model {
                let newModel = selectedControl.copy()
                newModel.frame = newModel.frame.offsetBy(dx: 40, dy: 40)
                self?.presenter?.add(newModel)
            }

            return event
        })
    }

    var keyListener: Any?
}
#endif
