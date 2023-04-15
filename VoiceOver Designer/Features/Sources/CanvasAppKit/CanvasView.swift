//
//  CanvasView.swift
//  Canvas
//
//  Created by Mikhail Rubanov on 22.05.2022.
//

import AppKit

import CommonUI
import Document
import Canvas

class ControlsView: FlippedView, DrawingView {
    var drawnControls: [A11yControlLayer] = []
    
    lazy var alignmentOverlay = AlignmentOverlayFactory().overlay(for: self)
    
    var copyListener = CopyModifierFactory().make()

    var hud = HUDLayer()
    
    override func layout() {
        super.layout()
        
        hud.frame = bounds
    }
}

class CanvasView: FlippedView {
    
    @IBOutlet weak var scrollView: CanvasScrollView!
    
    @IBOutlet weak var clipView: NSClipView!
    
    @IBOutlet weak var contentView: ContentView!
    @IBOutlet weak var addImageButton: NSButton!
   
    @IBOutlet weak var dragnDropView: DragNDropImageView!
    
    @IBOutlet weak var zoomOutButton: NSButton!
    @IBOutlet weak var zoomToFitButton: NSButton!
    @IBOutlet weak var zoomInButton: NSButton!
    
    @IBOutlet weak var footer: NSView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        scrollView.verticalScrollElasticity = .none
        scrollView.horizontalScrollElasticity = .none
        scrollView.hud = contentView.hud
        contentView.wantsLayer = true
        contentView.addHUD()
        
        zoomOutButton.toolTip = "⌘-"
        zoomToFitButton.toolTip = "0"
        zoomInButton.toolTip = "⌘+"
        footer.wantsLayer = true
        footer.layer?.backgroundColor = NSColor.quaternaryLabelColor.cgColor
        footer.isHidden = false
        
        dragnDropView.isHidden = true
        addImageButton.isHidden = true
        
        clipView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // MARK: - Magnification
    func fitToWindowIfAlreadyFitted() {
        if isImageMagnificationFitsToWindow {
            fitToWindow(animated: false)
        }
    }
    
    func changeMagnifacation(_ change: (_ current: CGFloat) -> CGFloat) {
        let current = scrollView.magnification
        let changed = change(current)
        setMagnification(to: changed, animated: false)
    }
    
    private func setMagnification(to magnification: CGFloat, animated: Bool) {
        // Manually trim to keep value in sync with real limitation
        let newLevel = (scrollView.minMagnification...scrollView.maxMagnification).trim(magnification)
        
        var scrollView = self.scrollView
        if animated {
            scrollView = self.scrollView.animator()
            
            self.scrollView.updateHud(to: newLevel) // Animator calls another function
        }
        
        scrollView?.setMagnification(
            newLevel,
            centeredAt: contentView.hud.selectedControlFrame?.center ?? contentView.frame.center)
    }
    
    private var isImageMagnificationFitsToWindow: Bool {
        if let fitingMagnification {
            return abs(fitingMagnification - scrollView.magnification) < 0.01
        } else {
            return false
        }
    }
    
    private var fitingMagnification: CGFloat? {
        let contentSize = contentView.intrinsicContentSize
        
        // TODO: Check width
        let scrollViewVisibleHeight = scrollView.frame.height
        return scrollViewVisibleHeight / contentSize.height
    }
    
    // MARK: - Image
    func image(at frame: CGRect) async -> CGImage? {
        contentView.image(at: frame)
    }
    
    func control(
        for model: any AccessibilityView
    ) -> A11yControlLayer? {
        contentView
            .drawnControls
            .first(where: { control in
                control.model === model
            })
    }
}

extension CanvasView: CanvasScrollViewProtocol {
    func fitToWindow(animated: Bool) {
        if let fitingMagnification {
            setMagnification(to: fitingMagnification, animated: animated)
        }
    }
}

extension CanvasView: PreviewSourceProtocol {
    func previewImage() -> Image? {
        contentView.imageRepresentatation()
    }
}

extension NSView {
    
    func imageRepresentatation() -> Image? {
        let mySize = bounds.size
        let imgSize = mySize
        guard let bir = bitmapImageRepForCachingDisplay(in: bounds) else {
            return nil
        }
        
        bir.size = imgSize
        cacheDisplay(in: bounds, to: bir)
        
        let image = Image(size: imgSize)
        image.addRepresentation(bir)
        return image
    }
}

extension NSEdgeInsets {
    var verticals: CGFloat {
        top + bottom
    }
}

extension CGRect {
    var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }
}

extension ClosedRange where Bound == CGFloat {
    fileprivate func trim(_ value: Bound) -> Bound {
        Swift.max(
            lowerBound,
            Swift.min(upperBound, value)
        )
    }
}
