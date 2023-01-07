//
//  AppDelegate.swift
//  VoiceOver Designer
//
//  Created by Mikhail Rubanov on 30.04.2022.
//

import Cocoa
import Document

class AppDelegate: NSObject, NSApplicationDelegate {
    
    private let documentController = VODocumentController() // Called by the iOS, we had to just keep reference
    private var windowManager = WindowManager.shared
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        windowManager.start()
        NSApplication.shared.mainMenu = MainMenu.menu()
        
#if DEBUG
        openFileForUITestIfNeeded()
        
        func openFileForUITestIfNeeded() {
            // UI-testing simulation for file openning
            guard let path = ProcessInfo.processInfo.environment["DocumentURL"] else { return }
            guard !path.isEmpty else { return }
            
            let url = URL(fileURLWithPath: path)
            openFile(url: url)
        }
#endif
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
    
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        let url = URL(fileURLWithPath: filename)
        
        openFile(url: url)
        return true
    }
    
    private func openFile(url: URL) {
        let document: VODesignDocument
        
        if url.pathExtension == vodesign {
            document = VODesignDocument(file: url)
        } else {
            let image = NSImage(byReferencing: url)
            document = VODesignDocument(image: image)
        }
        
        windowManager.createNewDocumentWindow(document: document)
    }
}

