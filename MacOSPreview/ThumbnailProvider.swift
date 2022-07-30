//
//  ThumbnailProvider.swift
//  MacOSPreview
//
//  Created by Mikhail Rubanov on 30.07.2022.
//

import QuickLookThumbnailing
import Document

class ThumbnailProvider: QLThumbnailProvider {
    
    override func provideThumbnail(
        for request: QLFileThumbnailRequest,
        _ handler: @escaping (QLThumbnailReply?, Error?) -> Void
    ) {
        let fileURL = request.fileURL
        
        let quickLookURL = VODesignDocument.quickLook(documentURL: fileURL)
        let reply = QLThumbnailReply(imageFileURL: quickLookURL)
        
        handler(reply, nil)
    }
}
