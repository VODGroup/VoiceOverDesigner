//
//  PreviewView.swift
//  VoiceOver Preview
//
//  Created by Andrey Plotnikov on 22.07.2022.
//

import Foundation
import UIKit
import Document

class VODesignPreviewView: UIView {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var backgroundImageHeight: NSLayoutConstraint!
    @IBOutlet weak var canvas: Canvas!
    
    var image: UIImage? {
        didSet {
            backgroundImageView.image = image
            
            guard let image = image else { return }
 
            guard image.size.width != 0 else { return }
            let aspectRatio = bounds.width / image.size.width
            backgroundImageHeight.constant = image.size.height * aspectRatio
        }
    }
    
    var controls: [A11yDescription] = [] {
        didSet {
            for control in controls {
                drawingController.drawControl(from: control)
            }
            
            canvas.layout = VoiceOverLayout(
                controls: controls,
                container: scrollView)
        }
    }
    
    private lazy var drawingController = DrawingController(view: canvas)
}

class Canvas: UIView, DrawingView {
    var drawnControls: [A11yControl] = []
    
    var alingmentOverlay: AlingmentOverlayProtocol = NoAlignmentOverlay()
    
    var layout: VoiceOverLayout? {
        didSet {
            accessibilityElements = layout?.accessibilityElements
        }
    }
}
