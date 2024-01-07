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

    func documentBrowser(_ controller: UIDocumentBrowserViewController, didPickDocumentURLs documentURLs: [URL]) {
        guard let sourceURL = documentURLs.first else { return }
        
        // When the user has chosen an existing document, a new `DocumentViewController` is presented for the first document that was picked.
        presentDocumentModally(url: sourceURL, animated: true)
    }
    
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
            
            let viewController = self.controllerToPresent(controller: documentViewController)
            self.transitionController?.targetView = viewController.view // Children provides better animation than navigation itself, don'n know why
            viewController.transitioningDelegate = self
            
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
    
    // MARK: State Preservation and Restoration
//    // This key is used to encode the bookmark data of the URL of the opened document as part of the state restoration data.
//    static let bookmarkDataKey = "bookmarkData"
//    override func encodeRestorableState(with coder: NSCoder) {
//        
//        // The system will call this method on the view controller when the application state needs to be preserved.
//        // Encode relevant information using the coder instance, that is provided.
//        
//        defer {
//            super.encodeRestorableState(with: coder)
//        }
//        
//        guard
//            let documentViewController = presentedViewController as? DocumentViewController,
//            let documentURL = documentViewController.document?.fileURL
//        else {
//            return
//        }
//        
//        do {
//            // Obtain the bookmark data of the URL of the document that is currently presented, if there is any.
//            
//            let bookmarkData = try documentURL.accessSecurityScopedResource(URL.bookmarkData)
//            
//            // Encode it with the coder.
//            coder.encode(bookmarkData, forKey: DocumentBrowserViewController.bookmarkDataKey)
//            
//        } catch {
//            // Make sure to handle the failure appropriately, e.g., by showing an alert to the user
//            os_log("Failed to get bookmark data from URL %@: %@", log: OSLog.default, type: .error, documentURL as CVarArg, error as CVarArg)
//        }
//    }
//    
//    override func decodeRestorableState(with coder: NSCoder) {
//        
//        // This method is called when the system attempts to restore application state.
//        // Try decoding the bookmark data, obtain a URL instance from it, and present the document.
//        if let bookmarkData = coder.decodeObject(forKey: DocumentBrowserViewController.bookmarkDataKey) as? Data {
//            do {
//                var bookmarkDataIsStale: Bool = false
//                let documentURL = try URL(resolvingBookmarkData: bookmarkData, bookmarkDataIsStale: &bookmarkDataIsStale) {
//                presentDocument(at: documentURL, animated: false)
//            } catch {
//                // Make sure to handle the failure appropriately, e.g., by showing an alert to the user
//                os_log("Failed to create document URL from bookmark data: %@, error: %@",
//                       log: OSLog.default, type: .error, bookmarkData as CVarArg, error as CVarArg)
//            }
//        }
//        super.decodeRestorableState(with: coder)
//    }
}
