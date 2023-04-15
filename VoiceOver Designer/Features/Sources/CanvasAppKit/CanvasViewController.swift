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

public class CanvasViewController: NSViewController {
    
    public func inject(presenter: CanvasPresenter) {
        self.presenter = presenter
    }
    
    public var presenter: CanvasPresenter!
    private var cancellables: Set<AnyCancellable> = []
    
    var trackingArea: NSTrackingArea!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view().dragnDropView.delegate = self
    }
    
    public override func viewWillDisappear() {
        super.viewWillDisappear()
        
        cancellables.forEach { cancellable in
            cancellable.cancel()
        }
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
        presenter
            .pointerPublisher
            .removeDuplicates()
            .sink(receiveValue: updateCursor)
            .store(in: &cancellables)
    }
    
    private func updateCursor(_ value: DrawingController.Pointer?) {
        NSCursor.current.pop()
        guard let value else { return NSCursor.arrow.push() }
        switch value {
        case .dragging:
            NSCursor.closedHand.push()
        case .hover:
            NSCursor.openHand.push()
        case .resize(let corner):
            NSCursor.resizing(for: corner).push()
        case .crosshair:
            NSCursor.crosshair.push()
        case .copy:
            NSCursor.dragCopy.push()
        }
    }
    
    public override func viewDidAppear() {
        super.viewDidAppear()
        view().addImageButton.action = #selector(addImageButtonTapped)
        view().addImageButton.target = self
        
        view.window?.delegate = self
        DispatchQueue.main.async {
            self.presenter.didLoad(
                uiContent: self.view().contentView,
                uiScroll: self.view(),
                initialScale: 1, // Will be scaled by scrollView
                previewSource: self.view()
                // TODO: Scale Preview also by UIScrollView?
            )
            
            self.addMouseTracking()
            self.addMenuItem()
            self.observe()
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
        guard let control = view()
            .contentView.drawnControls
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
                presenter.add(image: image)
            }
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
        presenter.add(image: image)
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
