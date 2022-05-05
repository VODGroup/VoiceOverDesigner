//
//  Router.swift
//  VoiceOver Designer
//
//  Created by Mikhail Rubanov on 05.05.2022.
//

import AppKit
import Document
import Settings

class Router {
    init(rootController: NSViewController) {
        self.rootController = rootController
    }
    
    let rootController: NSViewController
    
    func showSettings(for control: A11yControl, delegate: SettingsDelegate) {
        let settings = SettingsViewController.fromStoryboard()
        settings.control = control
        settings.delegate = delegate
        
        rootController.present(settings,
                               asPopoverRelativeTo: control.frame,
                               of: rootController.view,
                               preferredEdge: .maxX,
                               behavior: .semitransient)
    }
}
