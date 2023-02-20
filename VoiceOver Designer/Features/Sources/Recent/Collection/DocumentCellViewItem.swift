//
//  ProjectCell.swift
//  Projects
//
//  Created by Andrey Plotnikov on 16.07.2022.
//

import Foundation
import AppKit
import Document
import Samples

class DocumentCellViewItem: NSCollectionViewItem {
    static let identifier = NSUserInterfaceItemIdentifier(rawValue: String(describing: DocumentCellViewItem.self))
    
    let projectCellView = DocumentCellView()
    
    private var contextMenu: NSMenu = NSMenu()
    
    
    private var renameAction: DocumentRenameAction?
    
    override func loadView() {
        view = projectCellView
    }
    
    func configure(fileName: String) {
        view.setAccessibilityLabel(fileName)
        projectCellView.fileNameTextField.stringValue = fileName
        projectCellView.layoutSubtreeIfNeeded()
    }

    @MainActor
    var image: NSImage? {
        didSet {
            projectCellView.image = image
        }
    }
    
    private var currentDocument: URL?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        image = nil
    }
    
    
    func configureContextMenu(
        items: [NSMenuItem],
        renameAction: DocumentRenameAction?
    ) {
        contextMenu.items = items
        // If there's renameAction, adding action to enable textfield editing
        if let renameAction {
            self.renameAction = renameAction
            contextMenu.addItem(NSMenuItem(title: renameAction.name, action: #selector(renameItemClicked), keyEquivalent: renameAction.keyEquivalent))
        }
    }
    
    func loadThumbnail(
        for documentPath: DocumentPath,
        backingScaleFactor: CGFloat
    ) {
        Task {
            let sampleLoader = SampleLoader(document: documentPath)
            
            projectCellView.state = nil
            
            if sampleLoader.isFullyLoaded() {
                projectCellView.state = .image
            } else {
                projectCellView.state = .needLoading
            }
            
            try await sampleLoader.prefetch()
            
            let documentURL = sampleLoader.documentPathInCache
            readThumbnail(documentURL: documentURL,
                          backingScaleFactor: backingScaleFactor)
        }
    }
    
    override func rightMouseDown(with event: NSEvent) {
        super.rightMouseDown(with: event)
        NSMenu.popUpContextMenu(contextMenu, with: event, for: view)
    }
    
    func readThumbnail(
        documentURL: URL,
        backingScaleFactor: CGFloat
    ) {
        self.currentDocument = documentURL
        Task {
            // TODO: Move inside Document's model
            // TODO: Cache in not working yet
            let image = await ThumbnailDocument(documentURL: documentURL)
                .thumbnail(size: expectedImageSize,
                           scale: backingScaleFactor)
            
            let isStillSameDocument = self.currentDocument == documentURL
            if isStillSameDocument {
                self.image = image
            }
        }
    }
    
    var expectedImageSize: CGSize {
        CGSize(width: 125,
               height: 280)
    }
    
    @objc private func renameItemClicked() {
        projectCellView.fileNameTextField.delegate = self
        projectCellView.fileNameTextField.isEditable = true
        projectCellView.fileNameTextField.becomeFirstResponder()
    }
}

extension DocumentCellViewItem: NSTextFieldDelegate {
    public func controlTextDidEndEditing(_ obj: Notification) {
            guard let textField = obj.object as? NSTextField else { return }
            defer {
                textField.delegate = nil
                textField.isEditable = false
            }
            do {
                try renameAction?(textField.stringValue)
            } catch {
            // TODO: reset Name
            }

        }
}
