//
//  ProjectsView.swift
//  Projects
//
//  Created by Mikhail Rubanov on 05.05.2022.
//

import AppKit
import CommonUI

class DocumentsBrowserView: NSScrollView {
    
    @IBOutlet weak var collectionView: ClickedCollectionView! {
        didSet {
            collectionView.isSelectable = true
            collectionView.register(
                NewDocumentCollectionViewItem.self,
                forItemWithIdentifier: NewDocumentCollectionViewItem.identifier)
            collectionView.register(
                DocumentCellViewItem.self,
                forItemWithIdentifier: DocumentCellViewItem.identifier)
            collectionView.setAccessibilityLabel("Projects preview")
        }
    }
    
    @IBOutlet weak var flowLayout: NSCollectionViewFlowLayout! {
        didSet {
            flowLayout.scrollDirection = .vertical
            flowLayout.itemSize = CGSize(width: 125, height: 300)
            flowLayout.sectionInset = .init(top: 16, left: 16, bottom: 0, right: 16)
            flowLayout.minimumLineSpacing = 30
        }
    }
}

class ClickedCollectionView: NSCollectionView {
    var clickedIndexPath: IndexPath?

    override func menu(for event: NSEvent) -> NSMenu? {
        clickedIndexPath = nil

        let point = convert(event.locationInWindow, from: nil)
        
        clickedIndexPath = indexPathForItem(at: point)
    
        return super.menu(for: event)
    }
}
