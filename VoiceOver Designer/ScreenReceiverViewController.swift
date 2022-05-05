//
//  ScreenReceiverViewController.swift
//  VoiceOver Designer
//
//  Created by Mikhail Rubanov on 05.05.2022.
//

import AppKit
import Document

class ScreenReceiverViewController: NSViewController {
    
    @IBAction func selectMenu(_ sender: Any) {
        show(with: NSImage(named: "Sample_menu")!)
    }
    
    @IBAction func selectProductCard(_ sender: Any) {
        show(with: NSImage(named: "Sample_product")!)
    }
    
    func show(with image: NSImage) {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateController(withIdentifier: "editor") as! EditorViewController
        
        controller.presenter.document = VODesignDocument(image: image)
        
        // VODesignDocument(fileName: "Test")
        
        view.window?.contentViewController = controller
    }
}

extension VODesignDocument {
    convenience init(image: NSImage) {
        self.init(fileName: image.name() ?? Date().description)
        self.image = image
    }
}
