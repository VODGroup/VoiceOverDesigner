//
//  WindowController.swift
//  VoiceOver Designer
//
//  Created by Mikhail Rubanov on 05.05.2022.
//

import AppKit
import Projects
import Document
import Editor

class WindowController: NSWindowController {
    
    static func fromStoryboard() -> WindowController {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let window = storyboard.instantiateInitialController() as! WindowController
        return window
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        window?.delegate = self
        
        shouldCascadeWindows = true
        
        showProjectsController()
    }
    
    func showProjectsController() {
        let projects = ProjectsViewController.fromStoryboard()
        projects.documentController = VODocumentController.shared
        projects.router = self
        
        window?.toolbar = projects.toolbar
        contentViewController = projects
    }
    
    var documentWindows: [NSWindow] = []
}

extension WindowController: ProjectsRouter {
    
    func show(document: VODesignDocument) {
        let split = ProjectController()
        split.inject(document: document)

        let window = NSWindow(contentViewController: split)
        window.delegate = self
        window.makeKeyAndOrderFront(window)
        window.toolbar = split.editor.toolbar
        window.title = document.displayName
        
        documentWindows.append(window)
        
        let windowContorller = WindowController(window: window)
        document.addWindowController(windowContorller)
    }
}

extension WindowController: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        guard let window = notification.object as? NSWindow else { return }
        
        guard let index = documentWindows.firstIndex(of: window) else {
            return // Project windows, for example
        }
        
        documentWindows.remove(at: index) // Remove refernce to realase
        
        guard documentWindows.isEmpty else { return }
        
        presentProjectsInNewWindow()
    }
    
    private func presentProjectsInNewWindow() {
        let projects = ProjectsViewController.fromStoryboard()
        projects.documentController = VODocumentController.shared
        projects.router = self
        
        let window = NSWindow(contentViewController: projects)
        window.delegate = self
        window.title = NSLocalizedString("Projects", comment: "Window title")
        window.makeKeyAndOrderFront(window)
    }
}
