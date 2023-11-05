import Foundation

extension VODesignDocumentProtocol {
    
    // MARK: - Write
    func fileWrapper() throws -> FileWrapper {
        storeImagesAsFileWrappers()
        
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
    
    private func storeImagesAsFileWrappers() {
        for frame in artboard.frames {
            switch frame.imageLocation {
                
            case .file(name: let name):
                if let existedWrapper = imagesFolderWrapper.fileWrappers?[name] {
                    return
                }
                 
                if let imageWrapper = try? FileWrapper(url: artboard.imageLoader.url(for: name)) {
                    imageWrapper.preferredFilename = name
                
                    imagesFolderWrapper.addFileWrapper(imageWrapper)
                }
            case .url(url: let url):
                break // Do nothing, location will be saved at document.json
            case .cache(let image):
                guard let imageData = artboard.imageLoader.image(for: frame)?.png()
                else {
                    print("No image to store")
                    return
                }
                
                let imageWrapper = FileWrapper(regularFileWithContents: imageData)
                imageWrapper.preferredFilename = FileName.screen
                
                imagesFolderWrapper.addFileWrapper(imageWrapper)
                
                // Update location
                // TODO: Name should be different
                frame.imageLocation = .file(name: FileName.screen)
            }
        }
    }
    
    var imagesFolderWrapper: FileWrapper {
        if let existedWrapper = documentWrapper.fileWrappers?["Images"] {
            return existedWrapper
        }
        
        let imagesFolderWrapper = FileWrapper(directoryWithFileWrappers: [:])
        imagesFolderWrapper.preferredFilename = "Images"
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
        
        let imageWrapper = FileWrapper(regularFileWithContents: imageData)
        imageWrapper.preferredFilename = FileName.quickLookFile
        
        let quicklookFolder = FileWrapper(directoryWithFileWrappers: [FolderName.quickLook: imageWrapper])
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
            print("Nothing to read, probably the document was just created")
            return (.artboard, Artboard())
        }
        
        let fileVersion = packageWrapper.documentVersion()
        
        // Keep reference to gently update files for iCloud
        self.documentWrapper = packageWrapper
        
        switch fileVersion {
        case .beta:
            let controlsWrapper = documentWrapper.fileWrappers![FileName.controls]!
            let codingService = ArtboardElementCodingService()
            let controls = try codingService.controls(from: controlsWrapper.regularFileContents!)
            
            let imageData = documentWrapper.fileWrappers![FileName.screen]!.regularFileContents!
            let imageSize = Image(data: imageData)?.size ?? .zero
            
            let artboard = Artboard(frames: [
                Frame(label: "Frame",
                      imageName: "Frame.png",
                      frame: CGRect(origin: .zero, size: imageSize),
                      elements: controls)
            ])
            
            return (.beta, artboard)
        case .release:
            if let frameWrapper = documentWrapper.fileWrappers?[defaultFrameName] {
                let artboard = Artboard(frames: [
                    try readFrameWrapper(frameWrapper)
                ])
                
                documentWrapper.removeFileWrapper(frameWrapper)
                
                return (.release, artboard)
            }
            
        case .artboard:
            if let artboardWrapper = documentWrapper.fileWrappers?[FileName.document] {
                let artboard = try! ArtboardElementCodingService().artboard(from: artboardWrapper.regularFileContents!)
                return (.artboard, artboard)
            }
        }
        
        return (.artboard, Artboard())
    }
    
    /// For version .release
    private func readFrameWrapper(_ frameWrapper: FileWrapper) throws -> Frame {
        print("Read wrapper \(frameWrapper.filename)")
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
        
        let name = frameWrapper.filename ?? UUID().uuidString
        
        // TODO: Put image inside folder
        return Frame(label: name,
                     imageName: "Frame.png",
                     frame: frame,
                     elements: controls)
    }
    
    func createEmptyDocumentWrapper() {
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
