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
    
    weak var delegate: (any DocumentBrowserContextMenuDelegate)?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configureMenu() {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Delete", action: #selector(didSelectDelete(_:)), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Duplicate", action: #selector(didSelectDuplicate(_:)), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Rename", action: #selector(didSelectRename(_:)), keyEquivalent: ""))
        if FileManager.default.iCloudAvailable {
            menu.addItem(NSMenuItem(title: "Move to iCloud", action: #selector(didSelectMoveToCloud(_:)), keyEquivalent: ""))
        }
        collectionView.menu = menu
    }
    
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
    
    @objc func didSelectDelete(_ item: NSMenuItem) {
        guard let indexPath = collectionView.clickedIndexPath else { return }
        delegate?.didSelectDelete(at: indexPath)
    }
    
    @objc func didSelectDuplicate(_ item: NSMenuItem) {
        guard let indexPath = collectionView.clickedIndexPath else { return }
        delegate?.didSelectDuplicate(at: indexPath)
    }
    
    @objc func didSelectMoveToCloud(_ item: NSMenuItem) {
        guard let indexPath = collectionView.clickedIndexPath else { return }
        delegate?.didSelectMoveToCloud(at: indexPath)
    }
    
    @objc func didSelectRename(_ item: NSMenuItem) {
        guard let indexPath = collectionView.clickedIndexPath else { return }
        delegate?.didSelectRename(at: indexPath)
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
