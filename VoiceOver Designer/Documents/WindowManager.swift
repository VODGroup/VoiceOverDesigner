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
        print("Start")
        
        if newDocumentIsCreated {
            // Document has been created from [NSDocumentController openUntitledDocumentAndDisplay:error:]
            return
        }
        if documentsPresenter.shouldShowThisController {
            self.showRecent()
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
        print("will open \(document.fileURL?.absoluteString ?? "Unkonwn fileURL")")
        newDocumentIsCreated = true
        
        // TODO: Check that this document is not opened in another tab
        
        let split = ProjectController(document: document, router: self)
        let state = ProjectStateController(editor: split)
        let newWindow: NSWindow = NSWindow(contentViewController: state)
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
    
    func closeProject(document: NSDocument) {
        document.removeWindowController(rootWindowController)
        
        document.save(self)
        document.close()
        
        // TODO: Is it needed?
        showRecent()
    }
}
