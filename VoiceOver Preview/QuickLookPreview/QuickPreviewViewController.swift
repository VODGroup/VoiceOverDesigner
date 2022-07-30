//
//  PreviewViewController.swift
//  QuickLook
//
//  Created by Mikhail Rubanov on 30.07.2022.
//

import UIKit
import QuickLook

import Document
import UIKitPreview

class QuickPreviewViewController: UIViewController, QLPreviewingController {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    /*
     * Implement this method and set QLSupportsSearchableItems to YES in the Info.plist of the extension if you support CoreSpotlight.
     *
    func preparePreviewOfSearchableItem(identifier: String, queryString: String?, completionHandler handler: @escaping (Error?) -> Void) {
        // Perform any setup necessary in order to prepare the view.
        
        // Call the completion handler so Quick Look knows that the preview is fully loaded.
        // Quick Look will display a loading spinner while the completion handler is not called.
        handler(nil)
    }
    */
    

    func preparePreviewOfFile(at url: URL, completionHandler handler: @escaping (Error?) -> Void) {
        
        let document = VODesignDocument(fileURL: url)
        let preview = VODesignPreviewViewController.controller(for: document)
        
        addChild(preview)
        view.addSubview(preview.view)
        preview.didMove(toParent: self)
        
        if let previewView = preview.view {
            previewView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                previewView.leftAnchor.constraint(equalTo: view.leftAnchor),
                previewView.rightAnchor.constraint(equalTo: view.rightAnchor),
                previewView.topAnchor.constraint(equalTo: view.topAnchor),
                previewView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }
        
        // Call the completion handler so Quick Look knows that the preview is fully loaded.
        // Quick Look will display a loading spinner while the completion handler is not called.
        handler(nil)
    }

}
