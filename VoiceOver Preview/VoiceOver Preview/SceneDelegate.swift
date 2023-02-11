//
//  SceneDelegate.swift
//  VoiceOver Preview
//
//  Created by Mikhail Rubanov on 01.05.2022.
//

import UIKit
import DesignPreview

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        showDocumentBrowserAsRoot()
        
        window.makeKeyAndVisible()
        
        if let url = connectionOptions.urlContexts.first?.url {
            presentDocumentModally(url: url)
        }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        
        presentDocumentModally(url: url)
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        guard let documentURL = userActivity.userInfo?[UIDocument.userActivityURLKey] as? URL else {
            print("Don't want to restore any document, no url")
            return
        }
        
        print("will restore document \(documentURL)")
        presentDocumentModally(url: documentURL)
    }
}

import Document
extension SceneDelegate: UIDocumentBrowserViewControllerDelegate {
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didPickDocumentsAt documentURLs: [URL]) {
        guard let url = documentURLs.first else { return }
        
        presentDocumentModally(url: url)
    }
}

// MARK: Navigation
extension SceneDelegate {
    func presentDocumentModally(url: URL) {
        closePresentedDocument()
        
        let document = VODesignDocument(fileURL: url)
        let controller = PreviewMainViewController(document: document)
        controller.title = url.lastPathComponent
        
//        let navController = UINavigationController(rootViewController: controller)
//        navController.modalPresentationStyle = .overFullScreen
//        
//        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(
//            title: NSLocalizedString("Close document", comment: ""),
//            style: .done,
//            target: self, action: #selector(closePresentedDocument))
        
        window?.rootViewController?.present(controller, animated: true)
    }
    
    @objc private func closePresentedDocument() {
        window?
            .rootViewController?
            .presentedViewController?
            .dismiss(animated: true)
    }
    
    private func showDocumentBrowserAsRoot() {
        let documentBrowser = UIDocumentBrowserViewController()
        documentBrowser.allowsPickingMultipleItems = false
        documentBrowser.allowsDocumentCreation = false
        documentBrowser.delegate = self
        
        window?.rootViewController = documentBrowser
    }
}
