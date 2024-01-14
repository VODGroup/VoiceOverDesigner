// Copied from great example at https://github.com/danielctull-playground/BuildingAnAppBasedOnTheDocumentBrowserViewController

import UIKit
import os.log
import DesignPreview
import Document


class DocumentBrowserViewController: UIDocumentBrowserViewController, UIDocumentBrowserViewControllerDelegate, UIViewControllerTransitioningDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // The `UIDocumentBrowserViewController` needs a delegate that is notified about the user's interaction with their files.
        // In this case, the view controller itself is assigned as its delegate.
        delegate = self
        
        // Since the application allows creating Particles documents, document creation is enabled on the `UIDocumentBrowserViewController`.
        allowsDocumentCreation = false
        
        // In this application, selecting multiple items is not supported. Instead, only one document at a time can be opened.
        allowsPickingMultipleItems = false
    }
    
    // MARK: UIDocumentBrowserViewControllerDelegate
#if os(visionOS)
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didPickDocumentsAt documentURLs: [URL]) {
        guard let sourceURL = documentURLs.first else { return }
        
        // When the user has chosen an existing document, a new `DocumentViewController` is presented for the first document that was picked.
        presentDocumentModally(url: sourceURL, animated: true)
    }
#else
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didPickDocumentURLs documentURLs: [URL]) {
        guard let sourceURL = documentURLs.first else { return }
        
        // When the user has chosen an existing document, a new `DocumentViewController` is presented for the first document that was picked.
        presentDocumentModally(url: sourceURL, animated: true)
    }
#endif

    func documentBrowser(_ controller: UIDocumentBrowserViewController, didImportDocumentAt sourceURL: URL, toDestinationURL destinationURL: URL) {
        
        // When a new document has been imported by the `UIDocumentBrowserViewController`, a new `DocumentViewController` is presented as well.
        presentDocumentModally(url: destinationURL, animated: true)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, failedToImportDocumentAt documentURL: URL, error: Error?) {
        // Make sure to handle the failed import appropriately, e.g., by presenting an error message to the user.
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, applicationActivitiesForDocumentURLs documentURLs: [URL]) -> [UIActivity] {
        // Whenever one or more items are being shared by the user, the default activities of the `UIDocumentBrowserViewController` can be augmented
        // with custom ones. In this case, no additional activities are added.
        return []
    }
    
    // MARK: UIViewControllerTransitioningDelegate
    
    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        // Since the `UIDocumentBrowserViewController` has been set up to be the transitioning delegate of `DocumentViewController` instances (see
        // implementation of `presentDocument(at:)`), it is being asked for a transition controller.
        // Therefore, return the transition controller, that previously was obtained from the `UIDocumentBrowserViewController` when a
        // `DocumentViewController` instance was presented.
        return transitionController
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        // The same zoom transition is needed when closing documents and returning to the `UIDocumentBrowserViewController`, which is why the the
        // existing transition controller is returned here as well.
        return transitionController
    }
    
    // MARK: Document Presentation
    
    var transitionController: UIDocumentBrowserTransitionController?

    var currentDocument: URL? {
        didSet {
            if userActivity == nil {
                userActivity = NSUserActivity(activityType: "DocumentRestoration")
            }
            
            _ = currentDocument?.startAccessingSecurityScopedResource()
            userActivity!.userInfo![UIDocument.userActivityURLKey] = try? currentDocument?.bookmarkData()
            currentDocument?.stopAccessingSecurityScopedResource()
        }
    }
    
    func presentDocumentModally(url: URL, animated: Bool) {
        closePresentedDocument()
        currentDocument = url // Set after closing previous
        
        let document = VODesignDocument(fileURL: url)
        let documentViewController = PreviewMainViewController(document: document)
        documentViewController.title = url.lastPathComponent
        documentViewController.transitioningDelegate = self
        transitionController = transitionController(forDocumentAt: url)
        transitionController?.loadingProgress = Progress(totalUnitCount: 1)
        
        document.open { isSuccess in
            self.transitionController?.loadingProgress?.completedUnitCount = 1
            self.transitionController?.targetView = documentViewController.view // Children provides better animation than navigation itself, don'n know why
            
            let viewController = self.controllerToPresent(controller: documentViewController)
            viewController.transitioningDelegate = self
#if !os(visionOS)
            viewController.hidesBarsOnSwipe = true
            viewController.setNavigationBarHidden(true, animated: false)
#endif
            if UIDevice.current.userInterfaceIdiom == .phone {
                // iPad and iPhone have different settings for best behaviour.
                // Otherwise it will be completely broken (checked on iOS 17)
                // The strange thing that sizeClass won't help, it's device difference
                viewController.navigationBar.isTranslucent = false
            }
            
            self.present(viewController, animated: animated)
        }
    }
    
    private func controllerToPresent(controller: UIViewController) -> UINavigationController {
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: NSLocalizedString("Close", comment: ""),
            style: .done,
            target: self, action: #selector(closePresentedDocument))
        
        let navController = UINavigationController(rootViewController: controller)
        // Document's transition can't be interactive, that why we close screen by separate button
        navController.modalPresentationStyle = .overFullScreen
        navController.modalPresentationCapturesStatusBarAppearance = true
        return navController
    }
    
    @objc private func closePresentedDocument() {
        guard let presentedController = presentedViewController?.children.first as? PreviewMainViewController
        else { return }
        
        presentedController.document.close { _ in
            self.currentDocument = nil
            presentedController.dismiss(animated: true)
        }
    }
}
