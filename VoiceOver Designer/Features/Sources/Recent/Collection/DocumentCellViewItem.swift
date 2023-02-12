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
    
    var contextMenu: NSMenu = NSMenu()
    
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
}
