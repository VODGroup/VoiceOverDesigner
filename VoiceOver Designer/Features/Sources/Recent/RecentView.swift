//
//  ProjectsView.swift
//  Projects
//
//  Created by Mikhail Rubanov on 05.05.2022.
//

import AppKit
import CommonUI

class RecentView: NSScrollView {
    
    @IBOutlet weak var collectionView: NSCollectionView! {
        didSet {
            collectionView.isSelectable = true
            collectionView.register(
                RecentNewDocCollectionViewItem.self,
                forItemWithIdentifier: RecentNewDocCollectionViewItem.identifier)
            collectionView.register(
                RecentCollectionViewItem.self,
                forItemWithIdentifier: RecentCollectionViewItem.identifier)
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
