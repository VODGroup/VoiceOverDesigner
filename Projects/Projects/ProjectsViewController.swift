//
//  ProjectsViewController.swift
//  VoiceOver Designer
//
//  Created by Mikhail Rubanov on 05.05.2022.
//

import AppKit
import Document

public protocol ProjectsRouter: AnyObject {
    func show(with image: NSImage) -> Void
}

public class ProjectsViewController: NSViewController {
    
    public weak var router: ProjectsRouter?
    
    @IBAction func selectMenu(_ sender: Any) {
        router?.show(with: NSImage(named: "Sample_menu")!)
    }
    
    @IBAction func selectProductCard(_ sender: Any) {
        router?.show(with: NSImage(named: "Sample_product")!)
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
    func didDrag(image: NSImage) {
        router?.show(with: image)
    }
}


