import Recent
import AppKit
import Document

class WindowManager: NSObject {
    
    static var shared = WindowManager()
    
    let recentPresenter = RecentPresenter()
    lazy var projectsWindowController: RecentWindowController = {
        RecentWindowController.fromStoryboard(delegate: self, presenter: recentPresenter)
    }()
    
    func start() {
        if recentPresenter.shouldShowThisController {
            showDocumentSelector()
        } else {
            // TODO: Do we need it or document will open automatically?
            showNewDocument()
        }
    }
    
    private func showNewDocument() {
        createNewDocumentWindow(document: VODesignDocument())
    }
     
    private func showDocumentSelector() {
        projectsWindowController.embedProjectsViewControllerInWindow()
        projectsWindowController.window?.makeKeyAndOrderFront(self)
    }
    
    private func hideDocumentSelector() {
        projectsWindowController.window?.close()
    }
}

extension WindowManager: RecentDelegate {
    func createNewDocumentWindow(
        document: VODesignDocument
    ) {
        let split = ProjectController(document: document, router: self)
        
        let window = projectsWindowController.window!
        window.title = document.displayName
        window.toolbar = split.toolbar
        window.styleMask.formUnion(.fullSizeContentView)
        
        window.contentViewController = split
        
        document.addWindowController(projectsWindowController)
    }
}

extension WindowManager: ProjectRouterDelegate {
    func closeProject() {
        let window = projectsWindowController.window!
        window.title = NSLocalizedString("VoiceOver Designer", comment: "")

        window.toolbar = NSToolbar() // Resent toolbar
        
        projectsWindowController.embedProjectsViewControllerInWindow()
    }
}
