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

class ProjectsWindowController: NSWindowController {
    
    static func fromStoryboard() -> ProjectsWindowController {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let window = storyboard.instantiateInitialController() as! ProjectsWindowController
        return window
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        window?.delegate = self
        
        shouldCascadeWindows = true
        
        embedProjectsViewControllerInWindow()
    }
    
    private func embedProjectsViewControllerInWindow() {
        let projects = projectsController()
        window?.toolbar = projects.toolbar
        contentViewController = projects
    }
    
    private func restoreProjectsWindow() {
        window?.makeKeyAndOrderFront(window)
    }
    
    private func projectsController() -> ProjectsViewController {
        let projects = ProjectsViewController.fromStoryboard()
        projects.documentController = VODocumentController.shared
        projects.router = self
        return projects
    }
    
    var documentWindows: [NSWindow] = []
}

extension ProjectsWindowController: ProjectsRouter {
    
    func show(document: VODesignDocument) {
        createNewDocumentWindow(document: document)
        
        self.window?.close() // Projects window should hides when open a project
    }
    
    private func createNewDocumentWindow(
        document: VODesignDocument
    ) {
        let split = ProjectController(document: document)
        
        let window = NSWindow(contentViewController: split)
        window.delegate = self
        window.makeKeyAndOrderFront(window)
        window.title = document.displayName
        window.styleMask.formUnion(.fullSizeContentView)
        documentWindows.append(window)
        
        let windowContorller = ProjectsWindowController(window: window)
        document.addWindowController(windowContorller)
        
        let toolbar: NSToolbar = NSToolbar()
        toolbar.delegate = split
        
        windowContorller.window?.toolbar = toolbar
    }
}

extension ProjectsWindowController: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        guard let window = notification.object as? NSWindow else { return }
        
        guard let index = documentWindows.firstIndex(of: window) else {
            return // Project windows, for example
        }
        
        documentWindows.remove(at: index) // Remove refernce to realase
        
        guard documentWindows.isEmpty else { return }
        
        restoreProjectsWindow()
    }
}
