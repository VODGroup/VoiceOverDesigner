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

class VODocumentController: NSDocumentController {
    override func documentClass(forType typeName: String) -> AnyClass? {
        return VODesignDocument.self
    }
}

extension VODesignDocument {
    public override func makeWindowControllers() {
        let controller = EditorViewController.fromStoryboard()
        controller.presenter.document = self
    
        let window = NSWindow(contentViewController: controller)
        window.setContentSize(NSSize(width: 800, height: 600))
        
        let wc = NSWindowController(window: window)
        wc.contentViewController = controller
        wc.window?.toolbar = controller.toolbar
        addWindowController(wc)
        
        window.setFrameAutosaveName("windowFrame")
        window.makeKeyAndOrderFront(self)
    }
}
