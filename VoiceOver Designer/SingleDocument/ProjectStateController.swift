//
//  ProjectStateController.swift
//  VoiceOver Designer
//
//  Created by Mikhail Rubanov on 18.10.2023.
//

import AppKit
import Presentation
import SwiftUI
import Settings // TODO: Move StateViewController out of settings
import Document
import CommonUI

enum ProjectWindowState: StateProtocol {
    case editor
    case presentation
    
    static var `default`: ProjectWindowState = .editor
}

final class ProjectStateController: StateViewController<ProjectWindowState> {

    let document: VODesignDocument
    private(set) weak var router: ProjectRouterDelegate?
    
    lazy var editor: ProjectController = {
        ProjectController(document: document, router: router!)
    }()
    
    init(document: VODesignDocument,
         router: ProjectRouterDelegate) {
        self.document = document
        self.router = router

        super.init(nibName: nil, bundle: nil)
        
        self.stateFactory = { [weak self] state in
            guard let self = self else { fatalError() }
            
            ProjectWindowState.default = state // New document will keep state in sync with opened documents
            view.window?.toolbar = self.toolbar(for: state)
            
            switch state {
            case .editor:
                addCanvasMenu()
                return editor // Use cached value to speed up
                
            case .presentation:
                removeCanvasMenu()
                let hostingController = NSHostingController(rootView: PresentationView(
                    model: PresentationModel(document: VODesignDocumentPresentation(document))
                ))
                hostingController.title = NSLocalizedString("Presentation", comment: "")
                hostingController.view.layer?.backgroundColor = .clear
                return hostingController // Should be invalidated on every launch to redraw
            }
        }
    }

    override func cancelOperation(_ sender: Any?) {
        if state == .presentation {
            stopPresentation()
        }
    }

    var keyListener: Any?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addMenuItem()
    }
    
    public var editorToolbar: NSToolbar {
        let toolbar: NSToolbar = NSToolbar()
        toolbar.delegate = self
        return toolbar
    }
    
    private lazy var presentationToolbar: NSToolbar = {
        let toolbar = PresentationToolbar(actionDelegate: router)
        toolbar.editorSideBarItem.target = self
        toolbar.editorSideBarItem.action = #selector(stopPresentation)
        toolbar.editorSideBarItem.menuFormRepresentation = stopMenuItem
        return toolbar
    }()
    
    func toolbar(for state: ProjectWindowState = .default) -> NSToolbar {
        switch state {
        case .editor: editorToolbar
        case .presentation: presentationToolbar
        }
    }
    
    private func addMenuItem() {
        guard let menu = NSApplication.shared.menu else { return }
        guard menu.item(withTitle: NSLocalizedString("Play", comment: "")) == nil else { return }
        
        
        menu.insertItem(makePlayPresentationMenu(), at: 4)
    }
    
    private func addCanvasMenu() {
        guard let menu = NSApplication.shared.menu else { return }
        
        let canvasMenu = editor.canvas.canvasMenu
        guard menu.item(withTitle: canvasMenu.title) == nil else { return }
        
        menu.insertItem(canvasMenu, at: 3)
    }
    
    private func removeCanvasMenu() {
        guard let menu = NSApplication.shared.menu else { return }
        guard let itemIndex = menu.items.firstIndex(of: editor.canvas.canvasMenu) else { return }
        menu.removeItem(at: itemIndex)
    }
    
    let playMenuItem = NSMenuItem(title: NSLocalizedString("Play", comment: ""),
                                  action: #selector(enablePresentation),
                                  keyEquivalent: "p")
    let stopMenuItem = NSMenuItem(title: NSLocalizedString("Stop", comment: ""),
                                  action: #selector(stopPresentation),
                                  keyEquivalent: "\(KeyEquivalent.escape.character)")
    
    private func makePlayPresentationMenu() -> NSMenuItem {
        let slideshowMenu = NSMenuItem(title: "Play", action: nil, keyEquivalent: "")
        let slideshowSubmenu = NSMenu(title: "Play")
        slideshowSubmenu.autoenablesItems = false
        slideshowSubmenu.addItem(playMenuItem)
        slideshowSubmenu.addItem(stopMenuItem)
        slideshowMenu.submenu = slideshowSubmenu
        
        stopMenuItem.isHidden = true
        stopMenuItem.keyEquivalentModifierMask = []
        
        return slideshowMenu
    }
}
