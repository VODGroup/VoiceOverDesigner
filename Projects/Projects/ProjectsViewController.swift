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
    
    public weak var router: ProjectsRouter?
    
    @IBAction func selectMenu(_ sender: Any) {
        show(image: NSImage(named: "Sample_menu")!)
    }
    
    @IBAction func selectProductCard(_ sender: Any) {
        show(image: NSImage(named: "Sample_product")!)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view().delegate = self
    }
    
    func view() -> ProjectsView {
        view as! ProjectsView
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


