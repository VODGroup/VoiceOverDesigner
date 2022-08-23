//
//  ProjectsWindowController.swift
//  VoiceOver Designer
//
//  Created by Mikhail Rubanov on 05.05.2022.
//

import AppKit
import Document

public protocol RecentDelegate: AnyObject {
    func createNewDocumentWindow(
        document: VODesignDocument
    )
}

public class RecentWindowController: NSWindowController {
    
    public static func fromStoryboard(
        delegate: RecentDelegate
    ) -> RecentWindowController {
        let storyboard = NSStoryboard(name: "RecentWindowController", bundle: Bundle.module)
        let windowController = storyboard.instantiateInitialController() as! RecentWindowController
        windowController.delegate = delegate
        return windowController
    }
    
    weak var delegate: RecentDelegate?
    
    public override func windowDidLoad() {
        super.windowDidLoad()
        
        window?.setFrameAutosaveName("Projects")
        
        shouldCascadeWindows = true
        
        embedProjectsViewControllerInWindow()
    }
    
    private func embedProjectsViewControllerInWindow() {
        let projects = projectsController()
        window?.toolbar = projects.toolbar
        contentViewController = projects
    }
    
    public func restoreProjectsWindow() {
        guard !VODocumentController.shared.recentDocumentURLs.isEmpty else { return }
        window?.makeKeyAndOrderFront(window)
    }
    
    private func projectsController() -> RecentViewController {
        let projects = RecentViewController.fromStoryboard()
        projects.documentController = VODocumentController.shared
        projects.router = self
        return projects
    }
}

extension RecentWindowController: RecentRouter {
    
    public func show(document: VODesignDocument) {
        delegate?.createNewDocumentWindow(document: document)
    }
}
