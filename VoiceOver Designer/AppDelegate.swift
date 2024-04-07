//
//  AppDelegate.swift
//  VoiceOver Designer
//
//  Created by Mikhail Rubanov on 30.04.2022.
//

import Cocoa
import Document

class AppDelegate: NSObject, NSApplicationDelegate {
    
    private var windowManager = WindowManager.shared
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let isDefaultLaunch = aNotification.userInfo?[NSApplication.launchIsDefaultUserInfoKey] as? Bool ?? false
        
        print("Is default launch \(isDefaultLaunch)")
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
        // Sometimes the app opens from dock without UI
        // When user creates new document this method has been called before the new window it appeared
        // As a result the apps is closed because there is the window *haven't been opened yet*
        // It looks like apple's bug.
        return false
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
        windowManager.show(document: document)
    }
    
    @IBAction @objc func openSample(_ sender: Any) {
        // TODO: Should be simplified
        
        let languageButton = NSApplication.shared.keyWindow?.toolbar?.items.first(where: { item in
            item.itemIdentifier == NSToolbarItem.Identifier(rawValue: "SamplesButtonLabel")
        })
        
        guard let languageButton else { return }
        
        windowManager.showSamples(languageButton)
    }
}

