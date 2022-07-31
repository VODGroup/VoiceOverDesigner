//
//  ProjectController.swift
//  VoiceOver Designer
//
//  Created by Mikhail Rubanov on 31.07.2022.
//

import AppKit
import Editor

class ProjectController: NSSplitViewController {
    
    var editor: EditorViewController!
    lazy var router = Router(rootController: self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSplitViewItem(NSSplitViewItem(viewController: editor))
    }
}
