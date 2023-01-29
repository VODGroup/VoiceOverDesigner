import Foundation

class FileKeeperService {
    
    let file: URL
    init(url: URL, fileName: String) {
        self.file = url.appendingPathComponent(fileName)
    }
}

class FrameReader {
    
    init(frameURL: URL) {
        let dataProvider = URLDataProvider(
            url: frameURL,
            fileName: FileName.controls)
        
        self.saveService = DocumentSaveService(
            dataProvider: dataProvider)
        
        self.frameInfoPersistance = FrameInfoPersistance(
            url: frameURL, fileName: FileName.info)
        
        self.imageSaveService = ImageSaveService(
            url: frameURL, fileName: FileName.screen)
    }
    
    let saveService: DocumentSaveService
    let frameInfoPersistance: FrameInfoPersistance
    let imageSaveService: ImageSaveService
}

extension URL {
    public func frameURL(frameName: String) -> URL {
        let topLevelDocumentPath = self.appendingPathComponent(FileName.controls).path
        
        let isBetaStructure = FileManager.default.fileExists(atPath: topLevelDocumentPath)
        
        if isBetaStructure {
            return self
        } else {
            return self.appendingPathComponent(frameName)
        }
    }
    
    public func previewURL() -> URL {
        appendingPathComponent("QuickView/Preview.png")
    }
}
