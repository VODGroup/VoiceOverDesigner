//
//  PointerService.swift
//
//
//  Created by Mikhail Rubanov on 17.10.2023.
//

import AppKit
import Canvas

class PointerService {
    func updateCursor(_ value: DrawingController.Pointer?) {
        NSCursor.current.pop()
        guard let value else { return NSCursor.arrow.push() }
        switch value {
        case .dragging:
            NSCursor.closedHand.push()
        case .hover:
            NSCursor.openHand.push()
        case .resize(let corner):
            
            // There's no system resizing images so takes from WebKit
            // see or should take custom image/private cursor: https://stackoverflow.com/questions/49297201/diagonal-resizing-mouse-pointer
            let image: NSImage = {
                
                switch corner {
                case .topLeft, .bottomRight:
                    return NSImage(byReferencingFile: "/System/Library/Frameworks/WebKit.framework/Versions/Current/Frameworks/WebCore.framework/Resources/northWestSouthEastResizeCursor.png")!
                    
                case .topRight, .bottomLeft:
                    return NSImage(byReferencingFile: "/System/Library/Frameworks/WebKit.framework/Versions/Current/Frameworks/WebCore.framework/Resources/northEastSouthWestResizeCursor.png")!
                }
            }()
            
            NSCursor(image: image, hotSpot: NSPoint(x: 8, y: 8)).push()
            
        case .crosshair:
            NSCursor.crosshair.push()
        case .copy:
            NSCursor.dragCopy.push()
        }
    }
}
