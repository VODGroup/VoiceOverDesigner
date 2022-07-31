//
//  ProjectsViewController.swift
//  VoiceOver Designer
//
//  Created by Mikhail Rubanov on 05.05.2022.
//

import AppKit
import Document
import CommonUI

public protocol ProjectsRouter: AnyObject {
    func show(document: VODesignDocument) -> Void
}

public class ProjectsViewController: NSViewController {
    
    public weak var documentController: NSDocumentController?
    
    public weak var router: ProjectsRouter?
    
    public var toolbar = ProjectsToolbar()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        toolbar.addButton.action = #selector(createNewProject)
        view().collectionView.dataSource = self
        view().collectionView.delegate = self
    }
    
    override public func loadView() {
        view = ProjectsView(frame: CGRect(origin: .zero,
                                          size: CGSize(width: 800, height: 400)))
    }
    
    func view() -> ProjectsView {
        view as! ProjectsView
    }
    
    @objc func createNewProject() {
        let document = VODesignDocument()
        
        show(document: document)
    }

    private func show(document: VODesignDocument) {
        router?.show(document: document)
        view.window?.close() // Projects window should hides when open a project
    }
    
    public static func fromStoryboard() -> ProjectsViewController {
        let storyboard = NSStoryboard(name: "Projects", bundle: .module)
        return storyboard.instantiateInitialController() as! ProjectsViewController
    }
}

extension ProjectsViewController: DragNDropDelegate {
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


extension ProjectsViewController : NSCollectionViewDataSource {
    public func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        documentController?.recentDocumentURLs.count ?? 0
    }
    
    public func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = ProjectCollectionViewItem()
        if let url = documentController?.recentDocumentURLs[indexPath.item] {
            item.configure(image: VODesignDocument.image(from: url), fileName: url.deletingPathExtension().lastPathComponent)
        }
        return item
    }
    
    public func numberOfSections(in collectionView: NSCollectionView) -> Int {
        1
    }
}

extension ProjectsViewController: NSCollectionViewDelegate {
    public func collectionView(_ collectionView: NSCollectionView,
                               didSelectItemsAt indexPaths: Set<IndexPath>) {
        for indexPath in indexPaths {
            if let url = documentController?.recentDocumentURLs[indexPath.item] {
                let document = VODesignDocument(file: url)
                show(document: document)
            }
        }
    }
}
