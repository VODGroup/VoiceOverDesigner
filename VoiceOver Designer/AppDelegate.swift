//
//  AppDelegate.swift
//  VoiceOver Designer
//
//  Created by Mikhail Rubanov on 30.04.2022.
//

import Cocoa
import Document

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    lazy var windowController: WindowController = createWindowController()

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
    
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        let url = URL(fileURLWithPath: filename)
        let document = VODesignDocument(file: url)
        
        windowController.show(document: document)
        
        return true
    }
    
    private func createWindowController() -> WindowController {
        let windowController = WindowController.fromStoryboard()
        windowController.window?.setFrameAutosaveName("Projects")
        return windowController
    }
}
