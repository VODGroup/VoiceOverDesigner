import AppKit

class CenteredClipView: NSClipView {
    
    var magnification: CGFloat = 1
    
    /// In document's coordinate space
    override var contentInsets: NSEdgeInsets {
        get {
            let contentSize = documentView!.intrinsicContentSize
            
            guard contentSize.width != .infinity && contentSize.height != .infinity
            else { return NSEdgeInsetsZero }
            
            let horizontal = max(0, (frame.width  / magnification - contentSize.width ))
            let vertical   = max(0, (frame.height / magnification - contentSize.height))
            
            let insets = NSEdgeInsets(
                top: vertical,
                left: horizontal,
                bottom: vertical,
                right: horizontal)
            
            return insets
        }
        
        set {}
    }
}

