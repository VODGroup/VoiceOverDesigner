import AppKit

extension ProjectController: NSToolbarDelegate {
    public func toolbar(
        _ toolbar: NSToolbar,
        itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
        willBeInsertedIntoToolbar flag: Bool
    ) -> NSToolbarItem? {
        switch itemIdentifier {
        case .voiceControlLabel: return labelToolbar()
        default: return nil
        }
    }
    
    public func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [
            .flexibleSpace,
            .voiceControlLabel,
            .sidebarTrackingSeparator,
            .toggleSidebar,
        ]
    }
    
    public func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [.toggleSidebar, .sidebarTrackingSeparator, .voiceControlLabel]
    }
}

extension ProjectController {
    private func labelToolbar() -> NSToolbarItem {
        let item = NSToolbarItem(itemIdentifier: .voiceControlLabel)
        item.label = NSLocalizedString("Labels", comment: "")
        item.enableLabels()
        item.target = self
        item.action = #selector(showLabels(sender:))
        item.isBordered = true
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
}
