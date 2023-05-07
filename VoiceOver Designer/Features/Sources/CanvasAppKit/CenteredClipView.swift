import AppKit

class CenteredClipView: NSClipView
{
    override func constrainBoundsRect(_ proposedBounds: NSRect) -> NSRect {
        var rect = super.constrainBoundsRect(proposedBounds)
        
        if let containerView = documentView {
            let containerSize = containerView.intrinsicContentSize // can change on current layout pass and have not yet affect just containerView.frame
            
            if (rect.size.width > containerSize.width) {
                rect.origin.x = (containerSize.width - rect.width) / 2
            }
            
            if(rect.size.height > containerSize.height) {
                rect.origin.y = (containerSize.height - rect.height) / 2
            }
        }
        
        return rect
    }
}
