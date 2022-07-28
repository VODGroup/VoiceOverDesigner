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
    init(rootController: ProjectController) {
        self.root = rootController
    }
    
    let root: ProjectController
    
    func showSettings(for control: A11yControl, controlSuperview: NSView, delegate: SettingsDelegate) {
        let sidebarToggle = true
        if sidebarToggle {
            showSettingsInSidebar(for: control, controlSuperview: controlSuperview, delegate: delegate)
        } else {
            showSettingsInPopover(for: control, controlSuperview: controlSuperview, delegate: delegate)
        }
    }
    
    var sidebar: NSSplitViewItem?
    
    private func showSettingsInSidebar(for control: A11yControl, controlSuperview: NSView, delegate: SettingsDelegate) {
        if let sidebar = sidebar {
            root.removeSplitViewItem(sidebar)
        }
        
        let settings = SettingsViewController.fromStoryboard()
        settings.presenter = SettingsPresenter(control: control, delegate: delegate)
        
        let sidebar = NSSplitViewItem(sidebarWithViewController: settings)
        self.sidebar = sidebar
        root.addSplitViewItem(sidebar)
    }
    
    private func showSettingsInPopover(for control: A11yControl, controlSuperview: NSView, delegate: SettingsDelegate) {
        let settings = SettingsViewController.fromStoryboard()
        settings.presenter = SettingsPresenter(control: control, delegate: delegate)
        
        let windowCoordinates = controlSuperview.convert(control.frame, to: root.view)
        root.present(settings,
                     asPopoverRelativeTo: windowCoordinates,
                     of: root.view,
                     preferredEdge: .maxX,
                     behavior: .semitransient)
    }
}
