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

class CanvasView: FlippedView {
    
    @IBOutlet weak var scrollView: CanvasScrollView!
    
    @IBOutlet weak var clipView: NSClipView!
    
    @IBOutlet weak var contentView: ContentView!
   
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
        
        dragnDropView.hideTextAndBorder()
        
        clipView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    var isEmpty: Bool = true {
        didSet {
            if isEmpty {
                dragnDropView.showDefaultText()
            } else {
                dragnDropView.hideTextAndBorder()
            }
        }
    }
        
    // MARK: - Image
    func updateDragnDropVisibility(hasDrawnControls: Bool) {
        if hasDrawnControls {
            dragnDropView.hideTextAndBorder()
        } else {
            dragnDropView.showDefaultText()
        }

        footer.isHidden = !hasDrawnControls
    }
    
    func image(at frame: CGRect) async -> CGImage? {
        contentView.image(at: frame)
    }
    
    func control(
        for model: any ArtboardElement
    ) -> A11yControlLayer? {
        contentView
            .drawnControls
            .first(where: { control in
                control.model === model
            })
    }
}

extension CanvasView: PreviewSourceProtocol {
    func previewImage() -> Image? {
        contentView.imageRepresentation()
    }
}

extension NSView {
    
    func imageRepresentation() -> Image? {
        let mySize = bounds.size
        let imgSize = mySize
        guard let bitmap = bitmapImageRepForCachingDisplay(in: bounds) else {
            return nil
        }
        
        bitmap.size = imgSize
        cacheDisplay(in: bounds, to: bitmap)
        
        let image = Image(size: imgSize)
        image.addRepresentation(bitmap)
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
