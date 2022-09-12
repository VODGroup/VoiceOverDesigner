//
//  EditorView.swift
//  Editor
//
//  Created by Mikhail Rubanov on 22.05.2022.
//

import AppKit

import CommonUI
import Document

class ControlsView: FlippedView, DrawingView {
    var drawnControls: [A11yControl] = []
    
    lazy var alignmentOverlay = AlignmentOverlayFactory().overlay(for: self)
    
    var copyListener = CopyModifierFactory().make()
    
    var escListener = EscModifierFactory().make()
}

class EditorView: FlippedView {
    
    @IBOutlet weak var scrollView: NSScrollView!
    
    @IBOutlet weak var backgroundImageView: NSImageView!
    
    @IBOutlet weak var clipView: NSClipView!
    @IBOutlet weak var scrollViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var contentView: NSView!
    @IBOutlet weak var controlsView: ControlsView!
    @IBOutlet weak var addImageButton: NSButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        scrollView.verticalScrollElasticity = .none
        scrollView.horizontalScrollElasticity = .none
    }
    
    func setImage(_ image: NSImage?) {
        dragnDropView.isHidden = image != nil
        addImageButton.isHidden = image != nil
        
        guard let image = image else {
            return
        }

        backgroundImageView.image = image
        backgroundImageView.layer?.zPosition = 0

        let screenScale = NSScreen.main?.backingScaleFactor ?? 1
        var scale: CGFloat = image.recommendedLayerContentsScale(screenScale)

        if scale == 1 {
            scale = 3
        }
        let imageSizeScaled = CGSize(width: image.size.width / scale,
                                     height: image.size.height / scale)

        clipView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        imageWidth.constant = imageSizeScaled.width
        imageHeight.constant = imageSizeScaled.height
        
    }
    
    @IBOutlet weak var imageWidth: NSLayoutConstraint!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    
    @IBOutlet weak var dragnDropView: DragNDropImageView!
}

class FlippedView: NSView {
    override var isFlipped: Bool {
        true
    }
}

class FlippedStackView: NSStackView {
    override var isFlipped: Bool {
        true
    }
}
