import AppKit

class DocumetsTabViewController: NSTabViewController {
    
    init(router: RecentRouter) {
        super.init(nibName: nil, bundle: nil)
        
        let userDocuments = NSTabViewItem(viewController: documentsBrowserController(presenter: UserDocumentsPresenter(), router: router))
        userDocuments.label = NSLocalizedString("Your documents", comment: "Tab's label")
        
        let samples = NSTabViewItem(viewController: documentsBrowserController(
            presenter: SamplesDocumentsPresenter(),
            router: router))
        samples.label = NSLocalizedString("Samples", comment: "Tab's label")
        
        addTabViewItem(userDocuments)
        addTabViewItem(samples)
        
        tabStyle = .toolbar
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func documentsBrowserController(
        presenter: DocumentBrowserPresenterProtocol,
        router: RecentRouter
    ) -> DocumentsBrowserViewController {
        let projects = DocumentsBrowserViewController.fromStoryboard()
        projects.presenter = presenter
        projects.router = router
        return projects
    }
}

extension DocumetsTabViewController {
    func toolbar() -> NSToolbar {
        let toolbar = NSToolbar()
        toolbar.delegate = self
        return toolbar
    }
}

extension NSToolbarItem.Identifier {
    static let documentTypeSwitcher = NSToolbarItem.Identifier(rawValue: "DocumentTypeSwitcher")
}
