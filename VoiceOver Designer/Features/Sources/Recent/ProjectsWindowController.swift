//
//  ProjectsWindowController.swift
//  VoiceOver Designer
//
//  Created by Mikhail Rubanov on 05.05.2022.
//

import AppKit
import Document

public protocol ProjectsDelegate: AnyObject {
    func createNewDocumentWindow(
        document: VODesignDocument
    )
}

public class ProjectsWindowController: NSWindowController {
    
    public static func fromStoryboard(
        delegate: ProjectsDelegate
    ) -> ProjectsWindowController {
        let storyboard = NSStoryboard(name: "ProjectsWindowController", bundle: Bundle.module)
        let windowController = storyboard.instantiateInitialController() as! ProjectsWindowController
        windowController.delegate = delegate
        return windowController
    }
    
    weak var delegate: ProjectsDelegate?
    
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
    
    private func projectsController() -> ProjectsViewController {
        let projects = ProjectsViewController.fromStoryboard()
        projects.documentController = VODocumentController.shared
        projects.router = self
        return projects
    }
}

extension ProjectsWindowController: ProjectsRouter {
    
    public func show(document: VODesignDocument) {
        delegate?.createNewDocumentWindow(document: document)
    }
}
