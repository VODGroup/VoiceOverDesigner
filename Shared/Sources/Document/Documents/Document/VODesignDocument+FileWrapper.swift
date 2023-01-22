import Foundation

extension VODesignDocument {
    func fileWrapper() throws -> FileWrapper {
        let framePackage = FileWrapper(directoryWithFileWrappers: [:])
        framePackage.preferredFilename = defaultFrameName
        
        framePackage.addFileWrapper(try controlsWrapper())
        
        if let imageWrapper = imageWrapper() {
            framePackage.addFileWrapper(imageWrapper)
        }
        
        let frameMetaData = try! FrameInfoPersistance.data(frame: frameInfo)
        let frameMetaWrapper = FileWrapper(regularFileWithContents: frameMetaData)
        frameMetaWrapper.preferredFilename = FileName.info
        framePackage.addFileWrapper(frameMetaWrapper)
        
        let package = FileWrapper(directoryWithFileWrappers: [:])
        package.addFileWrapper(framePackage)
        
        if let previewWrapper = previewWrapper() {
            package.addFileWrapper(previewWrapper)
        }
        
        return package
    }
}

extension VODesignDocument {
    private func controlsWrapper() throws -> FileWrapper {
        let codingService = AccessibilityViewCodingService()
        let wrapper = FileWrapper(regularFileWithContents: try codingService.data(from: controls))
        wrapper.preferredFilename = FileName.controls
        return wrapper
    }
    
    private func imageWrapper() -> FileWrapper? {
        guard let image = image,
              let imageData = image.png()
        else { return nil }
        
        let imageWrapper = FileWrapper(regularFileWithContents: imageData)
        imageWrapper.preferredFilename = FileName.screen
        
        
        return imageWrapper
    }
    
    private func previewWrapper() -> FileWrapper? {
        guard let image = image, // TODO: Make smaller size
              let imageData = image.png()
        else { return nil }
        
        let imageWrapper = FileWrapper(regularFileWithContents: imageData)
        imageWrapper.preferredFilename = QuickLookFileName
        
        let quicklookFolder = FileWrapper(directoryWithFileWrappers: [QuickLookFolderName: imageWrapper])
        quicklookFolder.preferredFilename = QuickLookFolderName
        return quicklookFolder
    }
}
