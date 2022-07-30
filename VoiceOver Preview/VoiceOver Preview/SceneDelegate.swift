//
//  SceneDelegate.swift
//  VoiceOver Preview
//
//  Created by Mikhail Rubanov on 01.05.2022.
//

import UIKit
import UIKitPreview

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        if let url = connectionOptions.urlContexts.first?.url {
            makeDocumentRoot(url: url)
        } else {
            showDocumentBrowserAsRoot()
        }
        
        window.makeKeyAndVisible()
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        
        makeDocumentRoot(url: url)
    }
}

import Document
extension SceneDelegate: UIDocumentBrowserViewControllerDelegate {
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didPickDocumentsAt documentURLs: [URL]) {
        guard let url = documentURLs.first else {
            return
        }
        
        makeDocumentRoot(url: url)
    }
}

// MARK: Navigation
extension SceneDelegate {
    func makeDocumentRoot(url: URL) {
        let document = VODesignDocument(fileURL: url)
        window?.rootViewController = VODesignPreviewViewController.controller(for: document)
    }
    
    private func showDocumentBrowserAsRoot() {
        let documentBrowser = UIDocumentBrowserViewController()
        documentBrowser.allowsPickingMultipleItems = false
        documentBrowser.allowsDocumentCreation = false
        documentBrowser.delegate = self
        
        window?.rootViewController = documentBrowser
    }
}
