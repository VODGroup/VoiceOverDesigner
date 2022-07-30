//
//  WindowContoller.swift
//  VoiceOver Designer
//
//  Created by Mikhail Rubanov on 05.05.2022.
//

import AppKit
import Projects
import Document
import Editor

class WindowContoller: NSWindowController {
    
    static func fromStoryboard() -> WindowContoller {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let window = storyboard.instantiateInitialController() as! WindowContoller
        return window
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        let projects = ProjectsViewController.fromStoryboard()
        projects.documentController = VODocumentController.shared
        window?.toolbar = projects.toolbar
        contentViewController = projects
        projects.router = self
    }
}

extension WindowContoller: ProjectsRouter {
    
    func show(document: VODesignDocument) {
        window?.close()
        
        document.addWindowController(self)
        
        let editor = EditorViewController.fromStoryboard()
        
        let split = ProjectController()
        editor.inject(router: split.router, document: document)
        split.editor = editor
        
        window?.contentViewController = split
        window?.toolbar = editor.toolbar
    }
}
