//
//  Router.swift
//  VoiceOver Designer
//
//  Created by Mikhail Rubanov on 05.05.2022.
//

import AppKit
import Document
import Settings
import Editor

class Router {
    init(
        rootController: ProjectController,
        settingsDelegate: SettingsDelegate
    ) {
        self.root = rootController
        
        self.settings = SettingsStateViewController.fromStoryboard()
        self.settings.settingsDelegate = settingsDelegate
        
        let sidebar = NSSplitViewItem(sidebarWithViewController: settings)
        root.addSplitViewItem(sidebar)
    }
    
    private let root: ProjectController
    private let settings: SettingsStateViewController
    
    func showSettings(for model: A11yDescription) {
        settings.state = .control(model)
    }
    
    func hideSettings() {
        settings.state = .empty
    }
}
