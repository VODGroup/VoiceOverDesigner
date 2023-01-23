import Foundation

extension VODesignDocumentProtocol {
    
    var frameWrapper: FileWrapper {
        (documentWrapper.fileWrappers?[defaultFrameName] ?? documentWrapper)
    }
    
    func fileWrapper() throws -> FileWrapper {
        
        invalidateWrapperIfPossible(fileInFrame: FileName.controls)
//        if frameWrapper.fileWrappers?[FileName.controls] == nil {
        frameWrapper.addFileWrapper(try controlsWrapper())
//        }
        
        if frameWrapper.fileWrappers?[FileName.screen] == nil,
           let imageWrapper = imageWrapper() {
            frameWrapper.addFileWrapper(imageWrapper)
        }
        
        if frameWrapper.fileWrappers?[FileName.info] == nil {
            let frameMetaWrapper = infoWrapper()
            frameWrapper.addFileWrapper(frameMetaWrapper)
        }
        
        if documentWrapper.fileWrappers?[FolderName.quickLook] == nil,
            let previewWrapper = previewWrapper() {
            documentWrapper.addFileWrapper(previewWrapper)
        }
        
        return documentWrapper
    }
}

extension VODesignDocumentProtocol {
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
        imageWrapper.preferredFilename = FileName.quickLookFile
        
        let quicklookFolder = FileWrapper(directoryWithFileWrappers: [FolderName.quickLook: imageWrapper])
        quicklookFolder.preferredFilename = FolderName.quickLook
        return quicklookFolder
    }
    
    private func infoWrapper() -> FileWrapper {
        let frameMetaData = try! FrameInfoPersistance.data(frame: frameInfo)
        
        let frameMetaWrapper = FileWrapper(regularFileWithContents: frameMetaData)
        frameMetaWrapper.preferredFilename = FileName.info
        return frameMetaWrapper
    }
}

extension VODesignDocumentProtocol {
    
    func read(
        from packageWrapper: FileWrapper
    ) throws {
        guard packageWrapper.isDirectory else {
            self.documentWrapper = FileWrapper(directoryWithFileWrappers: [:])
            let frameWrapper = FileWrapper(directoryWithFileWrappers: [:])
            frameWrapper.preferredFilename = defaultFrameName
            self.documentWrapper.addFileWrapper(frameWrapper)
            print("Nothing to read, probably the document was just created")
            return
        }
        
        self.documentWrapper = packageWrapper
        
        let frameFolder = frameWrapper.fileWrappers!

        if
            let controlsWrapper = frameFolder[FileName.controls],
            let controlsData = controlsWrapper.regularFileContents
        {
            let codingService = AccessibilityViewCodingService()
            controls = try codingService.controls(from: controlsData)
        }

        if let imageWrapper = frameFolder[FileName.screen],
           let imageData = imageWrapper.regularFileContents {
            image = Image(data: imageData)
        }

        if let frameInfoWrapper = frameFolder[FileName.info],
           let infoData = frameInfoWrapper.regularFileContents,
            let info = try? JSONDecoder().decode(FrameInfo.self,
                                                 from: infoData) {
            frameInfo = info
        }
    }
    
    func invalidateWrapperIfPossible(fileInFrame: String) {
        if let imageWrapper = frameWrapper.fileWrappers?[fileInFrame] {
            frameWrapper.removeFileWrapper(imageWrapper)
        }
    }
    
    func invalidateWrapperIfPossible(fileInRoot: String) {
        if let wrapper = documentWrapper.fileWrappers?[fileInRoot] {
            documentWrapper.removeFileWrapper(wrapper)
        }
    }
}
