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
    let documentBrowser = DocumentBrowserViewController()
    
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = documentBrowser
        window.makeKeyAndVisible()
        self.window = window
        
        if let url = connectionOptions.urlContexts.first?.url {
            documentBrowser.presentDocumentModally(url: url, animated: true)
        }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        
        documentBrowser.presentDocumentModally(url: url, animated: true)
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        guard let documentURL = userActivity.userInfo?[UIDocument.userActivityURLKey] as? URL else {
            print("Don't want to restore any document, no url")
            return
        }
        
        print("will restore document \(documentURL)")
        documentBrowser.presentDocumentModally(url: documentURL, animated: false)
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
        documentBrowser.presentDocumentModally(url: documentURL, animated: false)
    }
    
    func stateRestorationActivity(for scene: UIScene) -> NSUserActivity? {
        print("Will save document for restoration")
        return documentBrowser.userActivity
    }
}
