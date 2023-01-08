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
        presenter: RecentPresenter
    ) -> RecentWindowController {
        let storyboard = NSStoryboard(name: "RecentWindowController", bundle: Bundle.module)
        let windowController = storyboard.instantiateInitialController() as! RecentWindowController
        windowController.delegate = delegate
        windowController.presenter = presenter
        return windowController
    }
    
    weak var delegate: RecentDelegate?
    var presenter: RecentPresenter!
    
    public override func windowDidLoad() {
        super.windowDidLoad()
        
        window?.setFrameAutosaveName("Projects")
        window?.styleMask.formUnion(.fullSizeContentView)
        window?.minSize = CGSize(width: 800, height: 600) // Two rows, 5 columns
        window?.titlebarAppearsTransparent = false
        resetToolbarAppearance()
        
        shouldCascadeWindows = true
    }
    
    public func resetToolbarAppearance() {
        setupToolbarAppearance(title: NSLocalizedString("VoiceOver Designer",
                                                        comment: "Window's title"),
                               toolbar: NSToolbar())
        
    }
    
    public func setupToolbarAppearance(title: String, toolbar: NSToolbar) {
        window?.title = title
        window?.toolbar = toolbar
        
    }
    
    public func embedProjectsViewControllerInWindow() {
        let projects = projectsController(presenter: presenter)
        projects.view().collectionView.reloadData()
        contentViewController = projects
        
    }
    
    public func projectsController(presenter: RecentPresenter) -> RecentViewController {
        let projects = RecentViewController.fromStoryboard()
        projects.presenter = presenter
        projects.router = self
        return projects
    }
}

extension RecentWindowController: RecentRouter {
    
    public func show(document: VODesignDocument) {
        delegate?.createNewDocumentWindow(document: document)
    }
}
