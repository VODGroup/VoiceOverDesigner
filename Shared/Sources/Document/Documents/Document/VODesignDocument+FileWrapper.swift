import Foundation

extension VODesignDocumentProtocol {
    
    // MARK: - Write
    func fileWrapper() throws -> FileWrapper {
        for frame in artboard.frames {
            guard let frameWrapper = try? frameWrapper(for: frame)
            else { continue }
            
            documentWrapper.addFileWrapper(frameWrapper)
        }
        
        if let controlsWithoutFrame = try? controlsWrapper(for: artboard.controlsWithoutFrames) {
            documentWrapper.addFileWrapper(controlsWithoutFrame)
        }
        
        // Save document's structure
        invalidateWrapperIfPossible(fileInRoot: FileName.document)
        let documentStructureWrapper = try documentStructureFileWrapper()
        self.documentWrapper.addFileWrapper(documentStructureWrapper)

        // Preview depends on elements and should be invalidated
        invalidateWrapperIfPossible(fileInRoot: FolderName.quickLook)
        if let previewWrapper = previewWrapper() {
            documentWrapper.addFileWrapper(previewWrapper)
        }

        return documentWrapper
    }
    
    private func frameWrapper(for frame: Frame) throws -> FileWrapper {
        let frameWrapper = documentWrapper.fileWrappers?[frame.label] ?? FileWrapper.createDirectory(preferredFilename: frame.label)
        
        // Just invalidate controls every time to avoid lose of user's data
        frameWrapper.invalidateIfPossible(file: FileName.controls)
        frameWrapper.addFileWrapper(try controlsWrapper(for: frame.elements))

        if frameWrapper.fileWrappers?[FileName.screen] == nil,
           let imageWrapper = imageWrapper(frame: frame) {
            frameWrapper.addFileWrapper(imageWrapper)
        }

        if frameWrapper.fileWrappers?[FileName.info] == nil {
            let frameMetaWrapper = infoWrapper()
            frameWrapper.addFileWrapper(frameMetaWrapper)
        }
        
        return frameWrapper
    }
}

extension VODesignDocumentProtocol {
    
    var isBetaStructure: Bool {
        // controls.json on top of file structure
        documentWrapper.fileWrappers?[FileName.controls] != nil
    }
    
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
    
    private func controlsWrapper(
        for controls: [any ArtboardElement]
    ) throws -> FileWrapper {
        let codingService = ArtboardElementCodingService()
        let wrapper = FileWrapper(regularFileWithContents: try codingService.data(from: controls))
        wrapper.preferredFilename = FileName.controls
        return wrapper
    }

    private func documentStructureFileWrapper(
    ) throws -> FileWrapper {
        let codingService = ArtboardElementCodingService()
        let wrapper = FileWrapper(regularFileWithContents: try codingService.data(from: controls))
        wrapper.preferredFilename = FileName.document
        return wrapper
    }
    
    private func imageWrapper(frame: Frame) -> FileWrapper? {
        guard let imageData = frame.image?.png()
        else { return nil }
        
        let imageWrapper = FileWrapper(regularFileWithContents: imageData)
        imageWrapper.preferredFilename = FileName.screen
        
        return imageWrapper
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
    
    private func infoWrapper() -> FileWrapper {
        let frameMetaData = try! FrameInfoPersistance.data(frame: frameInfo)
        
        let frameMetaWrapper = FileWrapper(regularFileWithContents: frameMetaData)
        frameMetaWrapper.preferredFilename = FileName.info
        return frameMetaWrapper
    }
}

// MARK: - Read
extension VODesignDocumentProtocol {
    
    func read(
        from packageWrapper: FileWrapper
    ) throws {
        guard packageWrapper.isDirectory else {
            createEmptyDocumentWrappert()
            print("Nothing to read, probably the document was just created")
            return
        }
        
        // Keep referente to gently update files for iCloud
        self.documentWrapper = packageWrapper
        for frameWrapper in frameWrappers {
            if let frame = try? readFrameWrapper(frameWrapper) {
                artboard.frames.append(frame)
            } else {
                print("Can't read frame, skip")
            }
        }
        
        if let controlsContent = documentWrapper.fileWrappers?[FileName.controls]?.regularFileContents {
            let codingService = ArtboardElementCodingService()
            artboard.controlsWithoutFrames = try codingService.controls(from: controlsContent)
        }
        
        if isBetaStructure {
            // Reset document wrapper to update file structure
            recreateDocumentWrapper()
        }
    }
    
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
        
        return Frame(label: frameWrapper.filename ?? UUID().uuidString, 
                     image: image,
                     frame: frame,
                     elements: controls)
    }
    
    private func createEmptyDocumentWrappert() {
        self.documentWrapper = FileWrapper(directoryWithFileWrappers: [:])
    }
    
    private func addEmptyFrameWrapper() {
        let frameWrapper = FileWrapper(directoryWithFileWrappers: [:])
        frameWrapper.preferredFilename = defaultFrameName
        self.documentWrapper.addFileWrapper(frameWrapper)
    }
    
    private func recreateDocumentWrapper() {
        createEmptyDocumentWrappert()
        addEmptyFrameWrapper()
    }
    
    func invalidateWrapperIfPossible(fileInRoot: String) {
        if let wrapper = documentWrapper.fileWrappers?[fileInRoot] {
            documentWrapper.removeFileWrapper(wrapper)
        }
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
