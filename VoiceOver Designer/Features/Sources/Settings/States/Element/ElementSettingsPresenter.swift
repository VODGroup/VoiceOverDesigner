//
//  SettingsPresenter.swift
//  Settings
//
//  Created by Mikhail Rubanov on 11.05.2022.
//

import Foundation
import Document

public protocol SettingsDelegate: AnyObject {
    func didUpdateElementSettings()
    func delete(model: any ArtboardElement)
}

public protocol SettingsUI: AnyObject {
    func updateTitle()
}

public class ElementSettingsPresenter {
    public init(
        element: A11yDescription,
        delegate: SettingsDelegate
    ) {
        self.element = element
        self.delegate = delegate
    }
    
    public var element: A11yDescription
    private weak var delegate: SettingsDelegate?
    private weak var ui: SettingsUI?
    
    func viewDidLoad(ui: SettingsUI) {
        self.ui = ui
    }
    
    func setIsAccessibleElement(_ value: Bool) {
        element.isAccessibilityElement = value
        delegate?.updateValue()
    }
    
    func delete() {
        delegate?.delete(model: element)
    }
    
    func changeHint(to hint: String) {
        element.hint = hint
        notifyDelegates()
    }
    
    func notifyDelegates() {
        delegate?.updateValue()
        ui?.updateTitle()
    }
}

extension ElementSettingsPresenter: LabelDelegate {
    func updateLabel(to text: String) {
        element.label = text
        notifyDelegates()
    }
}

extension ElementSettingsPresenter: A11yValueDelegate {
    public func didUpdateValue() {
        notifyDelegates()
    }
}

extension ElementSettingsPresenter: TraitsViewControllerDelegate {
    func didChangeTrait(_ trait: A11yTraits, state: Bool) {
        changeTrait(trait, state: state)
        notifyDelegates()
    }
    
    private func changeTrait(_ trait: A11yTraits, state: Bool) {
        if state {
            element.trait.formUnion(trait)
        } else {
            element.trait.subtract(trait)
        }
    }
}
