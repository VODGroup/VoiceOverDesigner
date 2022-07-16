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
        window?.toolbar = projects.toolbar
        contentViewController = projects
        projects.router = self
    }
}

extension WindowContoller: ProjectsRouter {
    func show(document: VODesignDocument) {
//        self.document = document
        document.addWindowController(self)
        document.updateRecent()
        
        let controller = EditorViewController.fromStoryboard()
        controller.presenter.document = document
        
        // VODesignDocument(fileName: "Test")
        
        window?.contentViewController = controller
        window?.toolbar = controller.toolbar
    }
}
