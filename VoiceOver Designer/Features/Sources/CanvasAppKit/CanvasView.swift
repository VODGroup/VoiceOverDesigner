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
    
    var escListener = EscModifierFactory().make()
    
    var hud = HUDLayer()
    
    override func layout() {
        super.layout()
        
        hud.frame = bounds
        
        // TODO: Find better place to add
        addHUD()
    }
}

class CanvasView: FlippedView {
    
    @IBOutlet weak var scrollView: CanvasScrollView!
    
    @IBOutlet weak var backgroundImageView: NSImageView!
    
    @IBOutlet weak var clipView: NSClipView!
    
    @IBOutlet weak var contentView: NSView!
    @IBOutlet weak var controlsView: ControlsView!
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
        scrollView.hud = controlsView.hud
        controlsView.addHUD()
        
        zoomOutButton.toolTip = "⌘-"
        zoomToFitButton.toolTip = "0"
        zoomInButton.toolTip = "⌘+"
        footer.wantsLayer = true
        footer.layer?.backgroundColor = NSColor.quaternaryLabelColor.cgColor
        footer.isHidden = true
    }
    
    // MARK: - Magnification
    func fitToWindowIfAlreadyFitted() {
        if isImageMagnificationFitsToWindow {
            fitToWindow(animated: false)
        }
    }
    
    func fitToWindow(animated: Bool) {
        if let fitingMagnification {
            setMagnification(to: fitingMagnification, animated: animated)
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
            centeredAt: controlsView.hud.selectedControlFrame?.center ?? contentView.frame.center)
    }
    
    private var isImageMagnificationFitsToWindow: Bool {
        if let fitingMagnification {
            return abs(fitingMagnification - scrollView.magnification) < 0.01
        } else {
            return false
        }
    }
    
    private var fitingMagnification: CGFloat? {
        guard let image = backgroundImageView.image else { return nil }
        
        let scrollViewVisibleHeight = scrollView.frame.height// - scrollView.contentInsets.verticals
        return scrollViewVisibleHeight / image.size.height
    }
    
    // MARK: - Image
    func setImage(_ image: NSImage?) {
        footer.isHidden = image == nil
        dragnDropView.isHidden = image != nil
        addImageButton.isHidden = image != nil
        
        guard let image = image else {
            return
        }

        backgroundImageView.image = image
        backgroundImageView.layer?.zPosition = 0

        clipView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        fitToWindow(animated: false)
    }
    
    func image(at frame: CGRect) async -> CGImage? {
        let image = backgroundImageView.image
        var frame = frame
        let cgImage = image?
            .cgImage(forProposedRect: &frame,
                     context: nil,
                     hints: nil)?
            .cropping(to: frame)
        
        return cgImage
    }
    
    func control(
        for model: any AccessibilityView
    ) -> A11yControlLayer? {
        controlsView
            .drawnControls
            .first(where: { control in
                control.model === model
            })
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
