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

    public weak var router: RecentRouter?
    var presenter: RecentPresenter! {
        didSet {
            if needReloadDataOnStart {
                view().collectionView.reloadData()
            }
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view().collectionView.dataSource = self
        view().collectionView.delegate = self
        (view().collectionView.collectionViewLayout as? NSCollectionViewFlowLayout)?.minimumLineSpacing = 30
    }
    
    /// Sometimel layout is called right after loading from storyboard, presenter is not set and a crash happened.
    /// I added check that presenter is not nil, but we had to call reloadData as as result
    private var needReloadDataOnStart = false
    
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
    
    public func numberOfSections(in collectionView: NSCollectionView) -> Int {
        1
    }
    
    public func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        guard presenter != nil else {
            needReloadDataOnStart = true
            return 0
        }
        return presenter.numberOfItemsInSection(section)
    }
    
    public func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        switch presenter.item(at: indexPath)! {
        case .newDocument:
            let item = RecentNewDocCollectionViewItem()
            item.view.setAccessibilityIdentifier("New")
            return item
        case .document(let url):
            let item = RecentCollectionViewItem()
            item.configure(
                image: VODesignDocument.image(from: url),
                fileName: url.deletingPathExtension().lastPathComponent
            )
            return item
        }
    }
}

extension RecentViewController: NSCollectionViewDelegate {
    
    public func collectionView(
        _ collectionView: NSCollectionView,
        didSelectItemsAt indexPaths: Set<IndexPath>
    ) {
        for indexPath in indexPaths {
            switch presenter.item(at: indexPath)! {
            case .document(let url):
                let document = VODesignDocument(file: url)
                show(document: document)
                
            case .newDocument:
                createNewProject()
            }
        }
    }
}
