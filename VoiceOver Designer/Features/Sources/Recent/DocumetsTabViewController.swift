import AppKit

class DocumetsTabViewController: NSTabViewController {
    
    init(router: RecentRouter) {
        super.init(nibName: nil, bundle: nil)
        
        let userDocuments = NSTabViewItem(viewController: documentsBrowserController(presenter: UserDocumentsPresenter(), router: router))
        userDocuments.label = NSLocalizedString("Your documents", comment: "Tab's label")
        userDocuments.image = NSImage(systemSymbolName: "tray.full", accessibilityDescription: "Your documents")
        
        let samples = NSTabViewItem(viewController: documentsBrowserController(
            presenter: SamplesDocumentsPresenter(),
            router: router))
        samples.label = NSLocalizedString("Samples", comment: "Tab's label")
        samples.image = NSImage(systemSymbolName: "sparkles.rectangle.stack", accessibilityDescription: "Samples")
        
        addTabViewItem(userDocuments)
        addTabViewItem(samples)
        
        tabStyle = .unspecified
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        view.window?.toolbarStyle = .unified
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

// MARK: - Toolbar
extension DocumetsTabViewController {
    func toolbar() -> NSToolbar {
        let toolbar = NSToolbar()
        toolbar.delegate = self
        toolbar.displayMode = .iconOnly
        
        if #available(macOS 13.0, *) {
            toolbar.centeredItemIdentifiers = [.documents]
        }
        return toolbar
    }
    
    override func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [.documents, .flexibleSpace, .language]
    }
    
    override func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [.documents, .language]
    }
    
    override func toolbar(
        _ toolbar: NSToolbar,
        itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
        willBeInsertedIntoToolbar flag: Bool
    ) -> NSToolbarItem? {
        switch itemIdentifier {
        case .documents:
            let titles = tabViewItems.map { item in item.label + "     " } // It's so strange to align elements by spaces
            
            let group = NSToolbarItemGroup(itemIdentifier: .documents,
                                           titles: titles,
                                           selectionMode: .selectOne,
                                           labels: nil,
                                           target: self, action: #selector(selectTab(sender:)))
            group.selectedIndex = 0
            return group
        case .language:
            let title = NSLocalizedString("Language", comment: "Toolbar item's label")
            
            let menu = NSMenu(title: title)
            menu.addItem(NSMenuItem(title: "Russian", action: #selector(selectLanguage(sender:)), keyEquivalent: ""))
            menu.addItem(NSMenuItem(title: "English", action: #selector(selectLanguage(sender:)), keyEquivalent: ""))
            
            let language = NSMenuToolbarItem(itemIdentifier: .language)
            language.label = title
            language.image = NSImage(systemSymbolName: "globe", accessibilityDescription: title)
            language.menu = menu
            
            return language
        default:
            return nil
        }
    }
    
    @objc func selectTab(sender: NSToolbarItemGroup) {
        selectedTabViewItemIndex = sender.selectedIndex
    }
    
    @objc func selectLanguage(sender: AnyObject) {
        
    }
}

extension NSToolbarItem.Identifier {
    static let documents = NSToolbarItem.Identifier(rawValue: "Documents")
    static let language = NSToolbarItem.Identifier(rawValue: "Language")
}
