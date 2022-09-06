//
//  ProjectsView.swift
//  Projects
//
//  Created by Mikhail Rubanov on 05.05.2022.
//

import AppKit
import CommonUI

class RecentView: NSView {
    
    var scrollViewCollectionView = NSScrollView()
    
    lazy var collectionView: NSCollectionView = {
        let flowLayout = NSCollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.itemSize = CGSize(width: 100, height: 250)
        flowLayout.sectionInset = .init(top: 16, left: 16, bottom: 0, right: 16)
        let collection = NSCollectionView()
        collection.collectionViewLayout = flowLayout
        collection.isSelectable = true
        collection.register(RecentNewDocCollectionViewItem.self, forItemWithIdentifier: RecentNewDocCollectionViewItem.identifier)
        collection.register(RecentCollectionViewItem.self, forItemWithIdentifier: RecentCollectionViewItem.identifier)
        return collection
    }()
    
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        addSubviews()
        addConstraints()
    }
    
    func addSubviews() {
        scrollViewCollectionView.documentView = collectionView
        [scrollViewCollectionView].forEach(addSubview(_:))
    }
    
    func addConstraints() {
        scrollViewCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollViewCollectionView.topAnchor.constraint(equalTo: scrollViewCollectionView.superview!.topAnchor),
            scrollViewCollectionView.leadingAnchor.constraint(equalTo: scrollViewCollectionView.superview!.leadingAnchor),
            scrollViewCollectionView.trailingAnchor.constraint(equalTo: scrollViewCollectionView.superview!.trailingAnchor),
            scrollViewCollectionView.bottomAnchor.constraint(equalTo: scrollViewCollectionView.superview!.bottomAnchor)
        ])
    }
}
