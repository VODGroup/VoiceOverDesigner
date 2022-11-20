import Foundation
import AppKit

extension CGImage {
    static func empty() -> CGImage {
        let size = CGSize(width: 1, height: 1)
        let image = DrawImageInNSGraphicsContext(size: size) {
            // Nothing
        }
        
        var frame = CGRect(origin: .zero, size: size)
        return image.cgImage(forProposedRect: &frame,
                             context: nil,
                             hints: nil)!
    }
}

func DrawImageInNSGraphicsContext(size: CGSize, drawFunc: ()->()) -> NSImage {
    let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: Int(size.width),
        pixelsHigh: Int(size.height),
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .calibratedRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0)
    
    let context = NSGraphicsContext(bitmapImageRep: rep!)
    
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = context
    
    drawFunc()
    
    NSGraphicsContext.restoreGraphicsState()
    
    let image = NSImage(size: size)
    image.addRepresentation(rep!)
    
    return image
}
