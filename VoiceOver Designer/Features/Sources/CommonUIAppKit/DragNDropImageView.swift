//
//  DragNDropImageView.swift
//  Projects
//
//  Created by Mikhail Rubanov on 06.05.2022.
//

import AppKit

public protocol DragNDropDelegate: AnyObject {
    func didDrag(image: NSImage, locationInWindow: CGPoint, name: String?)
    func didDrag(path: URL)
}

open class DragNDropImageView: NSView {
    open var isWaitingForFile: Bool = false
    
    public weak var delegate: DragNDropDelegate?

    lazy var label: NSTextField = {
        let label = NSTextField(string: defaultText)
        label.font = NSFont.preferredFont(forTextStyle: .largeTitle)
        label.textColor = .tertiaryLabelColor
        label.backgroundColor = .clear
        label.isBordered = false
        
        addSubview(label)
        label.isEditable = false
        label.isSelectable = false
        label.alignment = .center
        return label
    }()
    
    lazy var border: BorderedLayer = {
        let border = BorderedLayer()
        border.cornerRadius = 10
        
        wantsLayer = true
        layer?.addSublayer(border)
        
        return border
    } ()
    
    var text: String = "" {
        didSet {
            label.stringValue = text
            needsLayout = true
        }
    }
    
    public var scale: CGFloat = 1
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        registerDragging()
        
        hideTextAndBorder()
    }
    
    open override func layout() {
        super.layout()
        
        label.sizeToFit()
        let size = label.frame.size
        label.frame = CGRect(
            origin: CGPoint(x: (bounds.width-size.width)/2,
                            y: (bounds.height-size.height)/2),
            size: size)
        
        let inset: CGFloat = 10
        
        border.frame = bounds
        
        if let imageSize, let cursorLocation {
            let scaledSize = imageSize.scaled(scale)
//            let centeredOrigin = CGPoint(x: cursorLocation.x - scaledSize.width / 2,
//                                         y: cursorLocation.y - scaledSize.height / 2)
            // TODO: Use centeredOrigin, but had to move origin of inserted view
            let flippedOrigin = CGPoint(x: cursorLocation.x,
                                        y: cursorLocation.y - scaledSize.height)
            border.borderFrame = CGRect(origin: flippedOrigin,
                                        size: scaledSize)
        } else {
            let fullFrame = CGRect(
                    origin: CGPoint(x: bounds.origin.x + inset,
                                    y: bounds.origin.y + inset),
                    size: CGSize(width: bounds.size.width - inset * 2,
                                 height: bounds.size.height - inset * 2))
            
            border.borderFrame = fullFrame
        }
        
    }

    private var cursorLocation: NSPoint? {
        didSet {
            needsLayout = true
        }
    }
    private var imageSize: NSSize?
    
    // MARK: - Dragging
    func registerDragging() {
        // TODO: Add another files
        registerForDraggedTypes([.png, .fileURL])
    }
    
    public override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        imageSize = sender.image()?.size
        isWaitingForFile = true
        hideText()
        showBorder()
        return .copy
    }
    
    override open func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        cursorLocation = cursorLocation(from: sender)
        return .move
    }
    
    private func cursorLocation(from sender: NSDraggingInfo) -> CGPoint {
        convert(sender.draggingLocation, from: sender.draggingDestinationWindow?.contentView)
    }
    
    open override func draggingExited(_ sender: NSDraggingInfo?) {
        show(text: defaultText)
        imageSize = nil
    }
    
    open override func draggingEnded(_ sender: NSDraggingInfo) {
        isWaitingForFile = false
        imageSize = nil
    }
    
    public override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let pasteboard = sender.draggingPasteboard
        
        var foundDocument = false
        
        for image in pasteboard.images {
            delegate?.didDrag(image: image,
                              locationInWindow: sender.draggingLocation,
                              name: image.name())
            
            foundDocument = true
        }
        
        for url in pasteboard.VODesignURLs {
            delegate?.didDrag(path: url)
            foundDocument = true
        }
        
        if foundDocument {
            hideTextAndBorder()
        } else {
            show(text: NSLocalizedString("Don't know what it is :-(", comment: ""),
                 changeTo: defaultText)
        }
        
        return foundDocument
    }
    
    let defaultText = NSLocalizedString("Add your screenshot", comment: "")
    
    public func showDefaultText() {
        show(text: defaultText)
    }
    
    private func showBorder() {
        border.isHidden = false
    }
    
    func show(text: String, changeTo nextText: String? = nil) {
        label.isHidden = false
        showBorder()
        self.text = text
        
        if let nextText = nextText {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                self.text = nextText
            }
        }
    }
    
    public func hideText() {
        label.isHidden = true
    }
    
    public func hideTextAndBorder() {
        hideText()
        border.isHidden = true
    }
}

class BorderedLayer: CAShapeLayer {
    override init() {
        super.init()
        
        fillColor = nil
        strokeColor = NSColor.secondaryLabelColor.cgColor
        
        lineWidth = 2
        lineDashPattern = [5.0, 5.0]
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var borderFrame: CGRect? {
        didSet {
            setNeedsLayout()
        }
    }
    
    override func layoutSublayers() {
        super.layoutSublayers()
        
        path = CGPath(roundedRect: (borderFrame ?? bounds).insetBy(dx: borderWidth/2, dy: borderWidth/2),
                      cornerWidth: cornerRadius,
                      cornerHeight: cornerRadius,
                      transform: nil)
    }
}

extension NSDraggingInfo {
    func image() -> NSImage? {
        let pasteboard = draggingPasteboard
        let image = NSImage(pasteboard: pasteboard)
        return image
    }
    
}

extension CGSize {
    func scaled(_ scale: CGFloat) -> Self {
        CGSize(width: width * scale,
               height: height * scale)
    }
}

// TODO: Remove duplicationString(data: , encoding: .utf8)
extension NSEvent {
    func location(in view: NSView) -> CGPoint {
        view.convert(locationInWindow, from: nil)
    }
}

extension NSPasteboard {
    var fileName: String? {
        guard let data = data(forType: .fileURL),
              let string = String(data: data, encoding: .utf8),
              let url = URL(string: string) else {
            return nil
        }
        
        return url.lastPathComponent
    }
    
    var VODesignURLs: [URL] {
        readObjects(forClasses: [NSURL.self], options: nil)?
            .compactMap {
                $0 as? URL
            }.filter {
                $0.pathExtension.lowercased() == "vodesign"
            } ?? []
    }
    
    var images: [NSImage] {
        readObjects(forClasses: [NSImage.self], options: nil)?
            .compactMap {
                $0 as? NSImage
            } ?? []
    }
}
