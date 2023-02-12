//
//  ProjectsView.swift
//  Projects
//
//  Created by Mikhail Rubanov on 05.05.2022.
//

import AppKit
import Document
import CommonUI


protocol DocumentBrowserContextMenuDelegate: AnyObject {
    func didSelectDelete(at indexPath: IndexPath)
    func didSelectDuplicate(at indexPath: IndexPath)
    func didSelectMoveToCloud(at indexPath: IndexPath)
    func didSelectRename(at indexPath: IndexPath)
}

class DocumentsBrowserView: NSScrollView {
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
        
    @IBOutlet weak var collectionView: NSCollectionView! {
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
