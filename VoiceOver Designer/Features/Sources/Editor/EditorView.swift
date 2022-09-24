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
   
    @IBOutlet weak var dragnDropView: DragNDropImageView!
    
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

        let imageSize = image.size

        clipView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        fitToWindow()
    }
    
    private func fitToWindow() {
        if let fitingMagnification {
            scrollView.magnification = fitingMagnification
        }
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
        
        let scrollViewVisibleHeight = scrollView.frame.height - scrollView.contentInsets.verticals
        return scrollViewVisibleHeight / image.size.height
    }
    
    func fitToWindowIfAlreadyFitted() {
        if isImageMagnificationFitsToWindow {
            fitToWindow()
        }
    }
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

extension NSEdgeInsets {
    var verticals: CGFloat {
        top + bottom
    }
}

class CenteredClipView: NSClipView
{
    override func constrainBoundsRect(_ proposedBounds: NSRect) -> NSRect {
        var rect = super.constrainBoundsRect(proposedBounds)
        if let containerView = self.documentView as? NSView {
            
            if (rect.size.width > containerView.frame.size.width) {
                rect.origin.x = (containerView.frame.width - rect.width) / 2
            }
            
            if(rect.size.height > containerView.frame.size.height) {
                rect.origin.y = (containerView.frame.height - rect.height) / 2
            }
        }
        
        return rect
    }
}
