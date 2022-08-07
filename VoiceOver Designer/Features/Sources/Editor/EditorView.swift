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
}

class EditorView: FlippedView {
    
    @IBOutlet weak var scrollView: NSScrollView!
    
    @IBOutlet weak var backgroundImageView: NSImageView!
    
    @IBOutlet weak var clipView: NSClipView!
    @IBOutlet weak var scrollViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var contentView: NSView!
    @IBOutlet weak var controlsView: ControlsView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        scrollView.verticalScrollElasticity = .none
        scrollView.horizontalScrollElasticity = .none
    }
    
    func setImage(_ image: NSImage) {
        //        view().backgroundImageView.frame = CGRect(x: 0, y: 0, width: 375, height: 1000)
        backgroundImageView.image = image
        backgroundImageView.layer?.zPosition = 0
        //        view.window?.contentMinSize = CGSize(width: 320, height: 762)
        
        
//        scrollViewHeight.constant = image.size.height / 3
//        clipView.frame = CGRect(origin: .zero,
//                                       size: scrollView.frame.size)
        
        let imageSizeScaled = CGSize(width: image.size.width / 3,
                                     height: image.size.height / 3)
//        clipView.setBoundsSize(imageSizeScaled)
        clipView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
//        contentView.frame = CGRect(
//            origin: .zero,
//            size: imageSizeScaled)
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
