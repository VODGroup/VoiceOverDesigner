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
