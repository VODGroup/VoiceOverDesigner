import AppKit

protocol ProjectRouterDelegate: AnyObject {
    func closeProject(document: NSDocument)
    func lastSplitToggle(isCollapsed: Bool)
}

extension ProjectController: NSToolbarDelegate {
    public func toolbar(
        _ toolbar: NSToolbar,
        itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
        willBeInsertedIntoToolbar flag: Bool
    ) -> NSToolbarItem? {
        switch itemIdentifier {
        case .voiceControlLabel: return labelItem()
        case .backButtonLabel: return backItem()
        case .trailingSidebar: return trailingSideBarItem()
        case .leadingSidebar: return leadingSideBarItem()
        case .itemListTrackingSeparator:
                return NSTrackingSeparatorToolbarItem(
                    identifier: .itemListTrackingSeparator,
                    splitView: splitView,
                    dividerIndex: 1
                )
        default: return nil
        }
    }
    
    public func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [
            .flexibleSpace,
            .leadingSidebar,
            .sidebarTrackingSeparator,
            .backButtonLabel,
            .flexibleSpace,
            .flexibleSpace,
            .voiceControlLabel,
            .trailingSidebar
        ]
    }
    
    public func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [.toggleSidebar, .sidebarTrackingSeparator, .voiceControlLabel, .backButtonLabel, .trailingSidebar, .leadingSidebar, .itemListTrackingSeparator]
    }
}

extension ProjectController {
    private func labelItem() -> NSToolbarItem {
        let item = NSToolbarItem(itemIdentifier: .voiceControlLabel)
        item.label = NSLocalizedString("Labels", comment: "")
        item.enableLabels()
        item.target = self
        item.action = #selector(showLabels(sender:))
        item.isBordered = true
        return item
    }
    
    private func backItem() -> NSToolbarItem {
        let item = NSToolbarItem(itemIdentifier: .backButtonLabel)
        item.label = NSLocalizedString("Back", comment: "")
        item.target = self
        item.action = #selector(backDidPressed(sender:))
        item.isBordered = true
        item.image = NSImage(systemSymbolName: "chevron.backward",
                             accessibilityDescription: "Back to documents")!
        item.toolTip = NSLocalizedString("Go to my documents", comment: "")
        item.isNavigational = true
        return item
    }
    
    private func leadingSideBarItem() -> NSToolbarItem {
        let item = NSToolbarItem(itemIdentifier: .trailingSidebar)
        item.label = NSLocalizedString("Navigator", comment: "")
        item.target = self
        item.action = #selector(leadingSideBarTapped(sender:))
        item.isBordered = true
        item.image = NSImage(systemSymbolName: "sidebar.leading",
                             accessibilityDescription: "Close navigator sidebar")!
        item.toolTip = NSLocalizedString("Close navigator sidebar", comment: "")
        return item
    }
    
    private func trailingSideBarItem() -> NSToolbarItem {
        let item = NSToolbarItem(itemIdentifier: .trailingSidebar)
        item.label = NSLocalizedString("Inspector", comment: "")
        item.target = self
        item.action = #selector(trailingSideBarTapped(sender:))
        item.isBordered = true
        item.image = NSImage(systemSymbolName: "sidebar.trailing",
                             accessibilityDescription: "Close inspector sidebar")!
        item.toolTip = NSLocalizedString("Close inspector sidebar", comment: "")
        return item
    }
    
    @objc private func showLabels(sender: NSToolbarItem) {
        sender.action = #selector(hideLabels(sender:))
        canvas.presenter.showLabels()
        
        sender.disableLabels()
    }
    
    @objc private func hideLabels(sender: NSToolbarItem) {
        sender.action = #selector(showLabels(sender:))
        canvas.presenter.hideLabels()
        
        sender.enableLabels()
    }
    
    @objc private func backDidPressed(sender: NSToolbarItem) {
        router?.closeProject(document: document)
    }
    
    @objc private func leadingSideBarTapped(sender: NSToolbarItem) {
        guard let firstSplitView = splitViewItems.first else { return }
        firstSplitView.animator().isCollapsed.toggle()
    }
    
    @objc private func trailingSideBarTapped(sender: NSToolbarItem) {
        guard let lastSplitView = splitViewItems.last else { return }
        lastSplitView.animator().isCollapsed.toggle()
        router?.lastSplitToggle(isCollapsed: lastSplitView.isCollapsed)
    }
}

extension NSToolbarItem {
    func enableLabels() {
        image = NSImage(systemSymbolName: "text.bubble",
                        accessibilityDescription: "Show labels")!
        toolTip = NSLocalizedString("Show labels of elements", comment: "")
        
    }
    
    func disableLabels() {
        image = NSImage(systemSymbolName: "text.bubble.fill",
                        accessibilityDescription: "Hide labels")
        toolTip = NSLocalizedString("Hide labels of elements", comment: "")
    }
}

extension NSToolbarItem.Identifier {
    static let voiceControlLabel = NSToolbarItem.Identifier(rawValue: "VoiceControlLabel")
    static let backButtonLabel = NSToolbarItem.Identifier(rawValue: "BackButtonLabel")
    static let trailingSidebar = NSToolbarItem.Identifier(rawValue: "TrailingSidebar")
    static let leadingSidebar = NSToolbarItem.Identifier(rawValue: "LeadingSidebar")
    static let itemListTrackingSeparator = NSToolbarItem.Identifier("ItemListTrackingSeparator")
}
