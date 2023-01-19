import Foundation

class FileKeeperService {
    
    let file: URL
    init(url: URL, fileName: String) {
        self.file = url.appendingPathComponent(fileName)
    }
}

class FrameReader {
    
    init(documentURL: URL) {
        self.saveService = DocumentSaveService(
            url: documentURL, fileName: FileName.controls)
        
        self.frameInfoPersistance = FrameInfoPersistance(
            url: documentURL, fileName: FileName.info)
        
        self.imageSaveService = ImageSaveService(
            url: documentURL, fileName: FileName.screen)
    }
    
    let saveService: DocumentSaveService
    let frameInfoPersistance: FrameInfoPersistance
    let imageSaveService: ImageSaveService
}
