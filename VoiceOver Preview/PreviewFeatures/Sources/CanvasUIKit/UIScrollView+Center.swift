import UIKit

extension UIScrollView {
    
    func centerAndScaleToFit(contentSize: CGSize) {
        self.contentSize = contentSize
        
        /// Fit to width for iPhone, keep image width for iPhone's screen on iPad
        let minimalWidth = min(bounds.width, contentSize.width)
        let scale = updateZoomScaleToFitContent(width: minimalWidth)
        
        // We had to calculate manually because first layout do it wrong
        let scaledContentSize = CGSize(width: contentSize.width * scale,
                                       height: contentSize.height * scale)
        updateContentInsetToCenterContent(contentSize: scaledContentSize)
    }
    
    func updateContentInsetToCenterContent(contentSize: CGSize) {
        let offsetX = max((bounds.width  - contentSize.width)  * 0.5, 0)
        let offsetY = max((bounds.height - contentSize.height) * 0.5, 0)
    
        contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: 0, right: 0)
    }
    
    func updateZoomScaleToFitContent(width: CGFloat) -> CGFloat {
        let widthScale  = width  / contentSize.width
        let minScale    = widthScale
        
        minimumZoomScale = widthScale
        zoomScale = minScale
        return minScale
    }
}
