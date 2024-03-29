import Recent
import AppKit
import Document
import SwiftUI

class WindowManager: NSObject {
    
    static var shared = WindowManager()
    
    let documentsPresenter = DocumentPresenterFactory().presenter()
    
    func makeRecentWindow() -> NSWindow {
        let controller = DocumentsTabViewController(router: rootWindowController)
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
    
    private var newDocumentIsCreated = false
    private var projectController: ProjectController?

    func start() {
        // This method is called from applicationDidFinishLaunching
        // This place is too early to restore any previous opened windows
        // As a result we had to slightly wait to check what is restored
        // In there in no other windows – show recent or new
        // Even NSApplicationDidFinishRestoringWindowsNotification won't work, isn't called if there is no windows to restore
        //
        // It can be fixed by finding correct place 
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(10)) {
            self.showRecentIfNeeded()
        }
    }
    
    private func showRecentIfNeeded() {
        if newDocumentIsCreated {
            // Document has been created from [NSDocumentController openUntitledDocumentAndDisplay:error:]
            return
        }
        if documentsPresenter.shouldShowThisController {
            showRecent()
        } else {
            // TODO: Do we need it or document will open automatically?
            showNewDocument()
        }
    }
    
    private func showNewDocument() {
        createNewDocumentWindow(document: VODesignDocument())
    }
    
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
        newDocumentIsCreated = true
        
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

    func showRecent() {
        if let recentWindowTab = NSApplication.shared.keyWindow?.tabGroup?.windows.first(where: { window in
            window.contentViewController is DocumentsTabViewController
        }) {
            // Already in tabs
            recentWindowTab.makeKeyAndOrderFront(self)
        } else {
            // Add tab
            addTabOrCreateWindow(with: makeRecentWindow())
        }
    }
}

private final class WindowWithCancel: NSWindow {

    // Should be cancelOperation, but macos has a bug. cancelOperation(sender:) doesn't work, this does.
    // https://stackoverflow.com/a/42440020
    @objc func cancel(_ sender: Any?) {
        contentViewController?.cancelOperation(sender)
    }
}
