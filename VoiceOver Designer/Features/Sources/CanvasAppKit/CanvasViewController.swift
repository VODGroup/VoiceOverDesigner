//
//  ViewController.swift
//  VoiceOver Designer
//
//  Created by Mikhail Rubanov on 30.04.2022.
//

import Cocoa
import Document
import CommonUI
import Canvas
import Combine
import AppKit

public class CanvasViewController: NSViewController {
    
    public func inject(presenter: CanvasPresenter) {
        self.presenter = presenter
    }
    
    public var presenter: CanvasPresenter!
    private var cancellables: Set<AnyCancellable> = []
    private let pointerService = PointerService()
    
    var trackingArea: NSTrackingArea!
    var duplicateItem: NSMenuItem?

    public lazy var canvasMenu: NSMenuItem = {
        makeCanvasMenu()
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view().dragnDropView.delegate = self
        
        view().addImageButton.action = #selector(addImageButtonTapped)
        view().addImageButton.target = self
        
        view.window?.delegate = self
        
        presenter.didLoad(
            ui: self.view().controlsView,
            initialScale: 1, // Will be scaled by scrollView
            previewSource: self.view()
            // TODO: Scale Preview also by UIScrollView?
        )
        
        setImage()
        addMouseTracking()
    }
    
    public override func viewDidAppear() {
        super.viewDidAppear()
        
        presenter.subscribeOnControlChanges()
        observe()
    }
    
    public override func viewWillDisappear() {
        super.viewWillDisappear()
                
        presenter.stopObserving()
        stopPointerObserving()
    }
    
    private func addMouseTracking() {
        trackingArea = NSTrackingArea(
            rect: view.bounds,
            options: [.activeAlways,
                      .mouseMoved,
                      .mouseEnteredAndExited,
                      .inVisibleRect],
            owner: self,
            userInfo: nil)
        view.addTrackingArea(trackingArea)
    }
    
    private func observe() {
        presenter.selectedPublisher
            .sink { [weak self] view in self?.duplicateItem?.isEnabled = view != nil }
            .store(in: &cancellables)
        presenter
            .pointerPublisher
            .removeDuplicates()
            .sink(receiveValue: pointerService.updateCursor(_:))
            .store(in: &cancellables)
    }
    
    private func stopPointerObserving() {
        cancellables.forEach { cancellable in
            cancellable.cancel()
        }
    }
    
    func setImage() {
        view().setImage(presenter.document.image)
    }
    
    public override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    var highlightedControl: A11yControlLayer?
    
    public override func mouseMoved(with event: NSEvent) {
        highlightedControl?.isHiglighted = false
        highlightedControl = nil
        presenter.mouseMoved(on: location(from: event))
        
        // TODO: Can crash if happend before document loading
        guard let control = presenter.ui.control(at: location(from: event)) else {
            return
        }
        
        self.highlightedControl = control
        
        control.isHiglighted = true
    }
    
    func location(from event: NSEvent) -> CGPoint {
        let inWindow = event.locationInWindow
        let inView = view().contentView
            .convert(inWindow, from: nil)
//            .flippendVertical(in: view().contentView) // It's already flipped by contentView
        
        return inView
    }
    
    
    // MARK:
    public override func mouseDown(with event: NSEvent) {
        presenter.mouseDown(on: location(from: event))
    }
    
    public override func mouseDragged(with event: NSEvent) {
        presenter.mouseDragged(on: location(from: event))
    }
    
    public override func mouseUp(with event: NSEvent) {
        presenter.mouseUp(on: location(from: event))
    }
    
    func view() -> CanvasView {
        view as! CanvasView
    }
    
    public static func fromStoryboard() -> CanvasViewController {
        let storyboard = NSStoryboard(name: "Canvas", bundle: .module)
        return storyboard.instantiateInitialController() as! CanvasViewController
    }
    
    public func select(_ model: A11yDescription) {
        guard let control = view().controlsView.drawnControls
            .first(where: { control in
                control.model === model
            })
        else { return }
        
        presenter.select(control: control)
    }
    
    public func publishControlChanges() {
        presenter.publishControlChanges()
    }
    
    public func delete(model: any AccessibilityView) {
        presenter.remove(model)
    }
    
    @objc func addImageButtonTapped() {
        Task {
            if let image = await requestImage() {
                presentImage(image)
            }
        }
    }

    @objc func duplicateMenuSelected() {
        if let selectedControl = presenter.selectedControl?.model {
            let newModel = selectedControl.copy()
            newModel.frame = newModel.frame.offsetBy(dx: 40, dy: 40)
            presenter.add(newModel)
        }
    }

    func requestImage() async -> NSImage? {
        guard let window = view.window else { return nil }
        let imagePanel = NSOpenPanel()
        imagePanel.allowedFileTypes = NSImage.imageTypes
        imagePanel.canChooseFiles = true
        imagePanel.canChooseDirectories = false
        imagePanel.allowsMultipleSelection = false
        let modalResponse = await imagePanel.beginSheetModal(for: window)
        guard modalResponse == .OK else { return nil }
        guard let url = imagePanel.url, let image = NSImage(contentsOf: url) else { return nil }
        return image
    }
    
    func presentImage(_ image: NSImage) {
        presenter.update(image: image)
        view().setImage(image)
        presenter.publishControlChanges()
    }
}

extension CanvasViewController {
    public func image(
        for model: any AccessibilityView
    ) async -> CGImage? {
        guard let control = view().control(for: model)
        else { return nil }
        
        return await view().image(at: control.frame)
    }
}

// MARK: - Magnifiing
extension CanvasViewController {
    
    var zoomStep: CGFloat {
        1.33
    }
    
    @IBAction func reduceMagnifing(sender: Any) {
        view().changeMagnifacation { current in
            current / zoomStep
        }
    }
    
    @IBAction func increaseMagnifing(sender: Any) {
        view().changeMagnifacation { current in
            current * zoomStep
        }
    }
    
    @IBAction func fitMagnifing(sender: Any) {
        view().fitToWindow(animated: true)
    }
}

extension CanvasViewController: NSWindowDelegate {
    public func windowDidResize(_ notification: Notification) {
        view().fitToWindowIfAlreadyFitted()
    }
}

extension CanvasViewController: DragNDropDelegate {
    public func didDrag(image: NSImage) {
        presenter.update(image: image)
        view().setImage(image)
        presenter.publishControlChanges()
    }
    
    public func didDrag(path: URL) {
        // TODO: Add support. Or decline this files
    }
}

extension NSEvent {
    var locationInWindowFlipped: CGPoint {
        return CGPoint(x: locationInWindow.x,
                       y: window!.frame.height
                       - locationInWindow.y
                       - 28 // TODO: Remove toolbar's height
        )
    }
}

extension CGPoint {
    func flippendVertical(in view: NSView) -> CGPoint {
        CGPoint(x: x,
                y: view.frame.height - y
        )
    }
}
