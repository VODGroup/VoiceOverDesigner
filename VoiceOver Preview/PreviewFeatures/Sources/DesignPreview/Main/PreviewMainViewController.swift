import UIKit
import Document
import CanvasUIKit
import Canvas
import Combine

import SwiftUI
import ElementSettings
import Presentation

public class PreviewMainViewController: UIViewController {
    private var presenter: CanvasPresenter!
    
    public private(set) var document: VODesignDocument!
    public init(document: VODesignDocument) {
        self.document = document
        self.presenter = CanvasPresenter(document: document)
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        embedCanvas()
        subscribeToSelection()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        addDocumentStateObserving()
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        cancellables.forEach { cancellable in
            cancellable.cancel()
        }
        
        presenter.stopObserving()
        
        document.close()
    }
    
    public override var prefersStatusBarHidden: Bool {
        true // Often we present another screenshot with status bar in it, remove app's to remove overlap
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    private func subscribeToSelection() {
        presenter.selectedPublisher.sink { description in
            guard let description = description
            else { return }
            
            self.presentDetails(for: description)
        }.store(in: &cancellables)
    }
   
    private var sideTransition = SideTransition()
    
    private func presentDetails(for model: (any ArtboardElement)?) {
        guard let model = model
        else { return }
        
        self.presentDetails(for: model)
    }
    private func presentDetails(for model: any ArtboardElement) {
        if case .frame = model.cast {
            // No settings for Frame
            return 
        }
        
        let details = UIHostingController(rootView: makeView(for: model))
    
        // Side presentation for iPad
        if traitCollection.userInterfaceIdiom == .pad {
            details.modalPresentationStyle = .custom
            details.transitioningDelegate = sideTransition
        }
        
        self.present(details, animated: true)
    }
    
    @ViewBuilder
    private func makeView(for model: any ArtboardElement) -> some SwiftUI.View {
        let onDismiss = { [weak self] in
            guard let self = self else { return }
            self.presenter.deselect()
        }

        let deleteSelf = { [weak self] in
            guard let self = self else { return }
            self.presenter.remove(model)
        }

        switch model {
        case let description as A11yDescription:
            ElementSettingsEditorView(element: description, deleteSelf: deleteSelf)
                .onDisappear(perform: onDismiss)
        case let container as A11yContainer:
            ContainerSettingsEditorView(container: container, deleteSelf: deleteSelf)
                .onDisappear(perform: onDismiss)
        default:
            EmptyView()
        }
    }
    
    private func embedCanvas() {
        let shouldDisplayPreview = traitCollection.horizontalSizeClass == .compact
        let canvas = if shouldDisplayPreview {
            ScrollViewController.controller(presenter: presenter)
        } else {
            UIHostingController(rootView: PresentationView(
                document: .init(document)
            ))
        }
        addChild(canvas)
        view.addSubview(canvas.view)
        canvas.view.frame = view.frame // TODO: Constraints
        canvas.didMove(toParent: self)
        
        embedFullFrame(canvas)
    }
}

// MARK: - iCloud sync
extension PreviewMainViewController {
    private func addDocumentStateObserving() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(Self.documentStateChanged(_:)),
            name: UIDocument.stateChangedNotification, object: document)
    }
    
    @objc
    private func documentStateChanged(_ notification: Notification) {
        document.printState()
        
        if document.documentState == .progressAvailable {
            // TODO: Should show loading progress according to .progress property
        }
    }
}

public extension UIViewController {
    func embedFullFrame(_ viewController: UIViewController) {
        addChild(viewController)
        view.addSubview(viewController.view)
        if let subview = viewController.view {
            subview.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                subview.leftAnchor.constraint(equalTo: view.leftAnchor),
                subview.rightAnchor.constraint(equalTo: view.rightAnchor),
                subview.topAnchor.constraint(equalTo: view.topAnchor),
                subview.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }
        viewController.didMove(toParent: self)
    }
}
