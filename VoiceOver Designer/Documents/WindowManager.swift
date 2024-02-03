import Recent
import AppKit
import Document
import SwiftUI

class WindowManager: NSObject {
    
    static var shared = WindowManager()

    func prepare(_ window: NSWindow) {
        window.tabbingMode = .preferred
        window.tabbingIdentifier = "TabbingId"
        window.setFrameAutosaveName("Projects")
        window.styleMask = [.closable, .miniaturizable, .resizable, .titled, .fullSizeContentView]
    }
    
    private weak var presentedPopover: NSPopover?
}

extension WindowManager: RecentRouter {
    func show(document: VODesignDocument) {
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
        if let presentedPopover {
            // Hide presented controller and not present the new one
            presentedPopover.close()
            self.presentedPopover = nil // Should be cleared automatically, but release manually for feature possible bugs
            return
        }
        let controller = DocumentsTabViewController(router: self, selectedTab: type)
        controller.preferredContentSize = CGSize(width: 1000, height: 800)
        
        let window = NSApplication.shared.keyWindow!
        let contentController = window.contentViewController!
        
        if #available(macOS 14.0, *) {
            let popover = NSPopover()
            popover.contentViewController = controller
            popover.behavior = .transient
            popover.show(relativeTo: sender)
            
            self.presentedPopover = popover
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
}
