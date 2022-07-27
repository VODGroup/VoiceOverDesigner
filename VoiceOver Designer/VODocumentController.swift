//
//  VODocumentController.swift
//  VoiceOver Designer
//
//  Created by Mikhail Rubanov on 06.05.2022.
//

import Foundation

import AppKit
import Document
import Editor
import Projects

class VODocumentController: NSDocumentController {
    override func documentClass(forType typeName: String) -> AnyClass? {
        return VODesignDocument.self
    }
    
    override func removeDocument(_ document: NSDocument) {
        super.removeDocument(document)
        
        if VODocumentController.shared.documents.isEmpty {
            let controller = ProjectsViewController.fromStoryboard()
            let wc = WindowContoller.fromStoryboard()
            wc.window?.setContentSize(.init(width: 800, height: 400))
            wc.window?.toolbar = controller.toolbar
            wc.window?.setFrameAutosaveName("windowFrame")
            wc.showWindow(self)
        }
    }
}

extension VODesignDocument {
    public override func makeWindowControllers() {
        EditorViewController.makeWindow(for: self)
    }
}
