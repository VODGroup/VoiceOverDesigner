//
//  ProjectsWindowController.swift
//  VoiceOver Designer
//
//  Created by Mikhail Rubanov on 05.05.2022.
//

import AppKit
import Document
import Recent

public class RecentWindowController: NSWindowController {
    
    weak var router: RecentRouter?
    var presenter: DocumentBrowserPresenterProtocol!
    
    public override func windowDidLoad() {
        super.windowDidLoad()
        
        window?.setFrameAutosaveName("Projects")
        window?.styleMask.formUnion(.fullSizeContentView)
        window?.minSize = CGSize(width: 800, height: 700) // Two rows, 5 columns
        window?.titlebarAppearsTransparent = false
        
        shouldCascadeWindows = true
    }
}
