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
    
    var duplicateItem: NSMenuItem?

    public lazy var canvasMenu: NSMenuItem = {
        makeCanvasMenu()
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view().dragnDropView.delegate = self
        
        view.window?.delegate = self
        
        presenter.didLoad(uiContent: view().contentView,
                          uiScroll: view(),
                          initialScale: 1,
                          previewSource: view())
        
        addMouseTracking()
        addMenuItem()
        view().isEmpty = presenter.document.artboard.isEmpty
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
    
    var trackingArea: NSTrackingArea!
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
        
        presenter
            .artboardPublisher
            .map { !$0.isEmpty }
            .removeDuplicates()
            .sink(receiveValue: view().updateDragnDropVisibility(hasDrawnControls:))
            .store(in: &cancellables)
    }
    

    private func stopPointerObserving() {
        cancellables.forEach { cancellable in
            cancellable.cancel()
        }
    }
    
    // TODO: try to extract?
    func addMenuItem() {
        guard let menu = NSApplication.shared.menu, menu.item(withTitle: "Canvas") == nil else { return }
        let canvasMenuItem = NSMenuItem(title: "Canvas", action: nil, keyEquivalent: "")
        let canvasSubMenu = NSMenu(title: "Canvas")
        let addImageItem = NSMenuItem(title: "Add image", action: #selector(addImageButtonTapped), keyEquivalent: "")
        canvasSubMenu.addItem(addImageItem)
        canvasMenuItem.submenu = canvasSubMenu
        menu.addItem(canvasMenuItem)
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
        guard let control = presenter
            .uiContent
            .control(at: location(from: event)) else {
            return
        }
        
        self.highlightedControl = control
        
        control.isHiglighted = true
    }
    
    func location(from event: NSEvent) -> CGPoint {
        event.location(in: view().contentView)
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
        presenter.select(model)
    }
    
    public func publishControlChanges() {
        presenter.publishControlChanges()
    }
    
    public func delete(model: any ArtboardElement) {
        presenter.remove(model)
    }
    
    @objc func addImageButtonTapped() {
        Task {
            if let path = await requestImage(),
               let image = NSImage(contentsOf: path) {
                presenter.add(image: image)
            }
        }
    }

    @objc func duplicateMenuSelected() {
        if let selectedControl = presenter.selectedControl?.model {
            let newModel = selectedControl.copy()
            newModel.frame = newModel.frame.offsetBy(dx: 40, dy: 40)
            presenter.append(control: newModel)
        }
    }

    func requestImage() async -> URL? {
        guard let window = view.window else { return nil }
        let imagePanel = NSOpenPanel()
        imagePanel.allowedFileTypes = NSImage.imageTypes
        imagePanel.canChooseFiles = true
        imagePanel.canChooseDirectories = false
        imagePanel.allowsMultipleSelection = false
        let modalResponse = await imagePanel.beginSheetModal(for: window)
        guard modalResponse == .OK else { return nil }
        return imagePanel.url
    }
}

extension CanvasViewController {
    public func image(
        for model: any ArtboardElement
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
    public func didDrag(image: NSImage, locationInWindow: CGPoint) {
        let locationInCanvas = view().contentView.convert(locationInWindow, from: nil)
        let shouldAnimate = presenter.document.artboard.frames.count != 0
        presenter.add(image: image, origin: locationInCanvas)
        view().fitToWindow(animated: shouldAnimate)
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

extension NSCursor {
    static func resizing(for corner: RectCorner) -> NSCursor {
        // There's no system resizing images so takes from WebKit
        // see or should take custom image/private cursor: https://stackoverflow.com/questions/49297201/diagonal-resizing-mouse-pointer
        let image: NSImage = resizingImage(for: corner)
        
        return NSCursor(image: image, hotSpot: NSPoint(x: 8, y: 8))
    }
                        
    private static func resizingImage(for corner: RectCorner) -> NSImage {
        switch corner {
        case .topLeft, .bottomRight:
            return NSImage(byReferencingFile: "/System/Library/Frameworks/WebKit.framework/Versions/Current/Frameworks/WebCore.framework/Resources/northWestSouthEastResizeCursor.png")!
            
        case .topRight, .bottomLeft:
            return NSImage(byReferencingFile: "/System/Library/Frameworks/WebKit.framework/Versions/Current/Frameworks/WebCore.framework/Resources/northEastSouthWestResizeCursor.png")!
        }
    }
}

extension NSEvent {
    func location(in view: NSView) -> CGPoint {
        view.convert(locationInWindow, from: nil)
    }
}
