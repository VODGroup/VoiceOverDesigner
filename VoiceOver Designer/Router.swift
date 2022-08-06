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
    init(rootController: ProjectController, settingsDelegate: SettingsDelegate) {
        self.root = rootController
        self.settingsDelegate = settingsDelegate
    }
    
    let root: ProjectController
    unowned var settingsDelegate: SettingsDelegate!
    
    func showSettings(for model: A11yDescription) {
        showSettingsInSidebar(for: model)
    }
    
    var sidebar: NSSplitViewItem?
    
    private func showSettingsInSidebar(
        for model: A11yDescription
    ) {
        hideSettings()
        
        let settings = SettingsViewController.fromStoryboard()
        settings.presenter = SettingsPresenter(
            model: model,
            delegate: settingsDelegate)
        
        let sidebar = NSSplitViewItem(
            sidebarWithViewController: settings)
        
        self.sidebar = sidebar
        root.addSplitViewItem(sidebar)
    }
    
    func hideSettings() {
        guard let sidebar = sidebar else { return }
        root.removeSplitViewItem(sidebar)
        self.sidebar = nil
    }
}
