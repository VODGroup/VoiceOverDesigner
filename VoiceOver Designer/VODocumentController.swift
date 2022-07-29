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
        let window = WindowContoller.fromStoryboard()
        window.show(document: self)
        
        // TODO: Is it needed?
        window.window?.setFrameAutosaveName("windowFrame")
        window.window?.makeKeyAndOrderFront(self)
    }
}
