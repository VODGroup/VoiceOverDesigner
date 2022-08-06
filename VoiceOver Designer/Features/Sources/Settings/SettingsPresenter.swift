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
    func delete(model: A11yDescription)
}

public class SettingsPresenter {
    public init(
        model: A11yDescription,
        delegate: SettingsDelegate
    ) {
        self.model = model
        self.delegate = delegate
    }
    
    public var model: A11yDescription
    public weak var delegate: SettingsDelegate?
    
    func updateLabel(to newValue: String) {
        model.label = newValue
    }
}
