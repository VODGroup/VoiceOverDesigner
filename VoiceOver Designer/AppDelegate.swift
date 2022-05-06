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

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        let url = URL(fileURLWithPath: filename)
        let document = VODesignDocument(file: url)
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let window = storyboard.instantiateInitialController() as! WindowContoller
        window.document = document
        window.show(document: document)
        window.showWindow(self)
        
        return true
    }
}
