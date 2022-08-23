//
//  ProjectsWindowController.swift
//  VoiceOver Designer
//
//  Created by Mikhail Rubanov on 05.05.2022.
//

import AppKit
import Projects
import Document
import Editor

protocol ProjectsDelegate: AnyObject {
    func createNewDocumentWindow(
        document: VODesignDocument
    )
}

class ProjectsWindowController: NSWindowController {
    
    static func fromStoryboard() -> ProjectsWindowController {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let window = storyboard.instantiateInitialController() as! ProjectsWindowController
        return window
    }
    
    weak var delegate: ProjectsDelegate?
    
    override func windowDidLoad() {
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
    
    func restoreProjectsWindow() {
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
    
    func show(document: VODesignDocument) {
        delegate?.createNewDocumentWindow(document: document)
    }
}
