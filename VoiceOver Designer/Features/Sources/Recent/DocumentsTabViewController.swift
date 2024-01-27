import AppKit
import Document // For @Storage

public class DocumentsTabViewController: NSTabViewController {
    
    public enum SelectedTab: Int {
        case recent = 0
        case samples = 1
    }
    
    public init(router: RecentRouter, selectedTab: SelectedTab) {
        super.init(nibName: nil, bundle: nil)
        
        let documentsController = documentsBrowserController(presenter: UserDocumentsPresenter(), router: router)
        documentsController.title = NSLocalizedString("Recent documents", comment: "Tab's title")
        let userDocumentsTab = NSTabViewItem(viewController: documentsController)
        userDocumentsTab.label = NSLocalizedString("My documents", comment: "Tab's label")
        userDocumentsTab.image = NSImage(systemSymbolName: "tray.full", accessibilityDescription: "My documents")
        
        let samplesController = documentsBrowserController(
            presenter: SamplesDocumentsPresenter(),
            router: router)
        samplesController.title = NSLocalizedString("Samples", comment: "Tab's title")
        let samplesTab = NSTabViewItem(viewController: samplesController)
        samplesTab.label = NSLocalizedString("Samples", comment: "Tab's label")
        samplesTab.image = NSImage(systemSymbolName: "sparkles.rectangle.stack", accessibilityDescription: "Samples")
        
        addTabViewItem(userDocumentsTab)
        addTabViewItem(samplesTab)
        
        tabStyle = .unspecified
        selectedTabViewItemIndex = selectedTab.rawValue// Self.lastSelectedTabIndex
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewWillAppear() {
        super.viewWillAppear()
        
        view.window?.toolbarStyle = .unified
    }
    
    func documentsBrowserController(
        presenter: DocumentBrowserPresenterProtocol,
        router: RecentRouter
    ) -> DocumentsBrowserViewController {
        let projects = DocumentsBrowserViewController.fromStoryboard()
        projects.title = "1"
        projects.presenter = presenter
        projects.router = router
        return projects
    }
    
    private var presenter: DocumentBrowserPresenterProtocol {
        let item = tabViewItems[selectedTabViewItemIndex].viewController as! DocumentsBrowserViewController
        return item.presenter
    }
    
    @Storage(key: "RecentSelectedTab", defaultValue: 0)
    static var lastSelectedTabIndex: Int
}

// MARK: - Toolbar
extension DocumentsTabViewController {
    public func toolbar() -> NSToolbar {
        let toolbar = NSToolbar()
        toolbar.delegate = self
        toolbar.displayMode = .iconOnly
        
        if #available(macOS 13.0, *) {
            toolbar.centeredItemIdentifiers = [.documents]
        }
        return toolbar
    }
    
    public override func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [.documents, .flexibleSpace]
    }
    
    public override func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [.documents, .language]
    }
    
    public override func toolbar(
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
            group.selectedIndex = Self.lastSelectedTabIndex
            return group
        case .language:
            guard let languageSource = presenter as? LanguageSource else { return nil }
            
            let language = LanguageButton(languageSource: languageSource)
            
            return language
        default:
            return nil
        }
    }
    
    @objc func selectTab(sender: NSToolbarItemGroup) {
        guard selectedTabViewItemIndex != sender.selectedIndex else { return }
        selectedTabViewItemIndex = sender.selectedIndex
        Self.lastSelectedTabIndex = sender.selectedIndex
        
        if let toolbar = sender.toolbar {
            let isSamplesTab = sender.selectedIndex == 1
            if isSamplesTab {
                toolbar.appendItem(with: .language)
            } else {
                toolbar.removeItem(identifier: .language)
            }
        }
        
        // TODO: Remember selected tab
    }
}

extension NSToolbarItem.Identifier {
    static let documents = NSToolbarItem.Identifier(rawValue: "Documents")
    static let language = NSToolbarItem.Identifier(rawValue: "Language")
}

extension NSToolbar {
    @discardableResult
    fileprivate func removeItem(identifier: NSToolbarItem.Identifier) -> Bool {
        if let itemIndex = buttonIndex(identifier: identifier) {
            removeItem(at: itemIndex)
            return true
        }
        
        return false
    }
    
    fileprivate func buttonIndex(identifier: NSToolbarItem.Identifier) -> Int? {
        let documentIndex = visibleItems?.firstIndex(where: { item in
            item.itemIdentifier == identifier
        })
        
        return documentIndex
    }
    
    fileprivate func hasButton(with identifier: NSToolbarItem.Identifier) -> Bool {
        buttonIndex(identifier: identifier) != nil
    }
    
    fileprivate func appendItem(with identifier: NSToolbarItem.Identifier) {
        guard !hasButton(with: identifier) else {
            return
        }
        
        insertItem(withItemIdentifier: identifier, at: items.count)
    }
    
    func resetLanguageButton() {
        removeItem(identifier: .language)
        appendItem(with: .language)
    }
}

public class LanguageButton: NSMenuToolbarItem {
    
    private let languageSource: LanguageSource
    
    init(languageSource: LanguageSource) {
        self.languageSource = languageSource
        
        super.init(itemIdentifier: .language)
        
        let title = NSLocalizedString("Language", comment: "Toolbar item's label")
        let menu = NSMenu(title: title)
        let locale = Locale.current
        
        for (tag, languageCode) in languageSource.possibleLanguages.enumerated() {
            let language = locale.localizedString(forLanguageCode: languageCode) ?? languageCode
            
            let menuItem = NSMenuItem(title: language, action: #selector(selectLanguage(sender:)), keyEquivalent: "")
            menuItem.tag = tag
            
            menu.addItem(menuItem)
        }
        
        self.menu = menu
        isBordered = false
        if let currentLanguage = languageSource.samplesLanguage,
           let languageTitle = locale.localizedString(forLanguageCode: currentLanguage) {
            self.title = languageTitle
        } else {
            self.title = NSLocalizedString("Language", comment: "Toolbar item")
        }
    }
    
    @objc private func selectLanguage(sender: NSMenuItem) {
        let languageCode = languageSource.possibleLanguages[sender.tag]
        
        languageSource.presentProjects(with: languageCode)
    }
}
