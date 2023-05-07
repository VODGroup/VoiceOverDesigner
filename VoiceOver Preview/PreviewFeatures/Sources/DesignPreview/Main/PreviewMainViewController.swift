import UIKit
import Document
import CanvasUIKit
import Canvas
import Combine

import SwiftUI
import SettingsSwiftUI

public class PreviewMainViewController: UIViewController {
    private var presenter: CanvasPresenter!
    
    private var document: VODesignDocument!
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
        
        loadAndDraw()
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
    
    private var cancellables = Set<AnyCancellable>()
    private func loadAndDraw() {
        // TODO: Show loading?
        document.open { [weak self] isSuccess in
            if isSuccess {
                self?.embedCanvas()
                self?.subscribeToSelection()
            } else {
                fatalError() // TODO: Present something to user
            }
        }
    }
    
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
        // TODO: Add support for Container

        
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
<<<<<<< HEAD
        let onDismiss = { [weak self] in
            guard let self = self else { return }
            self.presenter.deselect()
        }
        
        let onDelete = { [weak self] in
            guard let self = self else { return }
            self.presenter.remove(model)
        }
        
        switch model {
        case let description as A11yDescription:
            ElementSettingsEditorView(element: description, delete: onDelete)
                .onDisappear(perform: onDismiss)
        case let container as A11yContainer:
            ContainerSettingsEditorView(container: container, delete: onDelete)
                .onDisappear(perform: onDismiss)
        default:
            EmptyView()
        }
        
        // TODO: Can't compile, strange
        fatalError()
//        let onDismiss = { [weak self] in
//            guard let self else { return }
//            self.presenter.deselect()
//        }
//
//        let onDelete = { [weak self] in
//            guard let self else { return }
//            self.presenter.remove(model)
//        }
//
//        switch model {
//        case let description as A11yDescription:
//            ElementSettingsEditorView(element: description, delete: onDelete)
//                .onDisappear(perform: onDismiss)
//        case let container as A11yContainer:
//            ContainerSettingsEditorView(container: container, delete: onDelete)
//                .onDisappear(perform: onDismiss)
//        default:
//            EmptyView()
//        }
    }
    
    private func embedCanvas() {
        let canvas = ScrollViewController.controller(presenter: presenter)
        
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
            loadAndDraw()
        }
    }
}

public extension UIViewController {
    func embedFullFrame(_ viewController: UIViewController) {
        addChild(viewController)
        view.addSubview(viewController.view)
        viewController.didMove(toParent: self)
        
        if let subiew = viewController.view {
            subiew.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                subiew.leftAnchor.constraint(equalTo: view.leftAnchor),
                subiew.rightAnchor.constraint(equalTo: view.rightAnchor),
                subiew.topAnchor.constraint(equalTo: view.topAnchor),
                subiew.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }
    }
}
