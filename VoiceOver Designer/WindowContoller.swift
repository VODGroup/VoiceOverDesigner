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
import TextUI

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
        document.addWindowController(self)
        
        let editor = EditorViewController.fromStoryboard()
        
        let split = ProjectController()
        split.document = document
        editor.inject(router: split.router, document: document)
        split.editor = editor
        
        window?.contentViewController = split
        window?.toolbar = editor.toolbar
    }
}

class ProjectController: NSSplitViewController {
    
    var editor: EditorViewController!
    lazy var router = Router(rootController: self)
    var document: VODesignDocument!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let textContent = TextRepresentationController.fromStoryboard(
            document: document,
            actionDelegate: self)
        addSplitViewItem(NSSplitViewItem(sidebarWithViewController: textContent))
        addSplitViewItem(NSSplitViewItem(viewController: editor))
    }
}

extension ProjectController: TextRepresentationControllerDelegate {
    func didSelect(_ model: A11yDescription) {
        editor.select(model)
    }
}
