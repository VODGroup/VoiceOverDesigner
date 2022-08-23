import Projects
import AppKit
import Document

class WindowManager: NSObject {
    
    static var shared = WindowManager()
    
    var documentWindows: [NSWindow] = []
    lazy var projectsWindowController: ProjectsWindowController =  .fromStoryboard(delegate: self)
    
    func start() {
        if hasRecentDocuments {
            showDocumentSelector()
        } else if documentWindows.isEmpty {
            showNewDocument()
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

extension WindowManager: ProjectsDelegate {
    func createNewDocumentWindow(
        document: VODesignDocument
    ) {
        let window = presenteWindow(for: document)
        documentWindows.append(window)
        projectsWindowController.window?.close()
    }
    
    func presenteWindow(for document: VODesignDocument) -> NSWindow {
        let split = ProjectController(document: document)
        
        let window = NSWindow(contentViewController: split)
        window.delegate = self
        window.makeKeyAndOrderFront(window)
        window.title = document.displayName
        window.styleMask.formUnion(.fullSizeContentView)
        
        let windowContorller = ProjectsWindowController(window: window)
        document.addWindowController(windowContorller)
        
        let toolbar: NSToolbar = NSToolbar()
        toolbar.delegate = split
        
        windowContorller.window?.toolbar = toolbar
        
        return window
    }
}
