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
    
    #warning("TODO: probably migrate from Storyboard ???")
    // TODO: probably migrate from Storyboard ???
    lazy var windowController: WindowContoller = {
        let windowController = WindowContoller.fromStoryboard()
        windowController.window?.setFrameAutosaveName("Projects")
        windowController.showWindow(self)
        return windowController
    }()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {

            windowController = WindowContoller.fromStoryboard()
            windowController.window?.setFrameAutosaveName("Projects")
            windowController.showWindow(self)
            
        }
        return flag
    }
    
    func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        let url = URL(fileURLWithPath: filename)
        let document = VODesignDocument(file: url)
        
        let window = WindowContoller.fromStoryboard()
        window.show(document: document)
        
        window.showWindow(self)
        
        return true
    }
}
