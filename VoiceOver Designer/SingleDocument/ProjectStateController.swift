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

enum ProjectWindowState: StateProtocol {
    case editor
    case presentation
    
    static var `default`: ProjectWindowState = .editor
}

class ProjectStateController: StateViewController<ProjectWindowState> {
    
    var editor: ProjectController
    
    init(editor: ProjectController!) {
        self.editor = editor
        
        super.init(nibName: nil, bundle: nil)
        
        self.stateFactory = { [weak self] state in
            guard let self = self else { fatalError() }
            
            ProjectWindowState.default = state // New document will keep state in sync with opened documents
            view.window?.toolbar = self.toolbar(for: state)
            
            switch state {
            case .editor:
                return editor
                
            case .presentation:
                let hostingController = NSHostingController(rootView: PresentationView(
                    document: .init(editor.document)
                ))
                hostingController.title = NSLocalizedString("Presentation", comment: "")
                hostingController.view.layer?.backgroundColor = .clear
                return hostingController
            }
        }
        
        // Should be handled by cancelOperation, but the function not calling https://stackoverflow.com/a/7777469/3300148
        keyListener = NSEvent.addLocalMonitorForEvents(matching: [.keyDown], handler: { [weak self] event in
            let escapeKeyCode: UInt16 = 53
            if event.keyCode == escapeKeyCode {
                if self?.state == .presentation {
                    self?.stopPresentation()
                }
            }
            return event
        })
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
        let toolbar = PresentationToolbar()
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
        
        menu.insertItem(editor.canvas.makeCanvasMenu(), at: 3)
        menu.insertItem(makePlayPresentationMenu(), at: 4)
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

class PresentationToolbar: NSToolbar {
    init() {
        super.init(identifier: NSToolbar.Identifier("Presentation"))
        
        delegate = self
    }
    
    lazy var editorSideBarItem: NSToolbarItem = {
        let item = NSToolbarItem(itemIdentifier: .editor)
        item.label = NSLocalizedString("Edit", comment: "")
        item.isBordered = true
        item.image = NSImage(systemSymbolName: "highlighter",
                             accessibilityDescription: "Open editor mode")!
        item.toolTip = NSLocalizedString("Open editor mode", comment: "")
        
        return item
    }()
}

extension PresentationToolbar: NSToolbarDelegate {
    public func toolbar(
        _ toolbar: NSToolbar,
        itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
        willBeInsertedIntoToolbar flag: Bool
    ) -> NSToolbarItem? {
        switch itemIdentifier {
        case .editor: return editorSideBarItem
        default: return nil
        }
    }
    
    public func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [
            .flexibleSpace,
            .editor
        ]
    }
}
