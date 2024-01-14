//
//  CanvasView.swift
//  Canvas
//
//  Created by Mikhail Rubanov on 22.05.2022.
//

import AppKit

import CommonUIAppKit
import Document
import Canvas

class CanvasView: FlippedView {
    
    @IBOutlet weak var scrollView: CanvasScrollView!
    
    @IBOutlet weak var clipView: CenteredClipView!
    
    var documentView: ContentView {
        scrollView.documentView()
    }
   
    @IBOutlet weak var dragnDropView: DragNDropImageView!
    
    @IBOutlet weak var zoomOutButton: NSButton!
    @IBOutlet weak var zoomToFitButton: NSButton!
    @IBOutlet weak var zoomInButton: NSButton!
    
    @IBOutlet weak var footer: NSView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        scrollView.delegate = self
        
        zoomOutButton.toolTip = "⌘-"
        zoomToFitButton.toolTip = "0"
        zoomInButton.toolTip = "⌘+"
        footer.wantsLayer = true
        footer.layer?.backgroundColor = NSColor.quaternaryLabelColor.cgColor
        footer.isHidden = false
        
        dragnDropView.hideTextAndBorder()
        
        clipView.translatesAutoresizingMaskIntoConstraints = false
        documentView.translatesAutoresizingMaskIntoConstraints = false
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
        documentView.image(at: frame)
    }
    
    func control(
        for model: any ArtboardElement
    ) -> A11yControlLayer? {
        documentView
            .drawnControls
            .first(where: { control in
                control.model === model
            })
    }
}

extension CanvasView: ScrollViewZoomDelegate {
    func didUpdateScale(_ magnification: CGFloat) {
        documentView.hud.scale = 1 / magnification
        dragnDropView.scale = magnification
        clipView.magnification = magnification
    }
}

extension CanvasView: PreviewSourceProtocol {
    func previewImage() -> Image? {
        documentView.imageRepresentation()
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
    
    var horizontals: CGFloat {
        left + right
    }
}

extension CGRect {
    var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }
}
