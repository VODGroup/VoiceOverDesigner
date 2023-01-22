import Foundation

class FileKeeperService {
    
    let file: URL
    init(url: URL, fileName: String) {
        self.file = url.appendingPathComponent(fileName)
    }
}

class FrameReader {
    
    init(documentURL: URL, frameName: String) {
        let frameURL = Self.frameURL(documentURL: documentURL, frameName: frameName)
        
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
    
    private static func frameURL(documentURL: URL, frameName: String) -> URL {
        let topLevelDocumentPath = documentURL.appendingPathComponent(FileName.controls).path
        let isBetaStructure = FileManager.default.fileExists(atPath: topLevelDocumentPath)
        if isBetaStructure {
            return documentURL
        } else {
            return documentURL.appendingPathComponent(frameName)
        }
    }
    
    let saveService: DocumentSaveService
    let frameInfoPersistance: FrameInfoPersistance
    let imageSaveService: ImageSaveService
}
