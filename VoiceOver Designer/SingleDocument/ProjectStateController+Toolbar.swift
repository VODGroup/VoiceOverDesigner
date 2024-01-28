import AppKit
import Document

protocol ProjectRouterDelegate: AnyObject {
    func showRecent(_ sender: NSToolbarItem)
    func showSamples(_ sender: NSToolbarItem)
}

extension ProjectStateController: NSToolbarDelegate {
    public func toolbar(
        _ toolbar: NSToolbar,
        itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
        willBeInsertedIntoToolbar flag: Bool
    ) -> NSToolbarItem? {
        switch itemIdentifier {
        case .recentButtonLabel: return recentItem()
        case .samplesButtonLabel: return samplesItem()
        case .trailingSidebar: return trailingSideBarItem()
        case .shareDocument: return shareDocumentItem()
        case .itemListTrackingSeparator:
            return NSTrackingSeparatorToolbarItem(
                identifier: .itemListTrackingSeparator,
                splitView: editor.splitView,
                dividerIndex: 1
            )
        case .presentation: return presentationSideBarItem()
        default: return nil
        }
    }
    
    public func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        var result: [NSToolbarItem.Identifier] = [
            .toggleSidebar,
            .sidebarTrackingSeparator,
            
            .recentButtonLabel,
            .samplesButtonLabel,
            .shareDocument,
            // Title
            .flexibleSpace,
            .presentation,
        ]
        
        if #available(macOS 14.0, *) {
            result.append(.inspectorTrackingSeparator)
            result.append(.flexibleSpace)
        }
        
        result.append(.trailingSidebar)
        
        return result
    }
    
    public func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        var result: [NSToolbarItem.Identifier] = [.toggleSidebar,
         .sidebarTrackingSeparator,
         .recentButtonLabel,
         .samplesButtonLabel,
         .shareDocument,
         .presentation,
         ]
        
        if #available(macOS 14.0, *) {
            result.append(.inspectorTrackingSeparator)
            result.append(.flexibleSpace)
        }
        
        result.append(.trailingSidebar)
        
        return result
    }

    var presentationAllowedItems: [NSToolbarItem.Identifier] {
        [
            .recentButtonLabel,
            .samplesButtonLabel,
            .editor,
            .shareDocument
        ]
    }
}

extension ProjectStateController {
    private func recentItem() -> NSToolbarItem {
        let item = NSToolbarItem.makeRecentItem()
        item.target = self
        item.action = #selector(showRecentDidPressed(sender:))
        return item
    }
    
    private func samplesItem() -> NSToolbarItem {
        let item = NSToolbarItem.makeSamplesItem()
        item.target = self
        item.action = #selector(showSamplesDidPressed(sender:))
        return item
    }
    
    private func shareDocumentItem() -> NSToolbarItem {
        let item = NSSharingServicePickerToolbarItem(itemIdentifier: .shareDocument)
        item.delegate = document
//        item.isNavigational = true
        return item
    }
    
    @available(macOS, obsoleted: 14.0)
    private func trailingSideBarItem() -> NSToolbarItem {
        let item = NSToolbarItem.trailingSideBarItem()
        item.target = self
        item.action = #selector(trailingSideBarTapped(sender:))
        return item
    }

    private func presentationSideBarItem() -> NSToolbarItem {
        let item = NSToolbarItem.presentationSideBarItem()
        item.target = self
        item.action = #selector(presentationModeTapped(sender:))
        item.menuFormRepresentation = playMenuItem
        return item
    }

    @objc private func showRecentDidPressed(sender: NSToolbarItem) {
        router?.showRecent(sender)
    }
    
    @objc private func showSamplesDidPressed(sender: NSToolbarItem) {
        router?.showSamples(sender)
    }
    
    @objc private func leadingSideBarTapped(sender: NSToolbarItem) {
        guard let firstSplitView = editor.splitViewItems.first else { return }
        firstSplitView.animator().isCollapsed.toggle()
    }
    
    @available(macOS, obsoleted: 14.0)
    @objc private func trailingSideBarTapped(sender: NSToolbarItem) {
        guard let lastSplitView = editor.splitViewItems.last else { return }
        lastSplitView.animator().isCollapsed.toggle()
        
        let lastIndex = editorToolbar.items.endIndex
        if lastSplitView.isCollapsed {
            editorToolbar.removeItem(at: lastIndex)
        } else {
            editorToolbar.insertItem(withItemIdentifier: .itemListTrackingSeparator, at: lastIndex)
        }
    }

    // MARK: - Presentation mode
    @objc private func presentationModeTapped(sender: NSToolbarItem) {
        enablePresentation()
    }
    
    @objc func enablePresentation() {
        stopMenuItem.isHidden.toggle()
        playMenuItem.isHidden.toggle()
        
        Set(toolbarAllowedItemIdentifiers(editorToolbar))
            .subtracting(presentationAllowedItems)
            .forEach {
                editorToolbar.removeItem(identifier: $0)
            }
        
        editorToolbar.insertItem(withItemIdentifier: .editor, at: editorToolbar.items.endIndex)
        
        setAllTabs(to: .presentation)
    }
    
    private func setAllTabs(to state: ProjectWindowState) {
        view.window?.tabGroup?.windows
            .compactMap( { $0.contentViewController as? ProjectStateController} )
            .forEach({ controller in
                controller.state = state
            })
    }
    
    @objc func stopPresentation() {
        stopMenuItem.isHidden.toggle()
        playMenuItem.isHidden.toggle()
        
        if let prevIndex = editorToolbar.removeItem(identifier: .editor) {
            editorToolbar.insertItem(withItemIdentifier: .presentation, at: prevIndex - 1)
        }
        
        setAllTabs(to: .editor)
    }

    @objc private func editorModeTapped(sender: NSToolbarItem) {
        stopPresentation()
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

extension VODesignDocument: NSSharingServicePickerToolbarItemDelegate {
    public func items(for pickerToolbarItem: NSSharingServicePickerToolbarItem) -> [Any] {
        [fileURL as Any]
    }
}
