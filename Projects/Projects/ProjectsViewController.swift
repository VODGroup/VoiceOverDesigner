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
    
    var recentProjectsPaths: [String] = UserDefaults.standard.array(forKey: "recentProjectsPaths") as? [String] ?? []
    
    public weak var router: ProjectsRouter?
    
    public var toolbar = ProjectsToolbar()
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        toolbar.addButton.action = #selector(createNewProject)
        view().collectionView.dataSource = self
        view().collectionView.delegate = self
        
        DispatchQueue.main.async(execute: {
            // Don't know why but configuring collectionView doesn't work, as it can't access document to retrieve image
            self.view().collectionView.reloadData()
        })
        updateRecentPaths()
    }
    
    override public func loadView() {
        view = ProjectsView(frame: CGRect(origin: .zero, size: CGSize(width: 800, height: 400)))
    }
    
    func view() -> ProjectsView {
        view as! ProjectsView
    }
    
    @objc func createNewProject() {
        let document = VODesignDocument()
        router?.show(document: document)
        
    }
    
    func updateRecentPaths() {
        recentProjectsPaths = (UserDefaults.standard.array(forKey: "recentProjectsPaths") as? [String] ?? []).filter({
            FileManager.default.fileExists(atPath: $0)
        })
        UserDefaults.standard.set(recentProjectsPaths, forKey: "recentProjectsPaths")
        view().collectionView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute: { [weak self] in
            self?.updateRecentPaths()
        })
    }
    
    public static func fromStoryboard() -> ProjectsViewController {
        let storyboard = NSStoryboard(name: "Projects", bundle: Bundle(for: ProjectsViewController.self))
        return storyboard.instantiateInitialController() as! ProjectsViewController
    }
}

extension ProjectsViewController: DragNDropDelegate {
    public func didDrag(path: URL) {
        let document = VODesignDocument(fileName: path.lastPathComponent, rootPath: path.deletingLastPathComponent())
        router?.show(document: document)
    }
    
    public func didDrag(image: NSImage) {
        show(image: image)
    }
    
    func show(image: NSImage) {
        let document = VODesignDocument(image: image)
        router?.show(document: document)
    }
}


extension ProjectsViewController : NSCollectionViewDataSource {
    public func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        recentProjectsPaths.count
    }
    
    public func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = ProjectCollectionViewItem()
        let path = recentProjectsPaths[indexPath.item]
        if let url = URL(string: "file://\(path)") {
            item.configure(image: VODesignDocument.image(from: url), fileName: url.deletingPathExtension().lastPathComponent)
        }
        
        return item
    }
    
    public func numberOfSections(in collectionView: NSCollectionView) -> Int {
        1
    }
    
    
}

extension ProjectsViewController: NSCollectionViewDelegate {
    public func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        for indexPath in indexPaths {
            let path = recentProjectsPaths[indexPath.item]
            let url = URL(string: "file://\(path)")
            let document = VODesignDocument(file: url!)
            router?.show(document: document)
        }
    }
}
