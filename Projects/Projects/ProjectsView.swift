//
//  ProjectsView.swift
//  Projects
//
//  Created by Mikhail Rubanov on 05.05.2022.
//

import AppKit
import CommonUI

class ProjectsView: DragNDropImageView {
    
    @IBOutlet weak var dragHereView: NSImageView!
    @IBOutlet weak var dragHereLabel: NSTextField!
    
    override var isWaitingForFile: Bool {
        didSet {
            dragHereView.isHidden = !isWaitingForFile
            dragHereLabel.isHidden = isWaitingForFile
        }
    }
}
