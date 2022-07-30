//
//  ThumbnailProvider.swift
//  Thumbnail
//
//  Created by Mikhail Rubanov on 30.07.2022.
//

import UIKit
import QuickLookThumbnailing
import Document

class ThumbnailProvider: QLThumbnailProvider {
    
//    override func provideThumbnail(
//        for request: QLFileThumbnailRequest,
//        _ handler: @escaping (QLThumbnailReply?, Error?) -> Void
//    ) {
//        let fileURL = request.fileURL
//
//        let quickLookURL = VODesignDocument.quickLook(documentURL: fileURL)
//        let reply = QLThumbnailReply(imageFileURL: quickLookURL)
//
//        handler(reply, nil)
//    }
    
    override func provideThumbnail(for request: QLFileThumbnailRequest, _ handler: @escaping (QLThumbnailReply?, Error?) -> Void) {
        
        let fileURL = request.fileURL
        let imageURL = VODesignDocument.quickLook(documentURL: fileURL)
        
        let image = UIImage(contentsOfFile: imageURL.path)!
        
        
        // size calculations
        
        let maximumSize = request.maximumSize
        let imageSize = image.size
        
        // calculate `newImageSize` and `contextSize` such that the image fits perfectly and respects the constraints
        var newImageSize = maximumSize
        var contextSize = maximumSize
        let aspectRatio = imageSize.height / imageSize.width
        let proposedHeight = aspectRatio * maximumSize.width
        
        if proposedHeight <= maximumSize.height {
            newImageSize.height = proposedHeight
            contextSize.height = max(proposedHeight.rounded(.down), request.minimumSize.height)
        } else {
            newImageSize.width = maximumSize.height / aspectRatio
            contextSize.width = max(newImageSize.width.rounded(.down), request.minimumSize.width)
        }
        
        handler(QLThumbnailReply(contextSize: contextSize, currentContextDrawing: { () -> Bool in
            // Draw the thumbnail here.
            
            // draw the image in the upper left corner
            //image.draw(in: CGRect(origin: .zero, size: newImageSize))
            
            // draw the image centered
            image.draw(in: CGRect(x: contextSize.width/2 - newImageSize.width/2,
                                  y: contextSize.height/2 - newImageSize.height/2,
                                  width: newImageSize.width,
                                  height: newImageSize.height))
            
            // Return true if the thumbnail was successfully drawn inside this block.
            return true
        }), nil)
    }
}
