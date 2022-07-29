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
            NSApplication.shared.delegate?.applicationShouldHandleReopen?(NSApplication.shared, hasVisibleWindows: false)
        }
    }
}

extension VODesignDocument {
    public override func makeWindowControllers() {
        EditorViewController.makeWindow(for: self)
    }
}
