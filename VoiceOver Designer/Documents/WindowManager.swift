import Recent
import AppKit
import Document
import SwiftUI

class WindowManager: NSObject {
    
    static var shared = WindowManager()
    
    let documentsPresenter = SamplesDocumentsPresenter.shared
    
    func makeRecentWindow() -> NSWindow {
        let controller = DocumentsTabViewController(router: rootWindowController, selectedTab: .recent)
        let window = NSWindow(contentViewController: controller)
        
        window.toolbar = controller.toolbar()
        
        prepare(window)
        
        window.minSize = CGSize(width: 800, height: 700) // Two rows, 5 columns
        window.isRestorable = false
        window.titlebarAppearsTransparent = false
        
        rootWindowController.window = window

        return window
    }
    
    lazy var rootWindowController: RecentWindowController = {
        let windowController = RecentWindowController()
        windowController.delegate = self
        windowController.presenter = documentsPresenter
        
        return windowController
    }()
    
    private var projectController: ProjectController?

    func prepare(_ window: NSWindow) {
        window.tabbingMode = .preferred
        window.tabbingIdentifier = "TabbingId"
        window.setFrameAutosaveName("Projects")
        window.styleMask = [.closable, .miniaturizable, .resizable, .titled, .fullSizeContentView]
    }
}

extension WindowManager: RecentDelegate {
    
    func createNewDocumentWindow(
        document: VODesignDocument
    ) {
        print("will open \(document.fileURL?.absoluteString ?? "Unknown fileURL")")
        
        // TODO: Check that this document is not opened in another tab
        
        let state = ProjectStateController(document: document, router: self)
        let newWindow: NSWindow = WindowWithCancel(contentViewController: state)
        newWindow.title = document.displayName
        newWindow.toolbar = state.toolbar()
        
        prepare(newWindow)
        
        let windowController = NSWindowController(window: newWindow)
        document.addWindowController(windowController)

        addTabOrCreateWindow(with: newWindow)
    }
    
    func addTabOrCreateWindow(with window: NSWindow) {
        let application = NSApplication.shared
        if let keyWindow = application.keyWindow {
            keyWindow.tabGroup?.addWindow(window)
            keyWindow.tabGroup?.selectedWindow = window
        } else {
            window.makeKeyAndOrderFront(self)
        }
    }
}

extension WindowManager: ProjectRouterDelegate {
    func showSamples(_ sender: NSToolbarItem) {
        showDocument(sender, type: .samples)
    }
    
    func showRecent(_ sender: NSToolbarItem) {
        showDocument(sender, type: .recent)
    }
    
    private func showDocument(_ sender: NSToolbarItem, type: DocumentsTabViewController.SelectedTab) {
        let controller = DocumentsTabViewController(router: rootWindowController, selectedTab: type)
        controller.preferredContentSize = CGSize(width: 1000, height: 800)
        
        let window = NSApplication.shared.keyWindow!
        let contentController = window.contentViewController!
        
        if #available(macOS 14.0, *) {
            let popover = NSPopover()
            popover.contentViewController = controller
            popover.behavior = .transient
            popover.show(relativeTo: sender)
        } else {
            contentController.present(
                controller,
                asPopoverRelativeTo: contentController.view.bounds,
                of: contentController.view.superview!,
                preferredEdge: .minX,
                behavior: .transient)
        }
    }
}

import Samples
private final class WindowWithCancel: NSWindow {

    // Should be cancelOperation, but macos has a bug. cancelOperation(sender:) doesn't work, this does.
    // https://stackoverflow.com/a/42440020
    @objc func cancel(_ sender: Any?) {
        contentViewController?.cancelOperation(sender)
    }
    
    /// Handle toolbar action by window
    @objc private func selectLanguage(sender: NSMenuItem) {
        let languageSource: LanguageSource = SamplesDocumentsPresenter.shared
        
        let languageCode = languageSource.possibleLanguages[sender.tag]
        
        languageSource.samplesLanguage = languageCode
    }
}
