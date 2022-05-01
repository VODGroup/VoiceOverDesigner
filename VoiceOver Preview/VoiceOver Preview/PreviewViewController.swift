//
//  PreviewViewController.swift
//  VoiceOver Preview
//
//  Created by Mikhail Rubanov on 01.05.2022.
//

import UIKit
import Document

final class PreviewViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadAndDraw()
    }
    
    private func loadAndDraw() {
        do {
            let controls = try documentSaveService.loadControls()
            controls.forEach(drawingService.drawControl(from:))
        } catch let error {
            print(error)
        }
    }
    
    private lazy var drawingService = DrawingService(view: view)
    private lazy var documentSaveService: DocumentSaveService = {
        let url = Bundle.main.url(forResource: "A11yControls", withExtension: "json")!
        return DocumentSaveService(fileURL: url)
    }()
}

