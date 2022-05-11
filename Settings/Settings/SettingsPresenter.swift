//
//  SettingsPresenter.swift
//  Settings
//
//  Created by Mikhail Rubanov on 11.05.2022.
//

import Foundation
import Document

public protocol SettingsDelegate: AnyObject {
    func didUpdateValue()
    func delete(control: A11yControl)
}

public class SettingsPresenter {
    public init(
        control: A11yControl,
        delegate: SettingsDelegate
    ) {
        self.control = control
        self.delegate = delegate
    }
    
    public var control: A11yControl
    public weak var delegate: SettingsDelegate?
    
    func updateLabel(to newValue: String) {
        control.a11yDescription?.label = newValue
        control.updateColor()
    }
}
