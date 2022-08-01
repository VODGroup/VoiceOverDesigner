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

class Router: EditorRouterProtocol {
    init(rootController: ProjectController, settingsDelegate: SettingsDelegate) {
        self.root = rootController
        self.settingsDelegate = settingsDelegate
    }
    
    let root: ProjectController
    unowned var settingsDelegate: SettingsDelegate!
    
    func showSettings(for control: A11yControl, controlSuperview: NSView) {
        let sidebarToggle = true
        if sidebarToggle {
            showSettingsInSidebar(for: control, controlSuperview: controlSuperview)
        } else {
            showSettingsInPopover(for: control, controlSuperview: controlSuperview)
        }
    }
    
    var sidebar: NSSplitViewItem?
    
    private func showSettingsInSidebar(
        for control: A11yControl,
        controlSuperview: NSView
    ) {
        if let sidebar = sidebar {
            root.removeSplitViewItem(sidebar)
        }
        
        let settings = SettingsViewController.fromStoryboard()
        settings.presenter = SettingsPresenter(control: control, delegate: settingsDelegate)
        
        let sidebar = NSSplitViewItem(sidebarWithViewController: settings)
        self.sidebar = sidebar
        root.addSplitViewItem(sidebar)
    }
    
    private func showSettingsInPopover(
        for control: A11yControl,
        controlSuperview: NSView
    ) {
        let settings = SettingsViewController.fromStoryboard()
        settings.presenter = SettingsPresenter(control: control, delegate: settingsDelegate)
        
        let windowCoordinates = controlSuperview.convert(control.frame, to: root.view)
        root.present(settings,
                     asPopoverRelativeTo: windowCoordinates,
                     of: root.view,
                     preferredEdge: .maxX,
                     behavior: .semitransient)
    }
    
    func hideSettings() {
        guard let sidebar = sidebar else { return }
        root.removeSplitViewItem(sidebar)
        self.sidebar = nil
    }
}
