//
//  ProjectsWindowController.swift
//  VoiceOver Designer
//
//  Created by Mikhail Rubanov on 05.05.2022.
//

import AppKit
import Document

public protocol RecentDelegate: AnyObject {
    func createNewDocumentWindow(
        document: VODesignDocument
    )
}

public class RecentWindowController: NSWindowController {
    
    public static func fromStoryboard(
        delegate: RecentDelegate,
        presenter: DocumentBrowserPresenterProtocol
    ) -> RecentWindowController {
        let storyboard = NSStoryboard(name: "RecentWindowController", bundle: Bundle.module)
        let windowController = storyboard.instantiateInitialController() as! RecentWindowController
        windowController.delegate = delegate
        windowController.presenter = presenter
        return windowController
    }
    
    weak var delegate: RecentDelegate?
    var presenter: DocumentBrowserPresenterProtocol!
    
    public override func windowDidLoad() {
        super.windowDidLoad()
        
        window?.setFrameAutosaveName("Projects")
        window?.styleMask.formUnion(.fullSizeContentView)
        window?.minSize = CGSize(width: 800, height: 700) // Two rows, 5 columns
        window?.titlebarAppearsTransparent = false
        
        shouldCascadeWindows = true
    }
    
    public func setupToolbarAppearance(title: String, toolbar: NSToolbar) {
        window?.title = title
        window?.toolbar = toolbar
    }
    
    public func embedProjectsViewControllerInWindow() {
        let controller = DocumentsTabViewController(router: self)
    
        setupToolbarAppearance(
            title: NSLocalizedString("VoiceOver Designer",
                                     comment: "Window's title"),
            toolbar: controller.toolbar())
        
        contentViewController = controller
    }
}

extension RecentWindowController: RecentRouter {
    
    public func show(document: VODesignDocument) {
        delegate?.createNewDocumentWindow(document: document)
    }
}
