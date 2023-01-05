import AppKit

protocol ProjectRouterDelegate: AnyObject {
    func closeProject()
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
        default: return nil
        }
    }
    
    public func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [
            .toggleSidebar,
            .sidebarTrackingSeparator,
            .backButtonLabel,
            .flexibleSpace,
            .voiceControlLabel,
        ]
    }
    
    public func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [.toggleSidebar, .sidebarTrackingSeparator, .voiceControlLabel, .backButtonLabel]
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
        router?.closeProject()
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
}
