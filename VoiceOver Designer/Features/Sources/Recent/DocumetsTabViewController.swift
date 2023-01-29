import AppKit

class DocumetsTabViewController: NSTabViewController {
    
    init(router: RecentRouter) {
        super.init(nibName: nil, bundle: nil)
        
        let userDocuments = NSTabViewItem(viewController: documentsBrowserController(presenter: UserDocumentsPresenter(), router: router))
        userDocuments.label = NSLocalizedString("My documents", comment: "Tab's label")
        userDocuments.image = NSImage(systemSymbolName: "tray.full", accessibilityDescription: "My documents")
        
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
    
    private var presenter: DocumentBrowserPresenterProtocol {
        let item = tabViewItems[selectedTabViewItemIndex].viewController as! DocumentsBrowserViewController
        return item.presenter
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
        return [.documents, .flexibleSpace]
    }
    
    override func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [.documents, .language]
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
            guard let languageSource = presenter as? LanguageSource else { return nil }
            
            let title = NSLocalizedString("Language", comment: "Toolbar item's label")
            let menu = NSMenu(title: title)
            let locale = Locale.current
            
            for (tag, languageCode) in languageSource.possibleLanguages.enumerated() {
                let language = locale.localizedString(forLanguageCode: languageCode) ?? languageCode
                
                let menuItem = NSMenuItem(title: language, action: #selector(selectLanguage(sender:)), keyEquivalent: "")
                menuItem.tag = tag
                
                menu.addItem(menuItem)
            }
            
            let language = NSMenuToolbarItem(itemIdentifier: .language)
            
            if let currentLanguage = languageSource.currentUserLanguage,
               let languageTitle = locale.localizedString(forLanguageCode: currentLanguage) {
                language.title = languageTitle
            } else {
                language.title = NSLocalizedString("Language", comment: "Toolbar item")
            }
            language.menu = menu
            
            return language
        default:
            return nil
        }
    }
    
    @objc func selectTab(sender: NSToolbarItemGroup) {
        selectedTabViewItemIndex = sender.selectedIndex
        
        if let toolbar = sender.toolbar {
            let isSamplesTab = sender.selectedIndex == 1
            if isSamplesTab {
                toolbar.appendItem(with: .language)
            } else {
                toolbar.removeItem(identifier: .language)
            }
        }
    }
    
    @objc func selectLanguage(sender: NSMenuItem) {
        guard let languageSource = presenter as? LanguageSource else { return }
        
        let languageCode = languageSource.possibleLanguages[sender.tag]
                
        languageSource.presentProjects(with: languageCode)
    }
}

extension NSToolbarItem.Identifier {
    static let documents = NSToolbarItem.Identifier(rawValue: "Documents")
    static let language = NSToolbarItem.Identifier(rawValue: "Language")
}

extension NSToolbar {
    func removeItem(identifier: NSToolbarItem.Identifier) {
        if let documentIndex = visibleItems?.firstIndex(where: { item in
            item.itemIdentifier == identifier
        }) {
            removeItem(at: documentIndex)
        }
    }
    
    func appendItem(with identifer: NSToolbarItem.Identifier) {
        insertItem(withItemIdentifier: identifer, at: items.count)
    }
    
    func resetLanguageButton() {
        removeItem(identifier: .language)
        appendItem(with: .language)
    }
}
