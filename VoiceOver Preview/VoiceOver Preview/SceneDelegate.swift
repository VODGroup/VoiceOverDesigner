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
    
    func scene(_ scene: UIScene, restoreInteractionStateWith stateRestorationActivity: NSUserActivity) {
        print("Will restore user activity")
        var isStale = false
        guard let bookmarkData = stateRestorationActivity.userInfo?[UIDocument.userActivityURLKey] as? Data,
              let documentURL = try? URL(resolvingBookmarkData: bookmarkData, bookmarkDataIsStale: &isStale),
              !isStale // Bookmark was fresh
        else {
            print("Don't want to restore any document, no url")
            return
        }
        
        print("Will restore document \(documentURL)")
        presentDocumentModally(url: documentURL)
    }
    
    func stateRestorationActivity(for scene: UIScene) -> NSUserActivity? {
        guard let currentDocument else {
            print("No current document")
            return nil
        }
        
        print("Save user activity")
        let userActivity = NSUserActivity(activityType: "DocumentRestoration")
        userActivity.userInfo?[UIDocument.userActivityURLKey] = try! currentDocument.bookmarkData()
        return userActivity
    }
    
    var currentDocument: URL?
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
        currentDocument = url // Set after closing previous
        
        let document = VODesignDocument(fileURL: url)
        let controller = PreviewMainViewController(document: document)
        controller.title = url.lastPathComponent
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            window?.rootViewController?.present(controller, animated: true)
        } else {
            controller.navigationItem.leftBarButtonItem = UIBarButtonItem(
                title: NSLocalizedString("Close", comment: ""),
                style: .done,
                target: self, action: #selector(closePresentedDocument))
            
            
            let navController = UINavigationController(rootViewController: controller)
            navController.modalPresentationStyle = .overFullScreen
            
            window?.rootViewController?.present(navController, animated: true)
        }
    }
    
    @objc private func closePresentedDocument() {
        guard let presentedController = window?
            .rootViewController?
            .presentedViewController
        else { return }
        
        presentedController.dismiss(animated: true)
        currentDocument = nil
    }
    
    private func showDocumentBrowserAsRoot() {
        let documentBrowser = UIDocumentBrowserViewController()
        documentBrowser.allowsPickingMultipleItems = false
        documentBrowser.allowsDocumentCreation = false
        documentBrowser.delegate = self
        
        window?.rootViewController = documentBrowser
    }
}
