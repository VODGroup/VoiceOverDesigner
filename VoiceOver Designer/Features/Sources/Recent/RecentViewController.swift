//
//  RecentViewController.swift
//  VoiceOver Designer
//
//  Created by Mikhail Rubanov on 05.05.2022.
//

import AppKit
import Document
import CommonUI

public protocol RecentRouter: AnyObject {
    func show(document: VODesignDocument) -> Void
}

public class RecentViewController: NSViewController {
    
    /// Type of cell in collection view
    enum CollectionViewItem {
        /// Regular (existing) document item
        case document(URL)
        /// Add new document item
        case newDocument
    }
    
    public weak var documentController: NSDocumentController?
    
    public weak var router: RecentRouter?
    
    private var items: [CollectionViewItem] {
        let documentItems = (documentController?.recentDocumentURLs ?? []).map { CollectionViewItem.document($0) }
        return [.newDocument] + documentItems
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view().collectionView.dataSource = self
        view().collectionView.delegate = self
    }
    
    override public func loadView() {
        view = RecentView(frame: CGRect(origin: .zero,
                                          size: CGSize(width: 800, height: 400)))
    }
    
    func view() -> RecentView {
        view as! RecentView
    }
    
    private func createNewProject() {
        let document = VODesignDocument()
        show(document: document)
    }

    private func show(document: VODesignDocument) {
        router?.show(document: document)
    }
    
    public static func fromStoryboard() -> RecentViewController {
        let storyboard = NSStoryboard(name: "RecentViewController", bundle: .module)
        return storyboard.instantiateInitialController() as! RecentViewController
    }
}

extension RecentViewController: DragNDropDelegate {
    public func didDrag(path: URL) {
        let document = VODesignDocument(fileName: path.lastPathComponent,
                                        rootPath: path.deletingLastPathComponent())
        show(document: document)
    }
    
    public func didDrag(image: NSImage) {
        let document = VODesignDocument(image: image)
        show(document: document)
    }
}


extension RecentViewController : NSCollectionViewDataSource {
    
    public func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }
    
    public func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        switch items[indexPath.item] {
        case .newDocument:
            return RecentNewDocCollectionViewItem()
        case .document(let url):
            let item = RecentCollectionViewItem()
            item.configure(
                image: VODesignDocument.image(from: url),
                fileName: url.deletingPathExtension().lastPathComponent
            )
            return item
        }
    }
    
    public func numberOfSections(in collectionView: NSCollectionView) -> Int {
        1
    }
}

extension RecentViewController: NSCollectionViewDelegate {
    
    public func collectionView(_ collectionView: NSCollectionView,
                               didSelectItemsAt indexPaths: Set<IndexPath>) {
        for indexPath in indexPaths {
            switch items[indexPath.item] {
            case .document(let url):
                let document = VODesignDocument(file: url)
                show(document: document)
                
            case .newDocument:
                createNewProject()
            }
        }
    }
}
