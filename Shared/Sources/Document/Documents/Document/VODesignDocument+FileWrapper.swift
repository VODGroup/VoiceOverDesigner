import Foundation

extension VODesignDocumentProtocol {
    
    // MARK: - Write
    func fileWrapper() throws -> FileWrapper {
        // Save artboard's structure
        documentWrapper.invalidateIfPossible(file: FileName.document)
        let documentStructureWrapper = try documentStructureFileWrapper()
        self.documentWrapper.addFileWrapper(documentStructureWrapper)

        // Preview depends on elements and should be invalidated
        documentWrapper.invalidateIfPossible(file: FolderName.quickLook)
        if let previewWrapper = previewWrapper() {
            documentWrapper.addFileWrapper(previewWrapper)
        }

        return documentWrapper
    }
    
    func storeImagesAsFileWrappers() {
        for frame in artboard.frames {
            migrateImageIfNeeded(frame: frame)
        }
    }
    
    func migrateImageIfNeeded(frame: Frame) {
        switch frame.imageLocation {
            
        case .fileWrapper(let path):
            let url = URL(filePath: path)
            let name = url.lastPathComponent
            
            let wrapperExists = imagesFolderWrapper.fileWrappers?[name] != nil
            if wrapperExists {
                return
            }
            
            if let imagePath = fileURL?.appendingPathComponent(path),
               let imageWrapper = try? FileWrapper(url: imagePath)
            {
                // TODO: Remove filename duplication across project
                imageWrapper.preferredFilename = FileName.frameImage
                
                imagesFolderWrapper.addFileWrapper(imageWrapper)
                
                frame.imageLocation = .fileWrapper(name: FileName.frameImage)
            }
        case .remote(_):
            // TODO: Move to local files?
            fatalError()
        }
    }
    
    @discardableResult
    func addImageWrapper(image: Image, name: String?) -> ImageLocation {
        addImageWrapper(content: (image.heic() ?? image.png())!,
                        name: name)
    }
    @discardableResult
    func addImageWrapper(content: Data, name: String?) -> ImageLocation {
        let name = name ?? UUID().uuidString
        
        let imageWrapper = FileWrapper(regularFileWithContents: content)
        imageWrapper.preferredFilename = name
        
        imagesFolderWrapper.addFileWrapper(imageWrapper)
        return .fileWrapper(name: name)
    }
    
    var imagesFolderWrapper: FileWrapper {
        if let existedWrapper = documentWrapper.fileWrappers?[FolderName.images] {
            return existedWrapper
        }
        
        Swift.print("Create image wrapper")
        let imagesFolderWrapper = FileWrapper(directoryWithFileWrappers: [:])
        imagesFolderWrapper.preferredFilename = FolderName.images
        documentWrapper.addFileWrapper(imagesFolderWrapper)
        return imagesFolderWrapper
    }
}

enum DocumentVersion {
    case beta
    case release
    case artboard
}

extension FileWrapper {
    func documentVersion() -> DocumentVersion {
        let hasControlsFileOnTopLevel = fileWrappers?[FileName.controls] != nil
        
        if hasControlsFileOnTopLevel {
            return .beta
        } else {
            let hasFrameFolderOnTopLevel = fileWrappers?["Frame"] != nil
            if hasFrameFolderOnTopLevel {
                return .release
            }
            return .artboard
        }
    }
}

extension VODesignDocumentProtocol {

    var frameWrappers: [FileWrapper] {
        let frameWrappers = documentWrapper
            .fileWrappers?
            .filter({ keyAndWrapper in
                keyAndWrapper.key.hasPrefix("Frame")
            })
        
        if let frameWrappers, !frameWrappers.isEmpty {
            return frameWrappers.values.compactMap { $0 }
        } else {
            return [documentWrapper]
        }
    }

    private func documentStructureFileWrapper(
    ) throws -> FileWrapper {
        let codingService = ArtboardElementCodingService()
        let wrapper = FileWrapper(regularFileWithContents: try codingService.data(from: artboard))
        wrapper.preferredFilename = FileName.document
        return wrapper
    }
    
    private func previewWrapper() -> FileWrapper? {
        guard let image = previewSource?.previewImage(), // TODO: Provide default image
              let imageData = image.heic(compressionQuality: 0.51)
        else { return nil }
        
        let quicklookWrapper = FileWrapper(regularFileWithContents: imageData)
        quicklookWrapper.preferredFilename = FileName.quickLookFile
        
        let quicklookFolder = FileWrapper(directoryWithFileWrappers: [FolderName.quickLook: quicklookWrapper])
        quicklookFolder.preferredFilename = FolderName.quickLook
        return quicklookFolder
    }
}

// MARK: - Read
extension VODesignDocumentProtocol {
    
    func read(
        from packageWrapper: FileWrapper
    ) throws -> (DocumentVersion, Artboard) {
        guard packageWrapper.isDirectory else {
            // Some file from tests creates as a directory
            createEmptyDocumentWrapper()
            Swift.print("Nothing to read, probably the document was just created")
            return (.artboard, Artboard())
        }
        
        let fileVersion = packageWrapper.documentVersion()
        
        // Keep reference to gently update files for iCloud
        self.documentWrapper = packageWrapper
        
        switch fileVersion {
        case .beta:
            // TODO: Remove force unwraps
            createEmptyDocumentWrapper() // Recreate structure
            let controlsWrapper = packageWrapper.fileWrappers![FileName.controls]!
            let codingService = ArtboardElementCodingService()
            let controls = try codingService.controls(from: controlsWrapper.regularFileContents!)
            
            let imageName = FileName.frameImage
            let imageData = packageWrapper.fileWrappers![FileName.screen]!.regularFileContents!
            let imageSize = Image(data: imageData)?.size ?? .zero
            
            addImageWrapper(content: imageData, name: imageName)
            
            let artboard = Artboard(elements: [
                Frame(label: "Frame",
                      imageLocation: .fileWrapper(name: imageName),
                      frame: CGRect(origin: .zero, size: imageSize),
                      elements: controls)
            ])
            
            return (.beta, artboard)
        case .release:
            if let frameWrapper = documentWrapper.fileWrappers?[defaultFrameName] {
                let artboard = Artboard(elements: [
                    try readFrameWrapper(frameWrapper)
                ])
                
                documentWrapper.removeFileWrapper(frameWrapper)
                
                return (.release, artboard)
            }
            
        case .artboard:
            if let documentWrapper = documentWrapper.fileWrappers?[FileName.document] {
                let artboard = try! ArtboardElementCodingService().artboard(from: documentWrapper.regularFileContents!)
                
                return (.artboard, artboard)
            }
        }
        
        return (.artboard, Artboard())
    }
    
    /// For version .release
    private func readFrameWrapper(
        _ frameWrapper: FileWrapper
    ) throws -> Frame {
        Swift.print("Read wrapper \(frameWrapper.filename ?? "null")")
        let frameFolder = frameWrapper.fileWrappers!

        var controls: [any ArtboardElement] = []
        if
            let controlsWrapper = frameFolder[FileName.controls],
            let controlsData = controlsWrapper.regularFileContents
        {
            let codingService = ArtboardElementCodingService()
            controls = try codingService.controls(from: controlsData)
        }

        var image: Image?
        if let imageWrapper = frameFolder[FileName.screen],
           let imageData = imageWrapper.regularFileContents {
            image = Image(data: imageData)

            let newImageWrapper = FileWrapper(regularFileWithContents: imageData)
            newImageWrapper.preferredFilename = FileName.frameImage
            imagesFolderWrapper.addFileWrapper(newImageWrapper)
        }
        
        var frameInfo: FrameInfo?
        if let frameInfoWrapper = frameFolder[FileName.info],
           let infoData = frameInfoWrapper.regularFileContents,
           let info = try? JSONDecoder().decode(FrameInfo.self,
                                                from: infoData) {
            frameInfo = info
        }
        
        let defaultFrameSize = CGSize(width: 400, height: 800) // TODO: Define default size
        
        let frame = frameInfo?.frame
        ?? CGRect(origin: .zero,
                  size: image?.size ?? defaultFrameSize) // TODO: Add image's scale
        
        let name = frameWrapper.filename ?? UUID().uuidString // TODO: Remove uuidString from here
        
        return Frame(label: name,
                     imageLocation: .fileWrapper(name: "Frame/\(FileName.frameImage)"),
                     frame: frame,
                     elements: controls)
    }
    
    private func createEmptyDocumentWrapper() {
        self.documentWrapper = FileWrapper(directoryWithFileWrappers: [:])
    }
}

extension FileWrapper {
    
    static func createDirectory(preferredFilename: String) -> FileWrapper {
        let wrapper = FileWrapper(directoryWithFileWrappers: [:])
        wrapper.preferredFilename = preferredFilename
        return wrapper
    }
    
    func invalidateIfPossible(file: String) {
        if let wrapper = fileWrappers?[file] {
            removeFileWrapper(wrapper)
        }
    }
}

