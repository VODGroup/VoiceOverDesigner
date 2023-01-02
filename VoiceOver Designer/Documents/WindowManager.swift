import Recent
import AppKit
import Document

class WindowManager: NSObject {
    
    static var shared = WindowManager()
    
    var documentWindows: [NSWindow] = []
    lazy var projectsWindowController: RecentWindowController =  .fromStoryboard(delegate: self)
    
    func start() {
        if documentWindows.isEmpty {
            if hasRecentDocuments {
                showDocumentSelector()
            } else {
                showNewDocument()
            }
        } else {
            // Do nothing, the user open document directly
        }
    }
    
    private var hasRecentDocuments: Bool {
        !VODocumentController.shared.recentDocumentURLs.isEmpty
    }
    
    private func showNewDocument() {
        createNewDocumentWindow(document: VODesignDocument())
    }
     
    private func showDocumentSelector() {
        projectsWindowController.window?.makeKeyAndOrderFront(self)
    }
    
    private func hideDocumentSelector() {
        projectsWindowController.window?.close()
    }
}

extension WindowManager: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        guard let window = notification.object as? NSWindow else { return }
        
        guard let index = documentWindows.firstIndex(of: window) else {
            return // Project windows, for example
        }
        
        documentWindows.remove(at: index) // Remove refernce to realase
        
        guard documentWindows.isEmpty else { return }
        
        projectsWindowController.restoreProjectsWindow()
    }
}

extension WindowManager: RecentDelegate {
    func createNewDocumentWindow(
        document: VODesignDocument
    ) {
        presentWindow(for: document)
        
        hideDocumentSelector()
    }
    
    private func presentWindow(for document: VODesignDocument) {
        let window = window(for: document)
        
        let windowContorller = RecentWindowController(window: window)
        document.addWindowController(windowContorller)
        
        window.makeKeyAndOrderFront(window)
        documentWindows.append(window)
    }
    
    private func window(for document: VODesignDocument) -> NSWindow {
        let split = ProjectController(document: document)
        
        let window = NSWindow(contentViewController: split)
        window.delegate = self
        
        window.title = document.displayName
        window.styleMask.formUnion(.fullSizeContentView)
        
        let toolbar: NSToolbar = NSToolbar()
        toolbar.delegate = split
        window.toolbar = toolbar
        
        return window
    }
}
